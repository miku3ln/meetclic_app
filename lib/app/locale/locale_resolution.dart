import 'package:flutter/material.dart';

Locale resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
  if (locale == null) return supportedLocales.first;

  if (locale.languageCode == 'qu') return const Locale('qu');

  for (final supported in supportedLocales) {
    if (supported.languageCode == locale.languageCode) return supported;
  }

  return supportedLocales.first;
}