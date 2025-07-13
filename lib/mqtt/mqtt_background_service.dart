// lib/mqtt/mqtt_background_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart'; // Importe isso
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:auto_haus/notifications/notification_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();

  // Se o serviço for uma instância do Android, configure os listeners
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // A lógica MQTT permanece a mesma
  MqttServerClient? client;
  String? ultimoStatusChuva; 

  final String topicSensorEstado = "casa/erick/toldo_janela/sensor/estado";
  final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
  final int port = 8883;
  final String username = 'Erickkk';
  final String password = '96488941Ab';
  final String clientId = 'flutter_background_service_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> connectAndListen() async {
    client = MqttServerClient.withPort(url, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..secure = true
      ..securityContext = SecurityContext.defaultContext
      ..onConnected = () {
          debugPrint('[BackgroundMQTT] Conectado!');
          client?.subscribe(topicSensorEstado, MqttQos.atLeastOnce);
        }
      ..onDisconnected = () {
          debugPrint('[BackgroundMQTT] Desconectado.');
        };

    try {
      await client?.connect(username, password);
    } catch (e) {
      debugPrint('[BackgroundMQTT] ERRO ao conectar: ${e.toString()}');
    }

    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final Map<String, dynamic> jsonPayload = json.decode(payload);
        if (jsonPayload.containsKey('chuva')) {
          String statusAtual = jsonPayload['chuva'];

          if (statusAtual == 'MOLHADO' && ultimoStatusChuva != 'MOLHADO') {
            NotificationService.showNotification(
              title: 'Alerta de Chuva!',
              body: 'O sensor detectou umidade. Verifique seus dispositivos.',
            );
          }
          ultimoStatusChuva = statusAtual; 
        }
      } catch (e) {
        debugPrint('[BackgroundMQTT] Erro ao processar JSON: $e');
      }
    });
  }

  // Inicia a conexão MQTT
  await connectAndListen();
}