import 'dart:async';
import 'dart:convert';

import 'package:CAPO/constants/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

part 'chart_event.dart';

part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  late final StompClient _client;

  ChartBloc() : super(ChartInitial()) {
    _client = StompClient(
      config: StompConfig.SockJS(
        url: 'http://192.168.1.58:8080/ws',
        onConnect: _onConnect,
        onDebugMessage: (msg) => print('[STOMP] $msg'),
      ),
    );
    _client.activate(); // <-- you must call activate to connect
  }

  void _onConnect(StompFrame frame) {
    emit(ChartLoadInProgress());
    _client.subscribe(
      destination: "/topic/chart/3004Pump1",
      callback: _onNewChartData,
    );
  }

  List<Map<String, dynamic>> allRows = [];

  void _onNewChartData(StompFrame frame) {
    if (frame.body != null) {
      try {
        final newRows =
        (jsonDecode(frame.body!) as List).cast<Map<String, dynamic>>();

        // 1) Append all incoming rows
        allRows.addAll(newRows);

        // 2) Globally trim to MAX_POINTS
        if (allRows.length > Constants.MAX_POINTS) {
          allRows = allRows.sublist(allRows.length - Constants.MAX_POINTS);
        }

        // 3) Regroup the trimmed allRows
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final row in allRows) {
          final tag = row['tag_name'] ?? '';
          grouped.putIfAbsent(tag, () => []).add(row);
        }

        // 4) Emit the grouped state
        emit(ChartDataUpdated(raw: grouped));
      } catch (e) {
        emit(ChartLoadFailure(message: 'Data parsing error'));
      }
    }
  }

  @override
  Future<void> close() {
    _client.deactivate();
    return super.close();
  }
}
