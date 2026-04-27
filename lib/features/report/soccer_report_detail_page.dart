import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/report_models.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';
import '../../shared/widgets/report/editor_avatar.dart';
import '../../shared/widgets/report/league_logo_widget.dart';
import 'report_dummy_data.dart';

/// Full soccer report article with league branding and editor line.
class SoccerReportDetailPage extends StatefulWidget {
  const SoccerReportDetailPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<SoccerReportDetailPage> createState() => _SoccerReportDetailPageState();
}

class _SoccerReportDetailPageState extends State<SoccerReportDetailPage> {
  static final _dateFmt = DateFormat('MMM dd, yyyy', 'en_US');

  SoccerReport? _report;
  var _missingHandled = false;

  @override
  void initState() {
    super.initState();
    _report = _lookupReport(widget.id);
    if (_report == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleNotFound());
    }
  }

  SoccerReport? _lookupReport(String id) {
    for (final r in ReportDummyData.soccerReports) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> _handleNotFound() async {
    if (!mounted || _missingHandled) return;
    _missingHandled = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report not found')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Match Reports',
          centerTitle: true,
          onBackPressed: () => context.pop(),
        ),
      ),
      body: _report == null
          ? const SizedBox.shrink()
          : _ReportBody(
              report: _report!,
              dateFormat: _dateFmt,
            ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.dateFormat,
  });

  final SoccerReport report;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final hasThumb =
        report.thumbnailUrl.isNotEmpty && report.thumbnailUrl.trim().isNotEmpty;
    final paragraphs = report.content
        .split('\n\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 232,
              width: double.infinity,
              child: hasThumb
                  ? CachedNetworkImage(
                      imageUrl: report.thumbnailUrl.trim(),
                      height: 232,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const _ThumbPlaceholder(),
                      placeholder: (context, url) => const _ThumbPlaceholder(),
                    )
                  : const _ThumbPlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const EditorAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TrendSoccer',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Football Data Analyst',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: LeagueLogoWidget(leagueId: report.leagueId),
          ),
          const SizedBox(height: 16),
          Text(
            report.title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dateFormat.format(report.publishedAt),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          ..._buildParagraphs(paragraphs),
        ],
      ),
    );
  }

  List<Widget> _buildParagraphs(List<String> paragraphs) {
    if (paragraphs.isEmpty) {
      return [
        Text(
          report.content,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }
    final out = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      if (i > 0) {
        out.add(const SizedBox(height: 16));
      }
      out.add(
        Text(
          paragraphs[i],
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return out;
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainer,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 48,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
