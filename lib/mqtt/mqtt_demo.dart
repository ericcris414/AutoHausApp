import 'dart:async';
import 'dart:io'; // Required for exit() and stdin

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// The main entry point for the Dart application.
/// It initializes the MQTT client and handles the application's lifecycle.

Future<void> main() async {
  // Connect to the MQTT broker.
  final client = await connect();

  // Check if the client successfully connected.
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('MAIN:: Client connected. Subscribing to a topic...');
    
    // Example: Subscribe to a topic to receive messages.
    const topic = 'test/topic'; // Change to the topic you want to subscribe to.
    client.subscribe(topic, MqttQos.atLeastOnce);

    // Example: Publish a message to the topic.
    print('MAIN:: Publishing a test message...');
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from Dart MQTT Client!');
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    print('MAIN:: Setup complete. Listening for messages...');
    print('MAIN:: Press Enter to exit.');

    // Keep the application running to listen for messages.
    // In a command-line app, the script would exit without this.
    await stdin.first;

    // Disconnect when done.
    print('MAIN:: Disconnecting MQTT client...');
    client.disconnect();
  } else {
    print('MAIN:: MQTT client failed to connect. State: ${client.connectionStatus!.state}');
    exit(-1); // Exit with an error code if connection failed.
  }
}

/// Establishes a connection to the MQTT broker.
/// Returns a configured and connected [MqttClient] instance.
Future<MqttClient> connect() async {
  // Create a new MQTT client.
  // Using a unique client ID is crucial to avoid conflicts.
  final String clientId = 'clientId-Erick-${DateTime.now().millisecondsSinceEpoch}';
  MqttServerClient client = MqttServerClient.withPort(
      'ba383544cf1b4a0c93db9ddfe621858f.s1.eu.hivemq.cloud',
      clientId,
      8883);

  // --- Configuration ---
  client.logging(on: true);
  client.keepAlivePeriod = 60;
  client.secure = true; // Use a secure TLS connection.
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  // For HiveMQ Cloud, the library typically uses the system's trusted certificates.
  // You would only need a custom SecurityContext for client certificate authentication (mTLS).
  // client.securityContext = SecurityContext.defaultContext;

  // --- Connection Message ---
  final connMess = MqttConnectMessage()
      .authenticateAs("Erickkk", "96488941Ab") // IMPORTANT: Use secure methods to handle credentials.
      .withWillTopic('willtopic') // Topic for the "Last Will and Testament" message.
      .withWillMessage('My Will message') // Message sent on unexpected disconnect.
      .startClean() // Start a new session, clearing any previous session data.
      .withWillQos(MqttQos.atLeastOnce); // QoS for the will message.
  
  print('CONNECT:: MQTT client connecting....');
  client.connectionMessage = connMess;

  // --- Connection Attempt ---
  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    // Raised when connection fails.
    print('CONNECT:: Client exception - NoConnectionException: $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised when underlying socket errors occur.
    print('CONNECT:: Client exception - SocketException: $e');
    client.disconnect();
  } catch (e) {
    print('CONNECT:: Client exception: $e');
    client.disconnect();
  }

  // --- Post-Connection Check ---
  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    print('CONNECT:: ERROR: MQTT client connection failed - status is ${client.connectionStatus}');
    client.disconnect();
  } else {
     print('CONNECT:: MQTT client connected.');
  }

  // --- Message Listener ---
  // This stream listens for incoming published messages.
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c != null && c.isNotEmpty) {
      final recMessage = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      print('RECEIVED:: message: "$payload" from topic: ${c[0].topic}');
    }
  });

  return client;
}

// --- Callback Functions ---

/// Callback for when the client successfully connects.
void onConnected() {
  print('CALLBACK:: OnConnected client callback - Connected!');
}

/// Callback for when the client disconnects.
void onDisconnected() {
  print('CALLBACK:: OnDisconnected client callback - Disconnected!');
}

/// Callback for when a topic subscription is successful.
void onSubscribed(String topic) {
  print('CALLBACK:: Subscribed topic: $topic');
}

/// Callback for when a topic subscription fails.
void onSubscribeFail(String topic) {
  print('CALLBACK:: Failed to subscribe to $topic');
}

/// Callback for when a topic is successfully unsubscribed.
void onUnsubscribed(String? topic) {
  print('CALLBACK:: Unsubscribed topic: $topic');
}

/// Callback for receiving a PONG response from the broker.
void pong() {
  print('CALLBACK:: Ping response client callback invoked');
}
