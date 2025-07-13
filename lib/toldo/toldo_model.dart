import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:ui';
import '/backend/schema/structs/index.dart';
import '/index.dart';
import 'dart:async';
import 'toldo_widget.dart' show ToldoWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ToldoModel extends FlutterFlowModel<ToldoWidget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Stores action output result for [Backend Call - API (Motor frente)] action in Button widget.
  ApiCallResponse? apiResultrq7;
  // Stores action output result for [Backend Call - API (Motor Tras)] action in Button widget.
  ApiCallResponse? apiResultqqd;
  // State field(s) for container widget.
  bool? switchValue1;
  // State field(s) for Slider1 widget.
  double? slider1Value;
  // Stores action output result for [Backend Call - API (SliderToldo)] action in Slider1 widget.
  ApiCallResponse? apiResultjjf;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // Stores action output result for [Backend Call - API (ToldoChuvaOn)] action in Switch widget.
  ApiCallResponse? apiResultwoe;
  // Stores action output result for [Backend Call - API (ToldoChuvaOff)] action in Switch widget.
  ApiCallResponse? apiResult1x3;

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
