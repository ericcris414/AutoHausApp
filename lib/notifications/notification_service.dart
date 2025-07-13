// lib/notifications/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    // MUDANÇA 1: Usar o novo ícone pequeno para a barra de status.
    // O nome deve ser exatamente o mesmo do arquivo, sem a extensão .png.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_logo');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // MUDANÇA 2: Definir o novo ícone grande para a notificação expandida.
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rain_channel_id',
      'Notificações de Chuva',
      channelDescription: 'Canal para notificações de detecção de chuva',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      // Adiciona o ícone grande que aparece quando a notificação é expandida.
      // O nome deve ser exatamente o mesmo do arquivo, sem a extensão .png.
      
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}