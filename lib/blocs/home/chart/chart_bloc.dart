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

  Future<void> _onChartGroupSelected(
      ChartGroupSelected event,
      Emitter<ChartState> emit,
      ) async {
    emit(ChartLoadInProgress());

    final newGroup = event.selectedDashboard.group_name;

    // 1) If we're already on this group and still connected, do nothing.
    if (newGroup == _currentGroupName && _client?.connected == true) {
      return;
    }

    // 2) Unsubscribe / deactivate any old connection.
    if (_unsubscribe != null) {
      _unsubscribe!();
      _unsubscribe = null;
    }
    _client?.deactivate();
    _client = null;

    // 3) Clear old data and remember the new group
    tagDataMap.clear();
    _currentGroupName = newGroup;

    // 4) Create & configure our STOMP client
    _client = StompClient(
      config: StompConfig(
        url: Constants.WS_BASE_URL,
        onConnect: (frame) {
          // Once connected, subscribe and request data
          _unsubscribe = _client!.subscribe(
            destination: "/topic/chart/$newGroup",
            callback: _onNewChartData,
          );
          _client!.send(
            destination: "/app/charts",
            body: newGroup,
          );
        },
        onDisconnect: (frame) {
          print('Disconnected');
        },
        onStompError: (frame) {
          print('STOMP error: ${frame.body}');
        },
        onWebSocketError: (error) {
          print('WebSocket error: $error');
        },
        onDebugMessage: (msg) => print('[STOMP] $msg'),
      ),
    );

    // 5) Activate the client. onConnect will handle the subscription.
    _client!.activate();
  }
  void _onNewChartData(StompFrame frame) {
    if (frame.body != null) {
      try {
        // Clean up the STOMP message payload
        String cleaned = frame.body!.replaceAll('\u0000', '').trim();

        // Decode JSON to List<Map<String, dynamic>>
        final newRows = (jsonDecode(cleaned) as List).cast<Map<String, dynamic>>();

        print('[DEBUG] Received ${newRows.length} new rows');

        for (final row in newRows) {
          final tag = row['custom_name'] ?? '';
          if (tag.isEmpty) continue;

          final tagList = tagDataMap.putIfAbsent(tag, () => []);
          tagList.add(row);

          // Limit to MAX_POINTS
          if (tagList.length > Constants.MAX_POINTS) {
            tagList.removeRange(0, tagList.length - Constants.MAX_POINTS);
          }

          for (final entry in tagDataMap.entries) {
            print('[DEBUG] Tag: ${entry.key} | Total Points: ${entry.value.length}');
          }

          print('[DEBUG] Tag: $tag | Total Points: ${tagList.length}');
        }
        final tagCounts = <String, int>{};
        for (final row in newRows) {
          final tag = row['custom_name'] ?? '';
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
        print('[DEBUG] Per-tag counts from incoming data:');
        tagCounts.forEach((tag, count) => print('  $tag => $count'));
        // Emit the updated chart state with copied data
        emit(
          ChartDataUpdated(
            raw: Map.fromEntries(
              tagDataMap.entries.map(
                    (e) => MapEntry(
                  e.key,
                  List<Map<String, dynamic>>.from(e.value),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        print('[ERROR] Data parsing error: $e');
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