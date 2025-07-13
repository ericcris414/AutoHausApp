import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

// Seus imports originais do FlutterFlow
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Mantido para navegação, se necessário
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import do seu modelo
import 'janela_model.dart';
export 'janela_model.dart';

class JanelaWidget extends StatefulWidget {
  const JanelaWidget({super.key});

  static String routeName = 'Janela';
  static String routePath = '/janela';

  @override
  State<JanelaWidget> createState() => _JanelaWidgetState();
}

class _JanelaWidgetState extends State<JanelaWidget> {
  late JanelaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // --- Variáveis de Estado para MQTT e UI ---
  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;

  // Variáveis para guardar o estado recebido do ESP32
  double _posicaoJanela = 0.0;
  String _statusChuva = 'SECO';
  bool _automacaoChuva = false;

  // --- Tópicos MQTT ---
  final String _topicBase = "casa/erick/toldo_janela";
  late final String _topicJanelaCmd;
  late final String _topicJanelaEstado;
  late final String _topicSensorEstado;
  late final String _topicSensorConfig;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JanelaModel());

    // Inicializa os tópicos MQTT
    _topicJanelaCmd = '$_topicBase/janela/cmd';
    _topicJanelaEstado = '$_topicBase/janela/estado';
    _topicSensorEstado = '$_topicBase/sensor/estado';
    _topicSensorConfig = '$_topicBase/sensor/config';

    // Inicializa os valores dos switches com base no AppState
    _model.switchValue1 = FFAppState().sliderjanela;
    _model.switchValue2 = FFAppState().sliderChuvaJanela;

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
    debugPrint('[MQTT Janela] $message');
  }

  Future<void> _connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected || _client?.connectionStatus?.state == MqttConnectionState.connecting) return;

    final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
    final int port = 8883;
    final String username = 'Erickkk';
    final String password = '96488941Ab';
    final String clientId = 'flutter_janela_ui_${DateTime.now().millisecondsSinceEpoch}';

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

    _client!.subscribe(_topicJanelaEstado, MqttQos.atLeastOnce);
    _client!.subscribe(_topicSensorEstado, MqttQos.atLeastOnce);

    _updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;

      _log('Mensagem recebida no tópico [$topic]: "$payload"');

      try {
        final Map<String, dynamic> jsonPayload = json.decode(payload);
        if (!mounted) return;

        setState(() {
          if (topic == _topicJanelaEstado && jsonPayload.containsKey('posicao')) {
            _posicaoJanela = (jsonPayload['posicao'] as num).toDouble();
            _model.slider1Value = _posicaoJanela;
          } else if (topic == _topicSensorEstado) {
            if (jsonPayload.containsKey('chuva')) {
              _statusChuva = jsonPayload['chuva'] as String;
            }
            if (jsonPayload.containsKey('autoMovJanela')) {
              _automacaoChuva = jsonPayload['autoMovJanela'] as bool;
              _model.switchValue2 = _automacaoChuva;
            }
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
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 335.5,
                            height: 460.8,
                            decoration: BoxDecoration(
                              color: Color(0xFF14181B),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(50.0, 35.0, 50.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () => _publishCommand(_topicJanelaCmd, "FECHAR"),
                                      text: AppLocalizations.of(context)!.fechar,
                                      icon: Icon(Icons.arrow_upward, color: FlutterFlowTheme.of(context).info, size: 24.0),
                                      options: FFButtonOptions(
                                        width: 140.0,
                                        height: 60.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                              fontFamily: 'Inter Tight',
                                              color: FlutterFlowTheme.of(context).info,
                                            ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(50.0, 10.0, 50.0, 190.0),
                                    child: FFButtonWidget(
                                      onPressed: () => _publishCommand(_topicJanelaCmd, "ABRIR"),
                                      text: AppLocalizations.of(context)!.abrir,
                                      icon: Icon(Icons.arrow_downward_sharp, color: FlutterFlowTheme.of(context).info, size: 24.0),
                                      options: FFButtonOptions(
                                        width: 140.0,
                                        height: 60.0,
                                        color: Color(0xFF272C32),
                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                              fontFamily: 'Inter Tight',
                                              color: FlutterFlowTheme.of(context).info,
                                            ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.5, 205.0, 16.5, 0.0),
                                  child: Container(
                                    width: 302.0,
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1D2428),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: AlignmentDirectional(-1.0, -1.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(162.0, 25.0, 0.0, 0.0),
                                            child: Text(
                                              '${_posicaoJanela.round()}%',
                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    fontFamily: 'Inter Tight',
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(1.0, -1.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(230.0, 15.0, 15.0, 0.0),
                                            child: Switch(
                                              value: _model.switchValue1!,
                                              onChanged: (newValue) => setState(() => _model.switchValue1 = newValue),
                                              activeColor: FlutterFlowTheme.of(context).primaryText,
                                              activeTrackColor: FlutterFlowTheme.of(context).primary,
                                              inactiveTrackColor: Color(0xFF98999A),
                                              inactiveThumbColor: FlutterFlowTheme.of(context).primaryText,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                                          child: Slider(
                                            activeColor: Color(0xFF4B39EF),
                                            inactiveColor: Colors.white,
                                            min: 0.0,
                                            max: 100.0,
                                            value: _model.slider1Value ?? _posicaoJanela,
                                            divisions: 10,
                                            onChanged: !_model.switchValue1!
                                                ? null
                                                : (newValue) => setState(() => _model.slider1Value = newValue),
                                            onChangeEnd: (newValue) {
                                              if (!_model.switchValue1!) return;
                                              final pos = newValue.round();
                                              _publishCommand(_topicJanelaCmd, 'POS:$pos');
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(-1.0, -1.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(20.0, 25.0, 0.0, 0.0),
                                            child: Text(
                                  '${AppLocalizations.of(context)!.controleManual}: ',
                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    fontFamily: 'Inter Tight',
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //  MODIFICAÇÃO APLICADA AQUI
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.5, 350.0, 16.5, 34.0),
                                  child: Container(
                                    width: 302.0,
                                    height: 78.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1D2428),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: Align(
                                      // Alinhamento alterado para a esquerda (center-left)
                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                                        child: RichText(
                                          //textAlign opcional, pois left é o padrão
                                          textAlign: TextAlign.left, 
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${AppLocalizations.of(context)!.detecaoChuva} ',
                                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                                      fontFamily: 'Inter Tight',
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              TextSpan(
                                                text: _statusChuva == 'SECO'
                                                    ? AppLocalizations.of(context)!.limpo
                                                    : AppLocalizations.of(context)!.umido,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Inter',
                                                      color: _statusChuva == 'SECO'
                                                          ? Color(0xE639D258) // Verde
                                                          : Color(0xE6E12428), // Vermelho
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF1D2428),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.modoAutomatico,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.white,
                                      ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.controleClima,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: 'Inter',
                                        color: Color(0xFF95A1AC),
                                      ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _model.switchValue2!,
                              onChanged: (newValue) {
                                setState(() => _model.switchValue2 = newValue);
                                _publishJsonCommand(_topicSensorConfig, {"movJanelaAuto": newValue});
                              },
                              activeColor: FlutterFlowTheme.of(context).info,
                              activeTrackColor: FlutterFlowTheme.of(context).primary,
                              inactiveTrackColor: Color(0xFF98999A),
                              inactiveThumbColor: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional(0.04, -1.01),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(150.0, 20.0, 150.0, 300.0),
                  child: Text(
                    '${AppLocalizations.of(context)!.janela}\n',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(357.0, 22.0, 20.0, 80.0),
                child: InkWell(
                  onTap: () => context.pushNamed('cronojan'),
                  child: Icon(Icons.more_vert, color: Colors.white, size: 22.0),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 22.0, 300.0, 80.0),
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 26.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}