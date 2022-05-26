import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({Key? key, required this.client}) : super(key: key);

  final MqttServerClient client;

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const Icon(Icons.linked_camera_sharp),
          title: const Text('WALL-E',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
          titleSpacing: 1.0,
          backgroundColor: Colors.greenAccent,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: 325.0,
                      child: WebView(
                        initialUrl: 'http://192.168.8.150/',
                        javascriptMode: JavascriptMode.unrestricted,
                        onProgress: (int progress) {
                          print('WebView is loading (progress : $progress%)');
                        },
                        navigationDelegate: (NavigationRequest request) {
                          if (request.url
                              .startsWith('https://www.youtube.com/')) {
                            print('blocking navigation to $request}');
                            return NavigationDecision.prevent;
                          }
                          print('allowing navigation to $request');
                          return NavigationDecision.navigate;
                        },
                        onPageStarted: (String url) {
                          print('Page started loading: $url');
                        },
                        onPageFinished: (String url) {
                          print('Page finished loading: $url');
                        },
                        gestureNavigationEnabled: true,
                        backgroundColor: const Color(0x00000000),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 50),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _forward(),
                          child: const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 100,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _left(),
                              child: const Icon(
                                Icons.keyboard_arrow_left_rounded,
                                size: 100,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _right(),
                              child: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                size: 100,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _back(),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(25),
                          child: RaisedButton(
                            child: const Text(
                              "OFFLINE",
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            onPressed: () => _offline(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(25),
                          child: RaisedButton(
                            child: const Text(
                              "STOP CAR",
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            onPressed: () => _stopCar(),
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
          ),
        ));
  }

  void _sendMessage(String message) {
    const pubTopic = 'flutter_client';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    widget.client
        .publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
  }

  void _back() {
    _sendMessage('2');
  }

  void _forward() {
    _sendMessage('1');
  }

  void _left() {
    _sendMessage('4');
  }

  void _right() {
    _sendMessage('3');
  }

  void _stopCar() {
    _sendMessage('0');
  }

  void _offline() {
    _sendMessage('5');
  }

  @override
  void dispose() {
    widget.client.disconnect();
    super.dispose();
  }
}
