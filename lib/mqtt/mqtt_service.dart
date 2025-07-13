import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class MQTTService {
  late MqttServerClient client;
  final String broker = 'ba383544cf1b4a0c93db9ddfe621858f.s1.eu.hivemq.cloud';
  final String clientId;
  final String username = 'Erickkk';
  final String password = '96488941Ab';

  MQTTService({required this.clientId}) {
    client = MqttServerClient.withPort(broker, clientId, 8884);
    client.secure = true;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = onPong;
    client.useWebSocket = true;
    client.websocketProtocols = ['mqtt']; // ou deixe padrão
    client.secure = true;

    /// TLS/SSL
    client.useWebSocket = true;
    client.websocketProtocols = ['mqtt'];

    /// Security context
    client.securityContext = SecurityContext.defaultContext;
  }

  /// Conectar no Broker
  Future<void> connect() async {
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
  await client.connect().timeout(Duration(seconds: 10));
} on TimeoutException {
  print('Conexão MQTT demorou demais e foi cancelada');
  disconnect();
}

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      print('Falha na conexão - status: ${client.connectionStatus}');
      disconnect();
    } else {
      print('Conectado ao broker MQTT!');
    }
  }

  /// Publicar mensagem
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Publicado no tópico $topic: $message');
  }

  /// Inscrever-se e receber mensagens
  Stream<String> subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);

    return client.updates!.map((c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Recebido no tópico $topic: $pt');
      return pt;
    });
  }

  /// Desconectar
  void disconnect() {
    client.disconnect();
    print('Desconectado do MQTT');
  }

  /// Callbacks
  void onSubscribed(String topic) {
    print('Inscrito no tópico: $topic');
  }

  void onDisconnected() {
    print('Desconectado do broker');
  }

  void onConnected() {
    print('Conectado com sucesso!');
  }

  void onPong() {
    print('Ping recebido');
  }
}
