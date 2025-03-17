import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotScreen extends StatelessWidget {
  final WebViewController webViewController;

  const ChatbotScreen({super.key, required this.webViewController});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: webViewController);
  }
}
