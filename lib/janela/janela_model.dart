import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:ui';
import '/backend/schema/structs/index.dart';
import '/index.dart';
import 'dart:async';
import 'janela_widget.dart' show JanelaWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class JanelaModel extends FlutterFlowModel<JanelaWidget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Stores action output result for [Backend Call - API (Abrir Janela)] action in Button widget.
  ApiCallResponse? apiResulte0e;
  // Stores action output result for [Backend Call - API (Fechar Janela)] action in Button widget.
  ApiCallResponse? apiResult4tx;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Slider12 widget.
  double? slider1Value;
  // Stores action output result for [Backend Call - API (Slider Janela)] action in Slider12 widget.
  ApiCallResponse? apiResultjjf;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // Stores action output result for [Backend Call - API (JanelaChuvaOn)] action in Switch widget.
  ApiCallResponse? apiResultok3;
  // Stores action output result for [Backend Call - API (JanelaChuvaOff)] action in Switch widget.
  ApiCallResponse? apiResultz99;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
