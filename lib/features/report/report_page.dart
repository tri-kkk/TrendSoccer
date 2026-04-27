import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/report_models.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../shared/widgets/appbar/app_bar_home.dart';
import '../../shared/widgets/cards/report_card.dart';
import '../../shared/widgets/section/section_header.dart';
import 'report_dummy_data.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  static final _dateFmt = DateFormat('MM.dd', 'en_US');

  Future<void> _openNewsUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width - 32;
    final soccer = ReportDummyData.soccerReports.take(4).toList();
    final baseball = ReportDummyData.baseballNews.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarHome(state: AppBarState.guest),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSoccerSection(
                      context,
                      soccer,
                      cardWidth,
                    ),
                    const SizedBox(height: 16),
                    _buildBaseballSection(
                      context,
                      baseball,
                      cardWidth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoccerSection(
    BuildContext context,
    List<SoccerReport> items,
    double cardWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Soccer Reports',
          type: SectionHeaderType.withAction,
          onSeeAllTap: () => context.push('/report/soccer'),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _soccerCard(context, items[i], cardWidth),
        ],
      ],
    );
  }

  Widget _buildBaseballSection(
    BuildContext context,
    List<BaseballNews> items,
    double cardWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Baseball News'),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _baseballCard(context, items[i], cardWidth),
        ],
      ],
    );
  }

  Widget _soccerCard(
    BuildContext context,
    SoccerReport r,
    double cardWidth,
  ) {
    return ReportCard(
      size: ReportCardSize.large,
      width: cardWidth,
      title: r.title,
      date: _dateFmt.format(r.publishedAt),
      description: r.author,
      thumbnailUrl: r.thumbnailUrl,
      onTap: () => context.push('/report/soccer/${r.id}'),
    );
  }

  Widget _baseballCard(
    BuildContext context,
    BaseballNews n,
    double cardWidth,
  ) {
    return ReportCard(
      size: ReportCardSize.large,
      width: cardWidth,
      title: n.title,
      date: _dateFmt.format(n.publishedAt),
      description: n.source,
      thumbnailUrl: n.thumbnailUrl,
      onTap: () => _openNewsUrl(n.url),
    );
  }
}
