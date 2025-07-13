import '/mqtt/mqtt_service.dart';

class MotorCalls {
  /// Envia comando para Motor A avançar
  static Future<void> toldoFecharMqtt({
    required MQTTService mqtt,
  }) async {
    final topic = 'casa/erick/toldo_janela/toldo/cmd';
    mqtt.publish(topic, 'POS:100');
  }

  /// Envia comando para Motor A voltar
  static Future<void> toldoAbrirMqtt({
    required MQTTService mqtt,
  }) async {
    final topic = 'casa/erick/toldo_janela/toldo/cmd';
    mqtt.publish(topic, 'POS:0');
  }

  // Você pode adicionar outros comandos aqui...
}