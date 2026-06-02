import 'package:flutter/widgets.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

extension L10nHelper on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
