import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:file_picker/file_picker.dart';

import '../../../formbricks_flutter.dart';

/// A widget that renders a Formbricks survey inside a WebView.
///
/// This widget is responsible for:
/// - Loading the HTML and JavaScript required to display the Formbricks survey.
/// - Communicating between Flutter and JavaScript (including file uploads).
/// - Handling survey lifecycle events such as completion or closure.
class SurveyWebview extends StatefulWidget {
  final FormbricksClient client;
  final Survey survey;
  final String userId;
  final String? language;
  final Map<String, dynamic> environmentData;
  final VoidCallback? onComplete;
  final String platform;

  const SurveyWebview({
    super.key,
    required this.client,
    required this.survey,
    required this.userId,
    this.language = 'default',
    required this.environmentData,
    required this.onComplete,
    required this.platform,
  });

  @override
  State<SurveyWebview> createState() => SurveyWebviewState();
}

class SurveyWebviewState extends State<SurveyWebview> {
  late WebViewController _webViewController;
  bool _isDismissing = false;
  final Completer<bool> _webViewLoaded = Completer<bool>();

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  /// Initializes and configures the WebView controller
  void _setupWebView() {
    _webViewController = WebViewController.fromPlatformCreationParams(
      PlatformWebViewControllerCreationParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (_) {},
          onPageStarted: (url) => debugPrint('WebView started: $url'),
          onHttpError: (error) => debugPrint('HTTP error: ${error.request} / ${error.response}'),
          onPageFinished: (_) {
            _webViewLoaded.complete(true);
            debugPrint('WebView finished loading.');
          },
          onWebResourceError: (error) => debugPrint('WebView error: ${error.description}'),
        ),
      )
      ..addJavaScriptChannel(
        'FormbricksJavascript',
        onMessageReceived: (message) => _handleJavaScriptMessage(message.message),
      );

    _loadSurveyHtml();
  }

  /// Loads the dynamically generated survey HTML into the WebView
  Future<void> _loadSurveyHtml() async {
    debugPrint("Loading survey HTML...");
    final htmlString = await _generateHtml();
    log("Survey HTML: $htmlString");
    _webViewController.loadHtmlString(htmlString);
  }

  /// Generates the HTML string that embeds the Formbricks survey
  Future<String> _generateHtml() async {
    final json = _getJson(widget.environmentData);
    final htmlTemplate = '''
<!doctype html>
<html>
  <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
  <head><title>Formbricks WebView Survey</title></head>
  <body style="overflow: hidden; height: 100vh; display: flex; flex-direction: column; justify-content: flex-end;">
    <div id="formbricks-${widget.platform}" style="width: 100%;"></div>
  </body>
  <script type="text/javascript">
    const json = {{WEBVIEW_DATA}};

    // JavaScript callbacks to notify Flutter
    function onClose() {
      FormbricksJavascript.postMessage(JSON.stringify({ event: "onClose" }));
    }
    function onDisplayCreated() {
      FormbricksJavascript.postMessage(JSON.stringify({ event: "onDisplayCreated" }));
    }
    function onResponseCreated() {
      FormbricksJavascript.postMessage(JSON.stringify({ event: "onResponseCreated" }));
    }

    // Hook for file uploads
    let setResponseFinished = null;
    function getSetIsResponseSendingFinished(callback) {
      setResponseFinished = callback;
    }

    function loadSurvey() {
      const options = json;
      const surveyProps = {
        ...options,
        getSetIsResponseSendingFinished,
        onDisplayCreated,
        onResponseCreated,
        onClose,
      };
      window.formbricksSurveys.renderSurvey(surveyProps);
    }

    // Override file picker inputs to use native Flutter file picker
    function attachFilePickerOverride() {
      const inputs = document.querySelectorAll('input[type="file"]');
      inputs.forEach(input => {
        if (!input.getAttribute('data-file-picker-overridden')) {
          input.setAttribute('data-file-picker-overridden', 'true');
          const allowedFileExtensions = input.getAttribute('data-accept-extensions');
          const allowMultipleFiles = input.getAttribute('data-accept-multiple');
          input.addEventListener('click', function (e) {
            e.preventDefault();
            FormbricksJavascript.postMessage(JSON.stringify({
              event: "onFilePick",
              fileUploadParams: {
                allowedFileExtensions: allowedFileExtensions,
                allowMultipleFiles: allowMultipleFiles === "true",
              }
            }));
          });
        }
      });
    }

    attachFilePickerOverride();

    // React to new elements added dynamically (e.g., more file inputs)
    const observer = new MutationObserver(function () {
      attachFilePickerOverride();
    });
    observer.observe(document.body, { childList: true, subtree: true });

    // Load Formbricks script dynamically
    const script = document.createElement("script");
    script.src = "${widget.client.appUrl}/js/surveys.umd.cjs";
    script.async = true;
    script.onload = () => loadSurvey();
    script.onerror = (error) => {
      FormbricksJavascript.postMessage(JSON.stringify({ event: "onSurveyLibraryLoadError" }));
      console.error("Failed to load Formbricks Surveys library:", error);
    };
    document.head.appendChild(script);
  </script>
</html>
''';
    return htmlTemplate.replaceAll('{{WEBVIEW_DATA}}', json);
  }

  /// Constructs the JSON configuration that is passed to the survey script
  String _getJson(Map<String, dynamic> environmentData) {
    final survey = environmentData['surveys'].firstWhere(
          (s) => s['id'] == widget.survey.id,
    );

    final styling = survey['styling'] != null && environmentData['project']['styling']['allowStyleOverwrite']
        ? survey['styling']
        : environmentData['project']['styling'];

    final jsonObject = {
      'survey': survey,
      'isBrandingEnabled': environmentData['project']['inAppSurveyBranding'],
      'appUrl': widget.client.appUrl,
      'environmentId': widget.client.environmentId,
      'contactId': widget.userId,
      'isWebEnvironment': false,
      'languageCode': survey['languages'].length > 1 ? widget.language : 'default',
      'styling': styling,
    };

    return jsonEncode(jsonObject).replaceAll('\\"', "'");
  }

  /// Handles messages sent from the WebView's JavaScript context
  void _handleJavaScriptMessage(String message) async {
    try {
      final data = jsonDecode(message);
      switch (data['event']) {
        case 'onClose':
          _safeDismiss();
          break;
        case 'onDisplayCreated':
          debugPrint('Display created for survey: ${widget.survey.id}');
          break;
        case 'onResponseCreated':
          debugPrint('Response created for survey: ${widget.survey.id}');
          break;
        case 'onFilePick':
          final params = data['fileUploadParams'];
          _pickFiles(
            params['allowedFileExtensions']?.split(','),
            params['allowMultipleFiles'] ?? false,
          );
          break;
        case 'onSurveyLibraryLoadError':
          debugPrint('Failed to load Formbricks Surveys library');
          _safeDismiss();
          break;
      }
    } catch (e) {
      debugPrint('Error handling JS message: $e');
    }
  }

  /// Triggers the native file picker and passes selected files to the WebView
  Future<void> _pickFiles(
      List<String>? allowedExtensions,
      bool allowMultiple,
      ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final files = result.files;
        final jsonArray = files.map((file) {
          final bytes = File(file.path!).readAsBytesSync();
          final base64 = base64Encode(bytes);
          final mimeType = file.extension != null
              ? 'application/${file.extension}'
              : 'application/octet-stream';
          return {
            'name': file.name,
            'type': mimeType,
            'base64': 'data:$mimeType;base64,$base64',
          };
        }).toList();

        final jsonString = jsonEncode(jsonArray);
        await _webViewController.runJavaScript(
          'window.formbricksSurveys.onFilePick($jsonString)',
        );
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  /// Safely dismisses the WebView and notifies listeners
  void _safeDismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    try {
      widget.onComplete?.call(); // Notify TriggerManager
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error dismissing WebView: $e');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: WebViewWidget(controller: _webViewController),
    );
  }
}
