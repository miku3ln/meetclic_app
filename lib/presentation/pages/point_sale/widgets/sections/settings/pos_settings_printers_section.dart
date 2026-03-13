import 'package:flutter/material.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../widgets/empty_data.dart';
import '../../organisms/settings/pos_settings_content.dart';

class PosSettingsPrintersSection extends StatefulWidget {
  const PosSettingsPrintersSection({super.key});

  @override
  State<PosSettingsPrintersSection> createState() =>
      _PosSettingsPrintersSectionState();
}

class _PosSettingsPrintersSectionState
    extends State<PosSettingsPrintersSection> {
  final ScrollController _scrollController = ScrollController();

  /// aquí decides el total simulado
  int _simulatedTotal = 592;

  late FakePrintersApi _api;

  final List<GenericListItem<Map<String, dynamic>>> _items = [];

  int _currentPage = 1;
  final int _rowCount = 10;
  int _total = 0;

  bool _isLoading = false;
  bool _hasInitialLoadFinished = false;

  bool get _hasData => _items.isNotEmpty;
  bool get _hasMore => _items.length < _total;

  @override
  void initState() {
    super.initState();
    _api = FakePrintersApi(total: _simulatedTotal);
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _hasInitialLoadFinished = true;
      _isLoading = false;
    });
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
    _api = FakePrintersApi(total: _simulatedTotal);

    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;
    });

    await _loadInitial();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onTapItem(GenericListItem<Map<String, dynamic>> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: Text(
          'ID: ${item.id}\n'
              'Subtitle: ${item.subtitle}\n'
              'Description: ${item.description}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_hasInitialLoadFinished && _isLoading)
          const Center(child: CircularProgressIndicator())
        else if (!_hasData)
          RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 600,
                  child: EmptyData(
                    icon: Icons.print_rounded,
                    title: 'Todavía no hay impresoras',
                    descriptionText:
                    'Aquí puedes conectar tu impresora de recibos y de cocina.',
                    linkText: 'Más información',
                  ),
                ),
              ],
            ),
          )
        else
          _buildList(),

        Positioned(
          right: 32,
          bottom: 80,
          child: FloatingActionButton(
            onPressed: () {
              debugPrint('Agregar impresora');
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
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

          final item = _items[index];

          return InkWell(
            onTap: () => _onTapItem(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: item.image == null
                        ? const Icon(Icons.print, color: Colors.grey)
                        : null,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}