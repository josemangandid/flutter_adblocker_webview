import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A webview implementation of in Flutter that blocks most of the ads that
/// appear inside of the webpages.
class AdBlockerWebview extends StatefulWidget {
  const AdBlockerWebview({
    required this.url,
    required this.adBlockerWebviewController,
    required this.shouldBlockAds,
    super.key,
    this.onLoadStart,
    this.onLoadFinished,
    this.onProgress,
    this.onLoadError,
    this.onLoadHttpError,
    this.onLoadResource,
    this.onTitleChanged,
    this.pullToRefreshController,
    this.onProgressChanged,
    this.onUpdateVisitedHistory,
    this.onConsoleMessage,
    this.shouldOverrideUrlLoading,
    this.onDownloadStartRequest,
    this.onLoadStop,
    this.initialOptions,
    this.options,
    this.onWebViewCreated,
    this.androidOnPermissionRequest,
  });

  /// Required: The initial [Uri] url that will be displayed in webview.
  final Uri url;

  /// Required: The controller for [AdBlockerWebview].
  /// See more at [AdBlockerWebviewController].
  final AdBlockerWebviewController adBlockerWebviewController;

  /// Required: Specifies whether to block or allow ads.
  final bool shouldBlockAds;

  /// Invoked when a page has started loading.
  final void Function(InAppWebViewController controller, Uri? uri)? onLoadStart;

  final Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  final void Function(InAppWebViewController controller, Uri? url,
      int statusCode, String description)? onLoadHttpError;

  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  final void Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
      onUpdateVisitedHistory;

  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  /// Invoked when a page has finished loading.
  final void Function(InAppWebViewController controller, Uri? uri)?
      onLoadFinished;

  /// Invoked when a page is loading to report the progress.
  final void Function(int progress)? onProgress;

  /// Invoked when the page title is changed.
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  final void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  final InAppWebViewGroupOptions? initialOptions;

  final PullToRefreshController? pullToRefreshController;

  final void Function(InAppWebViewController controller)? onWebViewCreated;

  final Future<PermissionRequestResponse?> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources)? androidOnPermissionRequest;

  /// Invoked when a loading error occurred.
  final void Function(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  )? onLoadError;

  /// Options for InAppWebView.
  final InAppWebViewGroupOptions? options;

  @override
  State<AdBlockerWebview> createState() => _AdBlockerWebviewState();
}

class _AdBlockerWebviewState extends State<AdBlockerWebview> {
  final _webViewKey = GlobalKey();
  InAppWebViewGroupOptions? _inAppWebViewOptions;

  @override
  void initState() {
    super.initState();
    _inAppWebViewOptions = widget.options ??
        InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        );

    if (widget.shouldBlockAds) {
      _setContentBlockers();
    }
  }

  void _setContentBlockers() {
    final contentBlockerList = widget.adBlockerWebviewController.bannedHost
        .map(
          (e) => ContentBlocker(
            trigger: ContentBlockerTrigger(
              urlFilter: _createUrlFilterFromAuthority(e.authority),
            ),
            action: ContentBlockerAction(
              type: ContentBlockerActionType.BLOCK,
            ),
          ),
        )
        .toList();

    _inAppWebViewOptions?.crossPlatform.contentBlockers = contentBlockerList;
  }

  String _createUrlFilterFromAuthority(String authority) => '.*.$authority/.*';

  void _clearContentBlockers() =>
      _inAppWebViewOptions?.crossPlatform.contentBlockers = [];

  @override
  void didUpdateWidget(AdBlockerWebview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldBlockAds) {
      _setContentBlockers();
    } else {
      _clearContentBlockers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      onWebViewCreated: widget.adBlockerWebviewController.setInternalController,
      initialUrlRequest: URLRequest(url: widget.url),
      initialOptions: _inAppWebViewOptions,
      onLoadStart: widget.onLoadStart,
      onLoadStop: widget.onLoadFinished,
      onLoadError: widget.onLoadError,
      onTitleChanged: widget.onTitleChanged,
      shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
      onDownloadStartRequest: widget.onDownloadStartRequest,
      onLoadHttpError: widget.onLoadHttpError,
      onLoadResource: widget.onLoadResource,
      onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
      onConsoleMessage: widget.onConsoleMessage,
      pullToRefreshController: widget.pullToRefreshController,
      androidOnPermissionRequest: widget.androidOnPermissionRequest,
    );
  }
}
