import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class PaymentWebviewRouteArgs {
  const PaymentWebviewRouteArgs({required this.formData});

  final Map<String, dynamic> formData;
}

class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({required this.formData, super.key});

  final Map<String, dynamic> formData;

  static const defaultGatewayUrl = 'https://pay.seedpayments.co.kr/payment';

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  bool _isLoading = true;
  bool _resultHandled = false;

  static const _gatewayCandidateKeys = [
    'payUrl',
    'actionUrl',
    'gatewayUrl',
    'paymentUrl',
    'requestUrl',
    'submitUrl',
    'pay_url',
  ];

  static const _sensitiveFormKeys = {
    'hashString',
    'hash',
    'sign',
    'signature',
  };

  String get _gatewayUrl {
    final data = widget.formData;
    for (final key in ['payUrl', 'actionUrl', 'gatewayUrl', 'pay_url']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return PaymentWebViewPage.defaultGatewayUrl;
  }

  String? get _returnUrlHint {
    final value = widget.formData['returnUrl'] ?? widget.formData['return_url'];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  String _htmlEscape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  String _maskFormValue(String key, dynamic value) {
    if (value == null) return 'null';
    final str = value.toString();
    final lowerKey = key.toLowerCase();
    final isSensitive = _sensitiveFormKeys.contains(key) ||
        lowerKey.contains('hash') ||
        lowerKey.contains('sign');
    if (!isSensitive) return str;
    if (str.length <= 10) return str;
    return '${str.substring(0, 10)}...';
  }

  void _logPaymentDiagnostics() {
    final formData = widget.formData;
    final gatewayUrl = _gatewayUrl;

    final maskedFormData = {
      for (final entry in formData.entries)
        entry.key: _maskFormValue(entry.key, entry.value),
    };
    print('[PAYMENT] formData: $maskedFormData');
    print('[PAYMENT] Gateway URL being used: $gatewayUrl');
    print('[PAYMENT] returnUrl: ${formData['returnUrl']}');

    for (final key in _gatewayCandidateKeys) {
      if (formData.containsKey(key)) {
        print('[PAYMENT] formData gateway candidate "$key": ${formData[key]}');
      }
    }

    final returnUrlAlt = formData['return_url'];
    if (returnUrlAlt != null) {
      print('[PAYMENT] return_url: $returnUrlAlt');
    }
  }

  String _buildPaymentHtml() {
    const gatewayKeys = {'payUrl', 'actionUrl', 'gatewayUrl', 'pay_url'};
    final inputs = widget.formData.entries
        .where((entry) => !gatewayKeys.contains(entry.key))
        .where((entry) => entry.value != null)
        .map((entry) {
          final name = _htmlEscape(entry.key);
          final value = _htmlEscape(entry.value.toString());
          return '<input type="hidden" name="$name" value="$value" />';
        })
        .join('\n');

    final gateway = _htmlEscape(_gatewayUrl);
    return '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8" /></head>
<body onload="document.getElementById('payForm').submit();">
<form id="payForm" method="POST" action="$gateway">
$inputs
</form>
</body>
</html>''';
  }

  void _complete(bool success) {
    if (_resultHandled || !mounted) return;
    _resultHandled = true;
    context.pop<bool>(success);
  }

  bool _evaluatePaymentUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();

    if (lower.contains('fail') ||
        lower.contains('cancel') ||
        lower.contains('error')) {
      _complete(false);
      return true;
    }

    final returnHint = _returnUrlHint;
    if (returnHint != null && lower.contains(returnHint.toLowerCase())) {
      _complete(true);
      return true;
    }

    if (lower.contains('trendsoccer.com') ||
        lower.contains('result') ||
        lower.contains('complete') ||
        lower.contains('success')) {
      _complete(true);
      return true;
    }

    return false;
  }

  Future<bool> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final semantic = Theme.of(dialogContext).extension<TsSemanticColors>()!;
        return AlertDialog(
          backgroundColor: semantic.surfaceOverlay,
          title: Text(
            '결제 취소',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          content: Text(
            '결제를 취소하시겠습니까?',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TsButton(
                    label: '아니오',
                    variant: TsButtonVariant.secondary,
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TsButton(
                    label: '예',
                    variant: TsButtonVariant.primary,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _onBackPressed() async {
    if (!await _confirmCancel() || !mounted) return;
    _complete(false);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    _logPaymentDiagnostics();
    final gatewayUrl = _gatewayUrl;
    final html = _buildPaymentHtml();
    print('[PAYMENT] HTML form action: $gatewayUrl');
    print('[PAYMENT] HTML length: ${html.length}');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceBase,
        appBar: AppBar(
          backgroundColor: semantic.surfaceBase,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
            onPressed: _onBackPressed,
          ),
          title: Text(
            '결제',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useWideViewPort: true,
              ),
              initialData: InAppWebViewInitialData(
                data: html,
                mimeType: 'text/html',
                encoding: 'utf-8',
                baseUrl: WebUri(_gatewayUrl),
              ),
              onLoadStart: (controller, url) {
                if (!mounted) return;
                setState(() => _isLoading = true);
                _evaluatePaymentUrl(url?.toString());
              },
              onLoadStop: (controller, url) async {
                if (!mounted) return;
                setState(() => _isLoading = false);
                _evaluatePaymentUrl(url?.toString());
              },
              onReceivedError: (controller, request, error) {
                if (!mounted) return;
                setState(() => _isLoading = false);
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final url = action.request.url?.toString();
                if (_evaluatePaymentUrl(url)) {
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
