import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';
import '../pages/lake_maritime/tabs/tab_home_page.dart';
import '../pages/lake_maritime/tabs/tab_list_registers_page.dart';
import '../pages/lake_maritime/tabs/tab_register_page.dart';

class ProjectLakePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const ProjectLakePage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  _ProjectLakePageState createState() => _ProjectLakePageState();
}

class _ProjectLakePageState extends State<ProjectLakePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: "Inicio"),
              Tab(icon: Icon(Icons.assignment), text: "Registro"),
              Tab(icon: Icon(Icons.list), text: "Registros"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TabHomePage(),
                TabRegisterPage(),
                TabListRegistersPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
