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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'desenvolvedor_model.dart';
export 'desenvolvedor_model.dart';

class DesenvolvedorWidget extends StatefulWidget {
  const DesenvolvedorWidget({super.key});

  static String routeName = 'Desenvolvedor';
  static String routePath = '/desenvolvedor';

  @override
  State<DesenvolvedorWidget> createState() => _DesenvolvedorWidgetState();
}

class _DesenvolvedorWidgetState extends State<DesenvolvedorWidget> {
  late DesenvolvedorModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // --- Variáveis de Estado para MQTT ---
  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;
  Timer? _reconnectTimer; // Timer para tentar reconectar
  bool _isConnecting = false; // Flag para evitar múltiplas tentativas de conexão

  // --- Tópicos MQTT ---
  final String _topicBase = "casa/erick/toldo_janela";
  // O tópico _topicPararTodosMotores não será mais usado diretamente nos botões de pulso
  // mas é mantido aqui caso você queira um botão de "parar tudo" separado no futuro.
  late final String _topicPararTodosMotores; // Mantido, mas não usado nos botões de pulso
  late final String _topicMotorToldoAFwd;
  late final String _topicMotorToldoABwd;
  late final String _topicMotorToldoBFwd;
  late final String _topicMotorToldoBBwd;
  late final String _topicMotorJanelaFwd;
  late final String _topicMotorJanelaBwd;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DesenvolvedorModel());

    // Inicializa os tópicos MQTT
    _topicPararTodosMotores = '$_topicBase/parar_todos';
    _topicMotorToldoAFwd = '$_topicBase/motor/toldoA/fwd';
    _topicMotorToldoABwd = '$_topicBase/motor/toldoA/bwd';
    _topicMotorToldoBFwd = '$_topicBase/motor/toldoB/fwd';
    _topicMotorToldoBBwd = '$_topicBase/motor/toldoB/bwd';
    _topicMotorJanelaFwd = '$_topicBase/motor/janela/fwd';
    _topicMotorJanelaBwd = '$_topicBase/motor/janela/bwd';

    // Conecta ao MQTT ao iniciar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _model.dispose();
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[MQTT Desenvolvedor] $message');
  }

  Future<void> _connect() async {
    if (_isConnecting || _client?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    _isConnecting = true;
    _log('Iniciando conexão MQTT...');

    final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
    final int port = 8883;
    final String username = 'Erickkk';
    final String password = '96488941Ab';
    final String clientId = 'flutter_desenvolvedor_ui_${DateTime.now().millisecondsSinceEpoch}';

    _log('Tentando conexão com $url:$port...');
    _client = MqttServerClient.withPort(url, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 30 // Mantenha a conexão viva
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected // Garante que a reconexão seja acionada
      ..onSubscribed = (topic) => _log('Inscrito no tópico: $topic'); // Para debug de subscrições

    _client!.secure = true;
    _client!.securityContext = SecurityContext.defaultContext;
    _client!.connectionMessage = MqttConnectMessage().withClientIdentifier(clientId).startClean();

    try {
      await _client!.connect(username, password);
    } catch (e) {
      _log('ERRO ao conectar: ${e.toString()}');
      _disconnect(); // Tenta desconectar e acionar o _onDisconnected para a reconexão
    } finally {
      _isConnecting = false;
    }
  }

  void _onConnected() {
    _log('Conexão MQTT estabelecida!');
    // Cancelar qualquer timer de reconexão pendente
    _reconnectTimer?.cancel();
    _isConnecting = false; // Resetar flag de conexão

    if (!mounted) return;

    // Se você precisar se inscrever em tópicos para receber feedback do ESP32, faça aqui.
    // Por exemplo, se o ESP32 publicasse um status de motor após o pulso.
    // Como seu ESP32 não envia status de volta para esses comandos de pulso individuais,
    // o listener de updates não é estritamente necessário para esta funcionalidade.
    // Mantido para debug, se houver necessidade futura de processar mensagens recebidas.
    _updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;
      _log('Mensagem recebida no tópico [$topic]: "$payload"');
      // Lógica para processar respostas do ESP32, se houver
    });
  }

  void _onDisconnected() {
    _log('Desconectado do MQTT. Tentando reconectar em 5 segundos...');
    if (!mounted) return;

    // Iniciar um timer para tentar reconectar após um atraso
    // Isso é mais robusto do que apenas chamar _connect diretamente, pois evita loops rápidos
    _reconnectTimer?.cancel(); // Cancela qualquer timer anterior
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connect();
    });
  }

  void _disconnect() {
    _log('Desconectando do MQTT...');
    _client?.disconnect();
    _reconnectTimer?.cancel();
    _isConnecting = false;
  }

  void _publishCommand(String topic, String message) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      _log('Não conectado, impossível publicar. Estado: ${_client?.connectionStatus?.state}');
      // Tentar reconectar imediatamente se não estiver conectado
      if (!_isConnecting) {
        _connect();
      }
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _log('Publicado no tópico [$topic]: "$message"');
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
                                  0.0, 18.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.controleMotores,
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
                          // MOTOR A DIANTEIRO TOLDO
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 85.0, 0.0, 10.0),
                            child: Text(AppLocalizations.of(context)!.motorADianteiroToldo,
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Color(0xFFFFF8F8),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          // Botão FRENTE (Motor A Dianteiro Toldo)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 130.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorToldoAFwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel para confiar no pulso de 300ms do ESP32
                              child: FFButtonWidget(
                                onPressed: () {}, // Desativa o onPressed padrão
                                text: AppLocalizations.of(context)!.frente,
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
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
                          // Botão TRAS (Motor A Dianteiro Toldo)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                230.0, 130.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorToldoABwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel
                              child: FFButtonWidget(
                                onPressed: () {}, // Desativa o onPressed padrão
                                text: AppLocalizations.of(context)!.tras,
                                icon: Icon(
                                  Icons.arrow_downward_sharp,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFF14181B),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
                                        fontSize: 16.0,
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

                          // MOTOR B TRASEIRO TOLDO
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 215.0, 0.0, 10.0),
                            child: Text(AppLocalizations.of(context)!.motorBTraseiroToldo,
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Color(0xFFFFF8F8),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          // Botão FRENTE (Motor B Traseiro Toldo)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 260.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorToldoBFwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel
                              child: FFButtonWidget(
                                onPressed: () {}, // Desativa o onPressed padrão
                                text: AppLocalizations.of(context)!.frente,
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
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
                          // Botão TRAS (Motor B Traseiro Toldo)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                230.0, 260.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorToldoBBwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel
                              child: FFButtonWidget(
                                onPressed: () {}, // Desativa o onPressed padrão
                                text: AppLocalizations.of(context)!.tras,
                                icon: Icon(
                                  Icons.arrow_downward_sharp,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFF14181B),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
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

                          // MOTOR JANELA
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 345.0, 0.0, 10.0),
                            child: Text(AppLocalizations.of(context)!.motorJanela,
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Color(0xFFFFF8F8),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          // Botão ABRIR (Motor Janela) - Correspondente ao 'fwd' no ESP32
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 390.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorJanelaFwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel
                              child: FFButtonWidget(
                                onPressed: () {},
                                text: AppLocalizations.of(context)!.abrirA,
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
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
                          // Botão FECHAR (Motor Janela) - Correspondente ao 'bwd' no ESP32
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                230.0, 390.0, 30.0, 10.0),
                            child: GestureDetector(
                              onTapDown: (_) async {
                                _publishCommand(_topicMotorJanelaBwd, "0"); // Envia "0"
                              },
                              // Removido onTapUp e onTapCancel
                              child: FFButtonWidget(
                                onPressed: () {},
                                text: AppLocalizations.of(context)!.fecharA,
                                icon: Icon(
                                  Icons.arrow_downward_sharp,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                options: FFButtonOptions(
                                  width: 140.0,
                                  height: 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFF14181B),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context).info,
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

                          // Botão PARAR TODOS OS MOTORES (ainda útil como um botão de emergência geral)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                119.0, 496.0, 119.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                _publishCommand(_topicPararTodosMotores, "PARAR");
                              },
                              text: AppLocalizations.of(context)!.pararMotores,
                              icon: Icon(
                                Icons.stop_circle,
                                size: 16.0,
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
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
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