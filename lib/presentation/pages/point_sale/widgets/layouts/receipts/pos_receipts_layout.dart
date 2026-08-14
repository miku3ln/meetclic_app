import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../shared/styles.dart';

import '../../../state/pos_receipts_controller.dart';
import '../../drawers/pos_app_drawer.dart';

import '../../organisms/items/pos_items_content.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../../organisms/receipts/pos_receipts_register_view.dart';
class PosReceiptsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const PosReceiptsLayout({
    super.key,
    this.onMenuTap,
  });
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosReceiptsController(),
      child: const _PosReceiptsView(),
    );
  }
}
class _PosReceiptsView extends StatelessWidget {
  const _PosReceiptsView();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      // Usamos Selector envuelto en PreferredSize para aislar los re-builds
      // únicamente al AppBar, dejando el body intacto.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Selector<PosReceiptsController, String>(
          selector: (_, controller) => controller.section,
          builder: (context, sectionTitle, _) {
            return PosSettingsAppBar(
              titlePrimary: "Recibos",
              titleSecondary: sectionTitle,
              onMenuTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
              style: PosSettingsAppBarStyle(
                topBackgroundColor: colors.primary,
                bottomBackgroundColor: colors.primary,
                primaryTitleColor: colors.textInverse,
                secondaryTitleColor: colors.textInverse,
                menuIconColor: colors.textInverse,
                primaryIndicatorColor: Colors.transparent,
                secondaryIndicatorColor: Colors.transparent,
                dividerColor: colors.divider,
              ),
            );
          },
        ),
      ),
      body: const Row(
        children: [
          Expanded(
            flex: 30,
            child: PosReceiptsRegisters(),
          ),
          Expanded(
            flex: 70,
            child: PosReceiptsRegisterView(),
          ),
        ],
      ),
    );
  }
}

class PosReceiptsRegisters extends StatefulWidget {
  const PosReceiptsRegisters({super.key});
  @override
  State<PosReceiptsRegisters> createState() => _PosReceiptsRegistersState();
}
class _PosReceiptsRegistersState extends State<PosReceiptsRegisters> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late PosTicketManagementApi _api;
  final List<GenericListItem<Map<String, dynamic>>> _items = [];
  int _currentPage = 1;
  final int _rowCount = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _hasInitialLoadFinished = false;
  String _searchCode = '';


  DateTime? _selectedDate;
  bool get _hasData => _items.isNotEmpty;
  bool get _hasMore => _items.length < _total;
  int _simulatedTotal = 592;


  @override
  void initState() {
    super.initState();

    _api = PosTicketManagementApi(total: _simulatedTotal);


      _loadInitial();


    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _api.fetchPage(
      current: _currentPage,
      rowCount: _rowCount,
      searchCode: _searchCode,
      date: _selectedDate,
    );

    if (!mounted) return;

    final controller = context.read<PosReceiptsController>();
    final rows = response.rows;

    setState(() {
      _items.addAll(rows);
      _total = response.total;
      _hasInitialLoadFinished = true;
      _isLoading = false;


    });

    if (rows.isNotEmpty) {
    controller.setSelectedReceipt(rows.first);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    _currentPage++;

    final response = await _api.fetchPage(
      current: _currentPage,
      rowCount: _rowCount,
      searchCode: _searchCode,
      date: _selectedDate,
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _isLoading = false;
    });
  }

  Future<void> _refreshAll() async {
    if (_isLoading) return;
    _api = PosTicketManagementApi(total: _simulatedTotal);
    final controller = context.read<PosReceiptsController>();
    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;

    });
    controller.clearSelection();
    await _loadInitial();
  }

  Future<void> _applyFilters() async {
    if (_isLoading) return;

    final controller = context.read<PosReceiptsController>();

    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;

    });

    controller.clearSelection();

    await _loadInitial();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });

    await _applyFilters();
  }

  void _clearDate() async {
    setState(() {
      _selectedDate = null;
    });

    await _applyFilters();
  }

  void _onSearchSubmitted(String value) async {
    _searchCode = value.trim();
    await _applyFilters();
  }


  @override
  Widget build(BuildContext context) {


    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildDateHeader(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasInitialLoadFinished && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasData) {
      return RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 500,
              child: EmptyData(
                icon: Icons.receipt_long_rounded,
                title: 'Todavía no hay recibos',
                descriptionText: 'Aquí podrás revisar ventas registradas',
                linkText: 'Más información',
              ),
            ),
          ],
        ),
      );
    }

    return _buildList();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Buscar por código o fecha',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () async {
              _searchController.clear();
              _searchCode = '';
              await _applyFilters();
            },
            icon: const Icon(Icons.close),
          )
              : IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildDateHeader() {
    final text = _selectedDate == null
        ? 'Todos los días'
        : _formatDate(_selectedDate!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_selectedDate != null)
            IconButton(
              onPressed: _clearDate,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _ReceiptListItem(
            key: ValueKey(_items[index].id),
            item: _items[index],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, ${date.day} de $month de ${date.year}';
  }
}

class _ReceiptListItem extends StatelessWidget {
  final GenericListItem<Map<String, dynamic>> item;

  const _ReceiptListItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<PosReceiptsController, bool>(
          (controller) => controller.selectedReceipt?.id == item.id,
    );

    final data = item.data ?? {};
    final ticketCode = data['ticketCode']?.toString() ?? '';

    return Material(
      color: isSelected
          ? Colors.grey.shade200
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          final controller = context.read<PosReceiptsController>();

          if (controller.selectedReceipt?.id == item.id) {
            return;
          }

          controller.setSelectedReceipt(item);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 32,
                color: Colors.grey,
              ),

              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 1,
                child: Text(
                  ticketCode,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}