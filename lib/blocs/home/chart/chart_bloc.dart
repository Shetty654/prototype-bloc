import 'dart:async';
import 'dart:convert';

import 'package:CAPO/constants/constants.dart';
import 'package:CAPO/data/models/dashboard.dart';
import 'package:CAPO/data/repositories/home/chart/chart_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

part 'chart_event.dart';

part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final ChartRepository chartRepository;
  StompClient? _client;
  Function? _unsubscribe; // holds the unsubscribe function
  final Map<String, List<Map<String, dynamic>>> tagDataMap = {};
  String? _currentGroupName;
  Dashboard? _currentDashboard;

  ChartBloc({required this.chartRepository}) : super(ChartInitial()) {
    on<ChartGroupSelected>(_onChartGroupSelected);
    on<StartLiveChart>(_onStartLiveChart);
    on<FetchHistoricalChart>(_onFetchHistoricalChart);
    on<StopLiveUpdates>(_onStopLiveUpdates);
  }

  Future<void> _onStopLiveUpdates(
      StopLiveUpdates event,
      Emitter<ChartState> emit,
      ) async {
    // Unsubscribe and disconnect if live subscription exists
    if (_unsubscribe != null) {
      _unsubscribe!();
      _unsubscribe = null;
    }
    _client?.deactivate();
    _client = null;

    // Optionally clear current group name and tag data map if you want a clean state
    _currentGroupName = null;
    tagDataMap.clear();

    // Emit a state indicating live is stopped or paused
    emit(ChartLiveStopped());
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

        for (final row in newRows) {
          final tag = row['custom_name'] ?? '';
          if (tag.isEmpty) continue;

          final tagList = tagDataMap.putIfAbsent(tag, () => []);
          tagList.add(row);

          // Limit to MAX_POINTS
          if (tagList.length > Constants.MAX_POINTS) {
            tagList.removeRange(0, tagList.length - Constants.MAX_POINTS);
          }

        }
        final tagCounts = <String, int>{};
        for (final row in newRows) {
          final tag = row['custom_name'] ?? '';
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
        tagCounts.forEach((tag, count) => print('  $tag => $count'));
        // Emit the updated chart state with copied data
        emit(
          ChartLiveUpdated(
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

  FutureOr<void> _onStartLiveChart(StartLiveChart event, Emitter<ChartState> emit) {
    add(ChartGroupSelected(selectedDashboard: event.dashboard));
  }

  FutureOr<void> _onFetchHistoricalChart(FetchHistoricalChart event, Emitter<ChartState> emit) async {
    emit(ChartLoadInProgress());
    try{
      final data = await chartRepository.fetchHistoricalData(projectName: event.projectName,
        groupName: event.dashboard.group_name,
        beforeTS: event.beforeTs,
        windowSec: event.windowSec,
      );
      tagDataMap..clear()..addAll(data);
      emit(ChartHistoricalUpdated(
        raw: Map.fromEntries(
          tagDataMap.entries.map((e) => MapEntry(
            e.key,
            List<Map<String, dynamic>>.from(e.value),
          )),
        ),
      ));
    }catch(e){
      emit(ChartLoadFailure(message: 'Failed to load historical data: $e'));
    }
  }
}