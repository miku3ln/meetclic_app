import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../domain/services/session_service.dart';
import '../../../../../../shared/controllers/app_controller.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../shared/styles.dart';

import '../../../state/pos_receipts_controller.dart';
import '../../drawers/pos_app_drawer.dart';

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
    final sectionTitle = context.watch<PosReceiptsController>().section;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: "Recibos",
        titleSecondary:sectionTitle,
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

  late FakeReceiptsApi _api;

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

  @override
  void initState() {
    super.initState();
    _api = FakeReceiptsApi();
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
    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _hasInitialLoadFinished = true;
      _isLoading = false;
    });
    if (_items.isNotEmpty && controller.selectedReceipt == null) {
      controller.setSelectedReceipt(_items.first);
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

    _api = FakeReceiptsApi();

    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;
    });

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

  void _onTapItem(GenericListItem<Map<String, dynamic>> item) {
    context.read<PosReceiptsController>().setSelectedReceipt(item);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosReceiptsController>();
    final app = context.read<AppController>();
    final session = context.watch<SessionService>();

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
    final receiptsController = context.watch<PosReceiptsController>();
    final selectedId = receiptsController.selectedReceipt?.id;

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
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = _items[index];
          final isSelected = item.id == selectedId;

          return Material(
            color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            child: InkWell(
              onTap: () => _onTapItem(item),
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
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
class FakeReceiptsApi {
  final List<GenericListItem<Map<String, dynamic>>> _allData = List.generate(
    120,
        (index) {
      final amount = (1.50 + (index % 5) * 0.50).toStringAsFixed(2);
      final code = '#5-${37260 + index}';
      final hour = '22:${(index % 60).toString().padLeft(2, '0')}';

      return GenericListItem<Map<String, dynamic>>(
        id: index + 1,
        title: '\$$amount',
        subtitle: hour,
        description: code,
        image: null,
        data: {
          'receiptNumber': '05-${647 + index}',
          'employee': 'Trece',
          'tpv': 'TPV 1',
          'orderType': 'Para Servirse',
          'productName': 'Mixto ${index + 1}',
          'quantity': 1,
          'unitPrice': double.parse(amount),
          'lineTotal': double.parse(amount),
          'total': double.parse(amount),
          'paymentMethod': 'Efectivo',
          'paymentAmount': double.parse(amount),
          'code': code,
          'hour': hour,
          'date': DateTime(2026, 3, 12),
        },
      );
    },
  );

  Future<PaginatedResponse<GenericListItem<Map<String, dynamic>>>> fetchPage({
    required int current,
    required int rowCount,
    String? searchCode,
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    Iterable<GenericListItem<Map<String, dynamic>>> filtered = _allData;

    if (searchCode != null && searchCode.trim().isNotEmpty) {
      final query = searchCode.toLowerCase();
      filtered = filtered.where((item) {
        final code = (item.data?['code'] ?? '').toString().toLowerCase();
        return code.contains(query);
      });
    }

    if (date != null) {
      filtered = filtered.where((item) {
        final itemDate = item.data?['date'] as DateTime?;
        if (itemDate == null) return false;

        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      });
    }

    final list = filtered.toList();
    final start = (current - 1) * rowCount;
    var end = start + rowCount;

    if (start >= list.length) {
      return PaginatedResponse(
        current: current,
        rowCount: rowCount,
        rows: [],
        total: list.length,
      );
    }

    if (end > list.length) {
      end = list.length;
    }

    return PaginatedResponse(
      current: current,
      rowCount: rowCount,
      rows: list.sublist(start, end),
      total: list.length,
    );
  }
}