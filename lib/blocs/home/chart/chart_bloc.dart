import 'dart:async';
import 'dart:convert';

import 'package:CAPO/constants/constants.dart';
import 'package:CAPO/data/models/dashboard.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

part 'chart_event.dart';

part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  StompClient? _client;
  Function? _unsubscribe; // holds the unsubscribe function
  final Map<String, List<Map<String, dynamic>>> tagDataMap = {};
  String? _currentGroupName;

  ChartBloc() : super(ChartInitial()) {
    on<ChartGroupSelected>(_onChartGroupSelected);
  }

  Future<void> _onChartGroupSelected(ChartGroupSelected event,
      Emitter<ChartState> emit,) async {
    emit(ChartLoadInProgress());

    final newGroup = event.selectedDashboard.group_name;

    // If already subscribed to the same group, do nothing
    if (_currentGroupName == newGroup && _client?.connected == true) {
      return;
    }

    // Unsubscribe from previous group if needed
    if (_unsubscribe != null) {
      _unsubscribe!();
      _unsubscribe = null;
    }

    // Clear old data
    tagDataMap.clear();
    _currentGroupName = newGroup;

    // Create client if not created yet
    _client ??= StompClient(
      config: StompConfig(
        url: Constants.WS_BASE_URL,
        onConnect: (frame) {
          if (_client == null) return; // Guard against null
          print('Connected to STOMP');

          // Subscribe safely
          _unsubscribe = _client!.subscribe(
            destination: "/topic/chart/$newGroup",
            callback: _onNewChartData,
          );

          // Send group request
          _client!.send(
            destination: "/app/charts",
            body: newGroup,
          );
        },
        onDisconnect: (frame) {
          print('Disconnected');
          _client = null;
        },
        onStompError: (frame) {
          print('STOMP error: ${frame.body}');
        },
        onWebSocketError: (error) {
          print('WebSocket error: $error');
          _client = null;
        },
        onDebugMessage: (msg) => print('[STOMP] $msg'),
      ),
    );

    // If already connected, re-subscribe immediately
    if (_client!.connected) {
      // Same logic as onConnect, but immediate
      _unsubscribe = _client!.subscribe(
        destination: "/topic/chart/$newGroup",
        callback: _onNewChartData,
      );

      _client!.send(
        destination: "/app/charts",
        body: newGroup,
      );
    } else {
      _client!.activate();
    }
  }

  void _onNewChartData(StompFrame frame) {
    if (frame.body != null) {
      try {
        String cleaned = frame.body!.replaceAll('\u0000', '').trim();
        final newRows = (jsonDecode(cleaned) as List)
            .cast<Map<String, dynamic>>();

        for (final row in newRows) {
          final tag = row['tag_name'] ?? '';
          if (tag.isEmpty) continue;

          final tagList = tagDataMap.putIfAbsent(tag, () => []);
          tagList.add(row);

          // Keep only the latest 20 data points
          if (tagList.length > Constants.MAX_POINTS) {
            tagList.removeRange(0, tagList.length - Constants.MAX_POINTS);
          }
        }
        emit(ChartDataUpdated(
          raw: Map.fromEntries(
            tagDataMap.entries.map(
                  (e) => MapEntry(e.key, List<Map<String, dynamic>>.from(e.value)),
            ),
          ),
        ));
      } catch (e) {
        emit(ChartLoadFailure(message: 'Data parsing error'));
      }
    }
  }

  @override
  Future<void> close() {
    _unsubscribe?.call();
    _unsubscribe = null;
    _currentGroupName = null;
    _client?.deactivate();
    return super.close();
  }
}