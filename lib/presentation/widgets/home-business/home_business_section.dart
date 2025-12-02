import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/business_data.dart';
import 'package:meetclic_app/domain/models/business_day.dart';
import 'package:meetclic_app/domain/models/business_model.dart';
import 'package:meetclic_app/domain/models/day_schedule.dart';
import 'package:meetclic_app/domain/models/social_network.dart';
import 'package:meetclic_app/domain/usecases/get_nearby_businesses_usecase.dart';
import 'package:meetclic_app/infrastructure/repositories/implementations/business_repository_impl.dart';
import 'package:meetclic_app/presentation/widgets/atoms/info_tile_schedule_atom.dart';
import 'package:meetclic_app/presentation/widgets/modals/scheduling_modal.dart';

import '../../../shared/localization/app_localizations.dart';
import '../../../shared/utils/util_common.dart';
import 'header_business_section.dart';

// InfoTile
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String type;

  const _InfoTile({required this.icon, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          text,
          style: TextStyle(
            fontSize: theme.textTheme.labelLarge?.fontSize,
            height: 2,
          ),
        ),
        onTap: () =>
            UtilCommon.handleTap(context: context, type: type, text: text),
      ),
    );
  }
}

List<_SocialIcon> buildSocialIcons(
  List<SocialNetwork> networks,
  String pageUrl,
) {
  final List<_SocialIcon> icons = [];
  final Map<String, IconData> iconMapping = {
    'facebook': Icons.facebook,
    'instagram': Icons.camera_alt,
    'twitter': Icons.alternate_email,
    'youtube': Icons.ondemand_video,
    'whatsapp': Icons.chat,
    'tiktok': Icons.videocam, // Asumiendo que tiktok vendría con otro name
  };
  for (final net in networks) {
    if (iconMapping.containsKey(net.typeSocial.toLowerCase())) {
      icons.add(
        _SocialIcon(
          icon: iconMapping[net.typeSocial.toLowerCase()]!,
          url: net.value,
        ),
      );
    }
  }
  if (pageUrl.isNotEmpty) {
    icons.add(_SocialIcon(icon: Icons.business, url: pageUrl));
  }

  return icons;
}

// SocialIcon
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () =>
            UtilCommon.handleTap(context: context, type: "web", text: url),
        borderRadius: BorderRadius.circular(22),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

List<DaySchedule> convertToDaySchedule(List<BusinessDay> days) {
  final now = DateTime.now();
  final todayIndex = now.weekday % 7; // Flutter: Lunes = 1

  return days.map((day) {
    final openRanges = day.configTypeSchedule.data;
    final isOpen = day.configTypeSchedule.type && openRanges.isNotEmpty;

    final timeRange = isOpen
        ? openRanges
              .map(
                (r) =>
                    "${r.startTime.modelBreakdown} - ${r.endTime.modelBreakdown}",
              )
              .join(" / ")
        : "";

    return DaySchedule(
      day: day.text,
      isToday: day.weightDay == todayIndex,
      isOpen: isOpen,
      timeRange: timeRange,
    );
  }).toList();
}

// MAIN COMPONENT
class HomeBusinessSection extends StatefulWidget {
  final BusinessData businessManagementData;

  const HomeBusinessSection({super.key, required this.businessManagementData});

  @override
  State<HomeBusinessSection> createState() => _HomeBusinessSectionState();
}

class _HomeBusinessSectionState extends State<HomeBusinessSection> {
  late BusinessModel business;
  late BusinessData businessData;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    business = widget.businessManagementData.business;
    _loadData();
    _scrollController.addListener(_handleScroll);
  }

  Future<void> _loadData() async {
    final response = await BusinessesDetailsUseCase(
      repository: BusinessDetailsRepositoryImpl(),
    ).execute(businessId: business.id);

    if (response.success && response.data.isNotEmpty) {
      setState(() {
        business = response.data[0];
        businessData = BusinessData(business: business);
        _isLoading = false;
      });
    }
  }

  void _handleScroll() {
    if (_scrollController.offset <= 0) {
      // Llegó al tope (puedes hacer algo extra si quieres)
      debugPrint("Scroll llegó arriba del todo");
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      // Llegó al fondo
      debugPrint("Llegó al fondo del scroll");
    }
  }

  Widget _buildSchedule() {
    List<BusinessDay>? days = business.schedulingData!;
    List<DaySchedule> schedule = convertToDaySchedule(days);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          InfoTileScheduleAtom(
            title: "Horario",
            subtitle: "Verified 1 month ago",
            description: "Abierto 8:00 a.m. - 2:00 p.m. EDT",
            icon: Icons.access_time,
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                isScrollControlled: true,
                builder: (context) {
                  return ScheduleModalOrganism(
                    schedule: schedule,
                  ); // Envías la lista ya armada
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final address = "${business.street1}, ${business.street2}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.phone,
            text: business.phoneValue,
            type: "whatsapp",
          ),
          _InfoTile(icon: Icons.email, text: business.email, type: "email"),
          _InfoTile(icon: Icons.public, text: business.pageUrl, type: "web"),
          _InfoTile(icon: Icons.location_on, text: address, type: ""),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    final List<_SocialIcon> icons = buildSocialIcons(
      business.socialNetworksData ?? [],
      business.pageUrl,
    );
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: icons);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final double headerHeight = screenHeight * 0.3;

    return Column(
      children: [
        SizedBox(
          height: headerHeight,
          child: HeaderBusinessSection(
            businessManagementData: businessData,
            heightTotal: headerHeight,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Text(
                  appLocalizations.translate('aboutUsDataTitle.contact'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.titleLarge?.fontSize,
                  ),
                ),
                _buildSchedule(),
                _buildContactSection(),
                const SizedBox(height: 12),
                Text(
                  appLocalizations.translate('aboutUsDataTitle.socials'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.titleLarge?.fontSize,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSocialIcons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
