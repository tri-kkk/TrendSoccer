import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class ReportListSkeleton extends StatelessWidget {
  const ReportListSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).extension<TsSemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? sem.surfaceBase : sem.surfaceContainer,
      highlightColor: isDark ? sem.surfaceContainer : sem.surfaceOverlay,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
        itemBuilder: (context, index) => _SkeletonCard(sem: sem),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.sem});

  final TsSemanticColors sem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: sem.surfaceBase,
        borderRadius: BorderRadius.circular(TsSpacing.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: sem.surfaceContainer,
              borderRadius: BorderRadius.circular(TsSpacing.sm),
            ),
          ),
          const SizedBox(width: TsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: sem.surfaceContainer,
                ),
                const SizedBox(height: TsSpacing.sm),
                Container(
                  height: 14,
                  width: 120,
                  color: sem.surfaceContainer,
                ),
                const SizedBox(height: TsSpacing.md),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: sem.surfaceContainer,
                ),
                const SizedBox(height: TsSpacing.xs),
                Container(
                  height: 12,
                  width: 80,
                  color: sem.surfaceContainer,
                ),
                const SizedBox(height: TsSpacing.sm),
                Container(
                  height: 10,
                  width: 60,
                  color: sem.surfaceContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
