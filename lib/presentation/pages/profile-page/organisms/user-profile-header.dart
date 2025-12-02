import 'package:flutter/material.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/pages/profile-page/atoms/avatar_image.dart';
import 'package:meetclic_app/presentation/pages/profile-page/molecules/counter-info-item.dart';
import 'package:meetclic_app/presentation/pages/profile-page/molecules/counter-reward-earned.dart';
import 'package:meetclic_app/presentation/pages/profile-page/molecules/user-info-block.dart';
import 'package:meetclic_app/presentation/widgets/atoms/title_widget.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../../../../shared/providers_session.dart';

class UserProfileHeader extends StatelessWidget {
  final SessionService session;
  const UserProfileHeader({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = Provider.of<SessionService>(
      context,
    ); // ✅ Reactivo: escucha cambios
    var userData = session.currentSession;
    final appLocalizations = AppLocalizations.of(context);
    var gradient = LinearGradient(
      colors: [Color(0xFF4C4CFF), Color(0xFF5C5CFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Column(
      children: [
        AvatarCard(
          width: double.infinity,
          height: 350,

          // backgroundColor: Colors.green,
          image: const AssetImage(
            AppImages.pageProfileAvatar,
          ), // Usa tu imagen local o NetworkImage
          onSettingsTap: () async {
            await session.clearSession();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuración disponible próximamente'),
              ),
            );
          },
        ),
        SizedBox(height: 12),
        UserInfoBlock(),
        SizedBox(height: 12),
        TitleWidget(
          title: 'Conexión',
          textAlign: TextAlign.left,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
        CounterInfoRow(
          items: [
            CounterInfoItem(
              count: 3,
              imageAsset: AppImages.pageLoginInit,
              label: appLocalizations.translate('profileDataTitle.business'),
              lineColor: theme.colorScheme.primary,
            ),
            CounterInfoItem(
              count: 6,
              imageAsset: AppImages.pageProfileFollowing,
              label: appLocalizations.translate('profileDataTitle.following'),
              lineColor: theme.colorScheme.primary,
            ),

            CounterInfoItem(
              count: 11,
              imageAsset: AppImages.pageProfileFollowers,
              label: appLocalizations.translate('profileDataTitle.followers'),
              lineColor: theme.colorScheme.primary,
            ),
          ],
        ),
        SizedBox(height: 12),
        TitleWidget(
          title: appLocalizations.translate('gamingDataTitle.rewardsWonCount'),
          textAlign: TextAlign.left,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
        RewardsGrid(
          items: [
            CounterRewardEarned(
              count: 5699,
              imageAsset: AppImages.rewardTypeReputation,
              label: 'Total Reputación',
              lineColor: Colors.yellow,
              onTap: () => print('Total XP tapped'),
            ),
            CounterRewardEarned(
              count: 120,
              imageAsset: AppImages.coinTypeYapitas,
              label: 'Yapitas',
              lineColor: Colors.orange,
              onTap: () => print('Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 450,
              imageAsset: AppImages.coinTypeYapitasPremium,
              label: 'Suma Yapitas',
              lineColor: Colors.purple,
              onTap: () => print('Suma Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 5,
              imageAsset: AppImages.rewardTypeTrophy,
              label: 'Trofeos',
              lineColor: Colors.amber,
              onTap: () => print('Trofeos tapped'),
            ),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
