import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlight.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

Future<void> showHighlightPlayerSheet(
  BuildContext context,
  FeedHighlight highlight,
) {
  final c = Theme.of(context).extension<TsThemeColors>()!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: c.scrim,
    isScrollControlled: false,
    useSafeArea: true,
    builder: (_) => _HighlightPlayerSheet(highlight: highlight),
  );
}

class _HighlightPlayerSheet extends StatefulWidget {
  const _HighlightPlayerSheet({required this.highlight});

  final FeedHighlight highlight;

  @override
  State<_HighlightPlayerSheet> createState() => _HighlightPlayerSheetState();
}

class _HighlightPlayerSheetState extends State<_HighlightPlayerSheet> {
  late final WebViewController _controller;
  var _loaded = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted || _failed) return;
            setState(() => _loaded = true);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame != true) return;
            if (!mounted) return;
            setState(() {
              _failed = true;
              _loaded = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.highlight.embedUrl));

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.canvas,
        borderRadius: TsRadius.topXl,
      ),
      padding: const EdgeInsets.all(TsSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: c.surfaceRaised,
              child: _failed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TsSpacing.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.highlightPlaybackFailedTitle,
                              style: TsType.h3.copyWith(color: c.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: TsSpacing.sm),
                            Text(
                              l10n.highlightPlaybackFailedBody,
                              style: TsType.bodyLRegular.copyWith(
                                color: c.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        WebViewWidget(controller: _controller),
                        if (!_loaded)
                          ColoredBox(
                            color: c.surfaceRaised,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: TsSpacing.md),
          Text(
            widget.highlight.titleLabel,
            style: TsType.bodyLBold.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
