import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class PaymentWebviewRouteArgs {
  const PaymentWebviewRouteArgs({
    required this.paymentUrl,
    required this.ordNo,
  });

  final String paymentUrl;
  final String ordNo;
}

class PaymentWebviewPage extends StatefulWidget {
  const PaymentWebviewPage({
    required this.paymentUrl,
    required this.ordNo,
    super.key,
  });

  final String paymentUrl;
  final String ordNo;

  static const _resultPathSegment = '/premium/pricing/result';
  static const _mobileUserAgent =
      'TrendSoccer/1.0 (Mobile; Flutter) AppleWebKit/537.36 (KHTML, like Gecko)';

  @override
  State<PaymentWebviewPage> createState() => _PaymentWebviewPageState();
}

class _PaymentWebviewPageState extends State<PaymentWebviewPage> {
  late final WebViewController _controller;
  bool _loadFailed = false;
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(PaymentWebviewPage._mobileUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) => _handleUrl(change.url),
          onPageFinished: (url) => _handleUrl(url),
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _loadFailed = true);
          },
          onNavigationRequest: (request) {
            if (_tryCompleteFromUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _tryCompleteFromUrl(String? url) {
    if (_resultHandled || url == null || url.isEmpty) return false;
    if (!url.contains(PaymentWebviewPage._resultPathSegment)) return false;

    _resultHandled = true;
    final status = Uri.tryParse(url)?.queryParameters['status'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pop<String?>(status);
    });
    return true;
  }

  void _handleUrl(String? url) {
    _tryCompleteFromUrl(url);
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                '아니오',
                style: TsType.bodyMBold.copyWith(color: semantic.textDisabled),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                '예',
                style: TsType.bodyMBold.copyWith(color: semantic.interactivePrimary),
              ),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _cancelPayment() async {
    if (!await _confirmCancel() || !mounted) return;
    context.pop<String?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _cancelPayment();
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceBase,
        appBar: TsAppBar.preferred(
          context,
          location: TsAppBarLocation.backTitle,
          title: '결제',
          onBack: _cancelPayment,
        ),
        body: _loadFailed ? _buildErrorBody(semantic) : WebViewWidget(controller: _controller),
      ),
    );
  }

  Widget _buildErrorBody(TsSemanticColors semantic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '결제 페이지를 불러올 수 없습니다.',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.lg),
            TsButton(
              label: '닫기',
              variant: TsButtonVariant.primary,
              size: TsButtonSize.small,
              onPressed: () => context.pop<String?>(null),
            ),
          ],
        ),
      ),
    );
  }
}
