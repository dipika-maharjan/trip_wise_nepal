import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EsewaWebViewPage extends StatefulWidget {
  final String formAction;
  final Map<String, String> fields;

  const EsewaWebViewPage({
    super.key,
    required this.formAction,
    required this.fields,
  });

  @override
  State<EsewaWebViewPage> createState() => _EsewaWebViewPageState();
}

class _EsewaWebViewPageState extends State<EsewaWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _loading = true);
          },
          onPageFinished: (url) {
            setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            // Use success/failure URLs from fields if present
            final successUrl = widget.fields['success_url'] ?? '';
            final failureUrl = widget.fields['failure_url'] ?? '';
            if (successUrl.isNotEmpty && request.url.startsWith(successUrl)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (failureUrl.isNotEmpty && request.url.startsWith(failureUrl)) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) => _postEsewaForm());
  }

  void _postEsewaForm() async {
    final html = '''
      <html>
        <body onload="document.forms[0].submit()">
          <form id="esewaPay" method="POST" action="${widget.formAction}">
            ${widget.fields.entries.map((e) => '<input type="hidden" name="${e.key}" value="${e.value}" />').join()}
          </form>
        </body>
      </html>
    ''';
    await _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eSewa Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
