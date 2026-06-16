import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      appBar: AppBar(
        title: Text(
          l10n.menuAbout,
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        backgroundColor: semantic.surfaceRaised,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              TsAssets.logoSymbol(Theme.of(context).brightness),
              width: 68,
              height: 120,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.menuAbout,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appName,
              style: TsType.displayHero.copyWith(color: semantic.interactivePrimary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutTagline,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDescription,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              l10n.aboutFeaturesSection,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              semantic,
              l10n.aboutFeatureAiTitle,
              l10n.aboutFeatureAiDesc,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              semantic,
              l10n.aboutFeatureOddsTitle,
              l10n.aboutFeatureOddsDesc,
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              semantic,
              l10n.aboutFeatureLeaguesTitle,
              l10n.aboutFeatureLeaguesDesc,
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              l10n.aboutVisionSection,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutVisionText,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              l10n.aboutContactSection,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.mail_outline, size: 24, color: semantic.textSecondary),
                const SizedBox(width: 16),
                Text(
                  l10n.aboutContactEmail,
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SvgPicture.asset(
                  TsAssets.iconLanguage,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    semantic.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.aboutContactWebsite,
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(TsSemanticColors semantic, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              TsAssets.iconCheckboxChecked,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                semantic.interactivePrimary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
        ),
      ],
    );
  }
}
