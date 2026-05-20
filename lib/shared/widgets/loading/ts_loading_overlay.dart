import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';

class TsLoadingOverlay extends StatelessWidget {
  const TsLoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
    super.key,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: child,
        ),
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: TsType.bodyLRegular.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
