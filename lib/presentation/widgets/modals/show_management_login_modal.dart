import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/widgets/atoms/intro_logo.dart';
import 'package:meetclic_app/presentation/widgets/atoms/social_icon.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/themes/app_spacing.dart';

void showManagementLoginModal(
  BuildContext context,

  Map<String, VoidCallback> actions,
) {
  final onTapGoogle = actions['google'];
  final onTapFacebook = actions['facebook'];
  final onTapLogin = actions['login'];
  final onTapSignUp = actions['signup'];
  final allowLoginSocialNetwork = false;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context); // 👈 Extrae el theme
      final appLocalizations = AppLocalizations.of(context);
      var containerCurrent = Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary, // 👈 Usa el theme
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntroLogo(assetPath: AppImages.pageLoginInit, height: 250),
            AppSpacing.spaceBetweenInputs,
            Text(
              appLocalizations.translate('loginManagerTitle.hi'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ), // 👈 Usa el textTheme
            ),
            AppSpacing.spaceBetweenInputs,

            Text(
              appLocalizations.translate('loginManagerTitle.welcome'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ), // 👈 Usa bodyMedium y onSurface
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: onTapLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // 👈 Usa primary
                  foregroundColor: theme.colorScheme.onPrimary, // 👈 Texto
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  appLocalizations.translate('loginManagerTitle.singInButton'),
                ),
              ),
            ),
            AppSpacing.spaceBetweenButtons,

            // Botón SIGN UP
            SizedBox(
              width: double.infinity,
              height: 70,
              child: OutlinedButton(
                onPressed: onTapSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary, // 👈 Texto
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                  ), // 👈 Borde
                ),
                child: Text(
                  appLocalizations.translate('loginManagerTitle.singUpButton'),
                ),
              ),
            ),

            if (allowLoginSocialNetwork) ...[
              AppSpacing.spaceBetweenButtons,
              Text(
                appLocalizations.translate('loginManagerTitle.loginInNetwork'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIcon(FontAwesomeIcons.google, onTap: onTapGoogle!),
                  const SizedBox(width: 16),
                  SocialIcon(FontAwesomeIcons.facebookF, onTap: onTapFacebook!),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ],
        ),
      );
      return Center(child: containerCurrent);
    },
  );
}
