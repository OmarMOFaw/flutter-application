import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'modules/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  initializeNotification();
  final client = await mqttServer();
  runApp(MyApp(
    client: client,
  ));
}

class MyApp extends StatelessWidget {
  final MqttServerClient client;

  const MyApp({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewExample(
        client: client,
      ),
    );
  }
}

Future<MqttServerClient> mqttServer() async {
  final client = MqttServerClient.withPort('broker.emqx.io', 'flutter', 1883);
  int pongCount = 0; // Pong counter
  client.logging(on: true);

  final connMsg = MqttConnectMessage()
      .withClientIdentifier('flutter')
      //
      // .withWillTopic('willtopic')
      // .withWillMessage('Will message')
      .startClean()
      .withWillQos(MqttQos.atMostOnce);
  client.connectionMessage = connMsg;

  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
  }

  /// Ok, lets try a subscription
  print('EXAMPLE::Subscribing to the test/lol topic');
  const topic2 = 'flutter'; // Not a wildcard topic
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.subscribe(topic2, MqttQos.atMostOnce);
  }

  const topic = 'flutter_client'; // Not a wildcard topic
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    final builder = MqttClientPayloadBuilder();
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
    if (payload == '1') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 1,
              channelKey: 'basic_channel',
              title: 'Warning',
              body: 'Check application'));
      print('check app:$payload from topic: ${c[0].topic}> ');
    }
  });

  return client;
}

void initializeNotification() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          criticalAlerts: true,
          importance: NotificationImportance.Max,
          playSound: true,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupkey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        )
      ],
      debug: true);

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}
