import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class MotorFrenteCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Motor frente',
      apiUrl: 'http://${esp32Ip}:32567/setMovimentoToldo?percent=100',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class MotorTrasCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Motor Tras',
      apiUrl: 'http://${esp32Ip}:32567/setMovimentoToldo?percent=0',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SliderToldoCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
    String? slidertoldo = '[slidertoldo]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'SliderToldo',
      apiUrl:
          'http://${esp32Ip}:32567/setMovimentoToldo?percent=${slidertoldo}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SlidertoldotestCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
    String? slidertoldo1 = '[slidertoldo1]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Slidertoldotest',
      apiUrl:
          'http://${esp32Ip}:32567/setMovimentoToldo?percent=${slidertoldo1}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ToldoChuvaOffCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoChuvaOff',
      apiUrl: 'http://${esp32Ip}:32567/toggleSensorToldo?sensor=off',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ToldoChuvaOnCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoChuvaOn',
      apiUrl: 'http://${esp32Ip}:32567/toggleSensorToldo?sensor=on',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class EstadoSensorCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'EstadoSensor',
      apiUrl: 'http://${esp32Ip}:32567/chuv',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiTestCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'api test',
      apiUrl: 'http://${esp32Ip}:32567/chuva',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String seco(dynamic response) => getJsonField(
        response,
        r'''$.estado''',
      );

  static int posicaoToldo(dynamic response) => getJsonField(
        response,
        r'''$.aberto''',
      );

  static int posicaoJanela(dynamic response) => getJsonField(
        response,
        r'''$.aberta''',
      );
}
class VelocidadeToldoCall {
  static Future<ApiCallResponse> call({
    String? velAfrente = '[velAfrente]',
    String? velBfrente = '[velBfrente]',
    String? velAtras = '[velAtras]',
    String? velBtras = '[velBtras]',
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Velocidade Toldo',
      apiUrl:
          'http://${esp32Ip}:32567/setSpeed?velAFrente=${velAfrente}&velBFrente=${velBfrente}&velATras=${velAtras}&velBTras=${velBtras}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ResetVelocidadesCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Reset Velocidades',
      apiUrl: 'http://${esp32Ip}:32567/resetSpeed',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class MotorAFrenteCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'motor A frente',
      apiUrl: 'http://${esp32Ip}:32567/motorA/frente',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class MotorBFrenteCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Motor B Frente',
      apiUrl: 'http://${esp32Ip}:32567/motorB/frente',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class MotorATrasCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Motor A Tras',
      apiUrl: 'http://${esp32Ip}:32567/motorA/tras',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class MotorBTrasCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Motor B Tras',
      apiUrl: 'http://${esp32Ip}:32567/motorB/tras',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PararMotoresCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Parar motores',
      apiUrl: 'http://${esp32Ip}:32567/parar',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class FecharJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Fechar Janela',
      apiUrl: 'http://${esp32Ip}:32567/setMovimentoJanela?percent=0',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AbrirJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Abrir Janela',
      apiUrl: 'http://${esp32Ip}:32567/setMovimentoJanela?percent=100',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SliderJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
    String? sliderjanela = '[SliderJanela]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Slider Janela',
      apiUrl:
          'http://${esp32Ip}:32567/setMovimentoJanela?percent=${sliderjanela}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class VelocidadeJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32_ip]',
    String? velJanelaAbrir = '[velJanelaAbrir]',
    String? velJanelaFechar = '[velJanelaFechar]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Velocidade Janela',
      apiUrl:
          'http://${esp32Ip}:32567/setSpeedJanela?velAbrir=${velJanelaAbrir}&velFechar=${velJanelaFechar}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class JanelaChuvaOnCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'JanelaChuvaOn',
      apiUrl: 'http://${esp32Ip}:32567/toggleSensorJanela?sensor=on',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class JanelaChuvaOffCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'JanelaChuvaOff',
      apiUrl: 'http://${esp32Ip}:32567/toggleSensorJanela?sensor=off',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class FrenteJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Frente Janela',
      apiUrl: 'http://${esp32Ip}:32567/motorC/abrir',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class TrasJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Tras Janela',
      apiUrl: 'http://${esp32Ip}:32567/motorC/fechar',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ResetVelocidadeJanelaCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Reset Velocidade Janela',
      apiUrl: 'http://${esp32Ip}:32567/resetSpeedJanela',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ToldoAbrirCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoAbrir',
      apiUrl: 'http://${esp32Ip}:32567/ToldoAbrir',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ToldoRecolherCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoRecolher',
      apiUrl: 'http://${esp32Ip}:32567/ToldoRecolher',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class JanelaAbrirCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoAbrir',
      apiUrl: 'http://${esp32Ip}:32567/JanelaAbrir',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class JanelaFecharCall {
  static Future<ApiCallResponse> call({
    String? esp32Ip = '[esp32ip]',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ToldoAbrir',
      apiUrl: 'http://${esp32Ip}:32567/JanelaFechar',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
