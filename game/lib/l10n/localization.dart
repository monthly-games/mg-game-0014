// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mg_common_game/l10n/extensions.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  const AppLocalizations();

  String get ui_general_battle_pass => 'Battle Pass';
  String get ui_general_tower_summon => 'Tower Summon';
  String get notification_claim_all__bpunclaimedrewardcount => 'Unclaimed Rewards';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return const AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}