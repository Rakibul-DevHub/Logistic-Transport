import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tag/core/theme/app_colors.dart';

class WebViewCheckoutScreen extends StatefulWidget {
  final String url;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const WebViewCheckoutScreen({
    super.key,
    required this.url,
    this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<WebViewCheckoutScreen> createState() => _WebViewCheckoutScreenState();
}

class _WebViewCheckoutScreenState extends State<WebViewCheckoutScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;
  double _progress = 0;

  /// Once true, close should finish successfully (no cancel warning).
  bool _paymentCompleted = false;
  bool _handledResult = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _isError = false;
            });
            debugPrint('🔄 Page started loading: $url');
            _handleStripeRedirect(url);
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            debugPrint('✅ Page finished loading: $url');
            _handleStripeRedirect(url);
          },
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress / 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Ignore load errors after success redirect.
            if (_paymentCompleted) return;
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _isError = true;
              _errorMessage = error.description;
            });
            debugPrint('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation: ${request.url}');
            _handleStripeRedirect(request.url);
            // Allow success/cancel pages to load.
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            final url = change.url;
            if (url != null) {
              debugPrint('🔀 URL changed: $url');
              _handleStripeRedirect(url);
            }
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/billing/success') ||
        lower.contains('billing/success') ||
        lower.contains('payment-success') ||
        lower.contains('checkout-success') ||
        lower.contains('checkout/success') ||
        lower.contains('thank-you') ||
        (lower.contains('success') &&
            (lower.contains('billing') ||
                lower.contains('payment') ||
                lower.contains('checkout')));
  }

  bool _isCancelUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('/billing/cancel') ||
        lower.contains('billing/cancel') ||
        lower.contains('payment-cancel') ||
        lower.contains('checkout-cancel') ||
        lower.contains('checkout/cancel');
  }

  void _handleStripeRedirect(String url) {
    if (_handledResult) return;

    if (_isSuccessUrl(url)) {
      debugPrint('✅ Payment success detected!');
      _handledResult = true;
      _paymentCompleted = true;

      // Notify parent first (refresh using captured cubits).
      widget.onPaymentSuccess?.call();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _showSuccessDialog();
      });
      return;
    }

    if (_isCancelUrl(url)) {
      debugPrint('❌ Payment cancelled');
      _handledResult = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        widget.onPaymentCancel?.call();
        Navigator.pop(context);
      });
    }
  }

  void _onClosePressed() {
    if (_paymentCompleted) {
      Navigator.pop(context);
      return;
    }
    _showCloseConfirmation();
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Checkout'),
        content: const Text(
          'Payment is not completed yet. Are you sure you want to leave checkout?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              widget.onPaymentCancel?.call();
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your subscription has been activated successfully.',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _paymentCompleted,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onClosePressed();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: _onClosePressed,
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _isError = false;
                  _progress = 0;
                });
                _webViewController.reload();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.grey[200]),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading && _progress < 1)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primaryColor,
                  minHeight: 3,
                ),
              ),
            if (_isLoading && _progress < 0.5)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading checkout page...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ?? 'Failed to load checkout page',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[800],
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isError = false;
                                  _isLoading = true;
                                  _progress = 0;
                                });
                                _webViewController.reload();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
