// lib/feature/profile/view/subscription/view/webview_checkout_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ✅ Required for Stripe
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _isError = false;
            });
            debugPrint('🔄 Page started loading: $url');

            // ✅ Check for payment success/cancel
            _handleStripeRedirect(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('✅ Page finished loading: $url');

            // ✅ Inject JavaScript to detect Stripe events
            _injectStripeDetectionScript();
          },
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _isError = true;
              _errorMessage = error.description;
            });
            debugPrint('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation: ${request.url}');

            // ✅ Handle Stripe redirects
            if (_handleStripeRedirect(request.url)) {
              return NavigationDecision.prevent;
            }

            // ✅ Allow all other navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent( // ✅ Set user agent for better compatibility
          'Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36'
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // ✅ Handle Stripe redirects
  bool _handleStripeRedirect(String url) {
    // Check for success patterns
    if (url.contains('success') ||
        url.contains('payment-success') ||
        url.contains('checkout-success') ||
        url.contains('thank-you') ||
        url.contains('payment_intent') && url.contains('succeeded')) {
      debugPrint('✅ Payment success detected!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onPaymentSuccess?.call();
          _showSuccessDialog(context);
        }
      });
      return true;
    }

    // Check for cancel patterns
    if (url.contains('cancel') ||
        url.contains('payment-cancel') ||
        url.contains('checkout-cancel')) {
      debugPrint('❌ Payment cancelled');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onPaymentCancel?.call();
          Navigator.pop(context);
        }
      });
      return true;
    }

    return false;
  }

  // ✅ Inject JavaScript to detect payment completion
  void _injectStripeDetectionScript() {
    _webViewController.runJavaScript('''
      (function() {
        // Monitor URL changes
        let lastUrl = window.location.href;
        setInterval(function() {
          if (window.location.href !== lastUrl) {
            lastUrl = window.location.href;
            // Send message to Flutter
            window.flutter_inappwebview?.callHandler('urlChanged', lastUrl);
          }
        }, 500);
        
        // Detect Stripe success messages
        const observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.target.textContent && 
                (mutation.target.textContent.includes('success') || 
                 mutation.target.textContent.includes('Thank you') ||
                 mutation.target.textContent.includes('Payment successful'))) {
              // Send success message to Flutter
              window.flutter_inappwebview?.callHandler('paymentSuccess', '');
            }
          });
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          characterData: true
        });
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _webViewController),

          // ✅ Progress Bar (shows loading progress)
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

          // Loading Indicator
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

          // Error Widget
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.black87,
        ),
        onPressed: () => _showCloseConfirmation(context),
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
          icon: const Icon(
            Icons.refresh,
            color: Colors.black87,
          ),
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
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Checkout'),
        content: const Text('Are you sure you want to cancel the payment process?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close WebView
              widget.onPaymentCancel?.call();
            },
            child: const Text(
              'Cancel Payment',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your subscription has been activated successfully.',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close WebView
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
}