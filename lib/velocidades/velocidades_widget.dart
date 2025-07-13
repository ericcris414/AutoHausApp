import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'velocidades_model.dart';
export 'velocidades_model.dart';

class VelocidadesWidget extends StatefulWidget {
  const VelocidadesWidget({super.key});

  static String routeName = 'Velocidades';
  static String routePath = '/velocidades';

  @override
  State<VelocidadesWidget> createState() => _VelocidadesWidgetState();
}

class _VelocidadesWidgetState extends State<VelocidadesWidget> {
  late VelocidadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // --- Variáveis de Estado para MQTT ---
  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;

  // --- Tópicos MQTT (conforme o código do ESP32) ---
  final String _topicBase = "casa/erick/toldo_janela";
  late final String _topicToldoVelocidadeSet;
  late final String _topicToldoVelocidadeReset;
  late final String _topicJanelaVelocidadeSet;
  late final String _topicJanelaVelocidadeReset;
  late final String _topicVelocidadesGeralEstado;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VelocidadesModel());

    // Inicializa os tópicos MQTT
    _topicToldoVelocidadeSet = '$_topicBase/toldo/velocidade/set';
    _topicToldoVelocidadeReset = '$_topicBase/toldo/velocidade/reset';
    _topicJanelaVelocidadeSet = '$_topicBase/janela/velocidade/set';
    _topicJanelaVelocidadeReset = '$_topicBase/janela/velocidade/reset';
    _topicVelocidadesGeralEstado = '$_topicBase/velocidades/estado';

    _model.textFieldATTextController ??=
        TextEditingController(text: FFAppState().velAtras.toString());
    _model.textFieldATFocusNode ??= FocusNode();

    _model.textFieldBFTextController ??=
        TextEditingController(text: FFAppState().velBfrente.toString());
    _model.textFieldBFFocusNode ??= FocusNode();

    _model.textController3 ??=
        TextEditingController(text: FFAppState().velJanelaAbrir.toString());
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldAFTextController ??=
        TextEditingController(text: FFAppState().velAfrente.toString());
    _model.textFieldAFFocusNode ??= FocusNode();

    _model.textFieldBTTextController ??=
        TextEditingController(text: FFAppState().velBtras.toString());
    _model.textFieldBTFocusNode ??= FocusNode();

    _model.textController6 ??=
        TextEditingController(text: FFAppState().velJanelaFechar.toString());
    _model.textFieldFocusNode2 ??= FocusNode();

    // Conecta ao MQTT ao iniciar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _client?.disconnect();
    _model.dispose();
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[MQTT Velocidades] $message');
  }

  Future<void> _connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected || _client?.connectionStatus?.state == MqttConnectionState.connecting) return;

    final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
    final int port = 8883;
    final String username = 'Erickkk';
    final String password = '96488941Ab';
    final String clientId = 'flutter_velocidades_ui_${DateTime.now().millisecondsSinceEpoch}';

    _log('Iniciando conexão com $url:$port...');
    _client = MqttServerClient.withPort(url, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = (topic) => _log('Inscrito no tópico: $topic');

    _client!.secure = true;
    _client!.securityContext = SecurityContext.defaultContext;
    _client!.connectionMessage = MqttConnectMessage().withClientIdentifier(clientId).startClean();

    try {
      await _client!.connect(username, password);
    } catch (e) {
      _log('ERRO ao conectar: ${e.toString()}');
      _disconnect();
    }
  }

  void _onConnected() {
    _log('Conexão MQTT estabelecida!');
    if (!mounted) return;

    _client!.subscribe(_topicVelocidadesGeralEstado, MqttQos.atLeastOnce);

    _updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;

      _log('Mensagem recebida no tópico [$topic]: "$payload"');

      try {
        final Map<String, dynamic> jsonPayload = json.decode(payload);
        if (!mounted) return;

        setState(() {
          if (topic == _topicVelocidadesGeralEstado) {
            if (jsonPayload.containsKey('toldo')) {
              final toldoVels = jsonPayload['toldo'];
              FFAppState().velAfrente = (toldoVels['vaf'] as num?)?.toInt() ?? FFAppState().velAfrente;
              FFAppState().velBfrente = (toldoVels['vbf'] as num?)?.toInt() ?? FFAppState().velBfrente;
              FFAppState().velAtras = (toldoVels['vat'] as num?)?.toInt() ?? FFAppState().velAtras;
              FFAppState().velBtras = (toldoVels['vbt'] as num?)?.toInt() ?? FFAppState().velBtras;
            }
            if (jsonPayload.containsKey('janela')) {
              final janelaVels = jsonPayload['janela'];
              FFAppState().velJanelaAbrir = (janelaVels['vabrir'] as num?)?.toInt() ?? FFAppState().velJanelaAbrir;
              FFAppState().velJanelaFechar = (janelaVels['vfechar'] as num?)?.toInt() ?? FFAppState().velJanelaFechar;
            }

            // Atualiza os TextControllers com os valores do AppState
            _model.textFieldATTextController?.text = FFAppState().velAtras.toString();
            _model.textFieldBFTextController?.text = FFAppState().velBfrente.toString();
            _model.textController3?.text = FFAppState().velJanelaAbrir.toString();
            _model.textFieldAFTextController?.text = FFAppState().velAfrente.toString();
            _model.textFieldBTTextController?.text = FFAppState().velBtras.toString();
            _model.textController6?.text = FFAppState().velJanelaFechar.toString();

            FFAppState().update(() {}); // Força a atualização do AppState global
          }
        });
      } catch (e) {
        _log("Erro ao processar mensagem do tópico [$topic]: $e");
      }
    });
  }

  void _onDisconnected() {
    _log('Desconectado do MQTT.');
  }

  void _disconnect() {
    _client?.disconnect();
  }

  void _publishCommand(String topic, String message) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      _log('Não conectado, impossível publicar.');
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _log('Publicado no tópico [$topic]: "$message"');
  }

  void _publishJsonCommand(String topic, Map<String, dynamic> jsonData) {
    final String jsonString = json.encode(jsonData);
    _publishCommand(topic, jsonString);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF010B14),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: 402.0,
                      height: 906.0,
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 18.0, 0.0, 0.0),
                              child: Text(AppLocalizations.of(context)!.ajusteVel,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 345.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.janela,
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 215.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.toldoRecolher,
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 85.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.toldoAbrir,
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 140.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldATTextController,
                                  focusNode: _model.textFieldATFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldATTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velAtras = int.parse(text);
                                      FFAppState().update(() {});
                                      // Publica a velocidade do toldo ao ESP32
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FFAppState().velAfrente,
                                        "vbf": FFAppState().velBfrente,
                                        "vat": FFAppState().velAtras,
                                        "vbt": FFAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velATras,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: '210',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldATTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 270.0, 0.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldBFTextController,
                                  focusNode: _model.textFieldBFFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldBFTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velBfrente = int.parse(text);
                                      FFAppState().update(() {});
                                      // Publica a velocidade do toldo ao ESP32
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FFAppState().velAfrente,
                                        "vbf": FFAppState().velBfrente,
                                        "vat": FFAppState().velAtras,
                                        "vbt": FFAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velBFrente,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldBFTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 400.0, 0.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textController3,
                                  focusNode: _model.textFieldFocusNode1,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textController3',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velJanelaAbrir = int.parse(text);
                                      safeSetState(() {});
                                      // Publica a velocidade da janela ao ESP32
                                      _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                        "vabrir": FFAppState().velJanelaAbrir,
                                        "vfechar": FFAppState().velJanelaFechar,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.abrirA,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textController3Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 140.0, 0.0, 10.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldAFTextController,
                                  focusNode: _model.textFieldAFFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldAFTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velAfrente = int.parse(text);
                                      FFAppState().update(() {});
                                      // Publica a velocidade do toldo ao ESP32
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FFAppState().velAfrente,
                                        "vbf": FFAppState().velBfrente,
                                        "vat": FFAppState().velAtras,
                                        "vbt": FFAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velAFrente,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFF14181B),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldAFTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 270.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldBTTextController,
                                  focusNode: _model.textFieldBTFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldBTTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velBtras = int.parse(text);
                                      FFAppState().update(() {});
                                      // Publica a velocidade do toldo ao ESP32
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FFAppState().velAfrente,
                                        "vbf": FFAppState().velBfrente,
                                        "vat": FFAppState().velAtras,
                                        "vbt": FFAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velBTras,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldBTTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 400.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textController6,
                                  focusNode: _model.textFieldFocusNode2,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textController6',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FFAppState().velJanelaFechar = int.parse(text);
                                      safeSetState(() {});
                                      // Publica a velocidade da janela ao ESP32
                                      _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                        "vabrir": FFAppState().velJanelaAbrir,
                                        "vfechar": FFAppState().velJanelaFechar,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.fecharA,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textController6Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  120.0, 560.0, 120.0, 10.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  // Publica o comando de reset para toldo e janela
                                  _publishCommand(_topicToldoVelocidadeReset, "RESET");
                                  _publishCommand(_topicJanelaVelocidadeReset, "RESET");

                                  // Resetar os valores locais (opcional, já que o ESP32 vai publicar os defaults)
                                  FFAppState().velAfrente = 87;
                                  FFAppState().velBfrente = 200;
                                  FFAppState().velAtras = 210;
                                  FFAppState().velBtras = 90;
                                  FFAppState().velJanelaAbrir = 100;
                                  FFAppState().velJanelaFechar = 100;
                                  FFAppState().update(() {});

                                  // Atualiza os TextControllers para refletir os valores resetados
                                  _model.textFieldATTextController?.text = FFAppState().velAtras.toString();
                                  _model.textFieldBFTextController?.text = FFAppState().velBfrente.toString();
                                  _model.textController3?.text = FFAppState().velJanelaAbrir.toString();
                                  _model.textFieldAFTextController?.text = FFAppState().velAfrente.toString();
                                  _model.textFieldBTTextController?.text = FFAppState().velBtras.toString();
                                  _model.textController6?.text = FFAppState().velJanelaFechar.toString();

                                  safeSetState(() {}); // Força a reconstrução da UI
                                },
                                text: AppLocalizations.of(context)!.resetarVelocidades,
                                icon: Icon(
                                  Icons.replay,
                                  size: 15.0,
                                ),
                                options: FFButtonOptions(
                                  width: 170.0,
                                  height: 65.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  120.0, 480.0, 120.0, 10.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  // Publica as velocidades do toldo ao ESP32
                                  _publishJsonCommand(_topicToldoVelocidadeSet, {
                                    "vaf": FFAppState().velAfrente,
                                    "vbf": FFAppState().velBfrente,
                                    "vat": FFAppState().velAtras,
                                    "vbt": FFAppState().velBtras,
                                  });

                                  // Publica as velocidades da janela ao ESP32
                                  _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                    "vabrir": FFAppState().velJanelaAbrir,
                                    "vfechar": FFAppState().velJanelaFechar,
                                  });

                                  safeSetState(() {});
                                },
                                text: AppLocalizations.of(context)!.definirVelocidades,
                                icon: Icon(
                                  Icons.done,
                                  size: 15.0,
                                ),
                                options: FFButtonOptions(
                                  width: 165.0,
                                  height: 65.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}