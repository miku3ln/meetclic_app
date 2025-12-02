import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/maritime_departure_model.dart';
import '../../../../infrastructure/services/maritime_departure_service.dart';

class TabListRegistersPage extends StatefulWidget {
  const TabListRegistersPage({super.key});

  @override
  State<TabListRegistersPage> createState() => _TabListRegistersPageState();
}

class _TabListRegistersPageState extends State<TabListRegistersPage> {
  final ScrollController _scrollController = ScrollController();
  final List<MaritimeDepartureModel> _items = [];

  bool _isLoading = false;

  DateTime? _fromDate;
  DateTime? _toDate;

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchData(); // carga inicial sin filtros
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================
  // LÓGICA DE CARGA DE DATOS
  // ==========================
  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final useCase = GetDeparturesWithCustomersUseCase(
      MaritimeDepartureService(),
    );

    final result = await useCase.execute(
      businessId: 1,
      from: _fromDate,
      to: _toDate,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _items
          ..clear()
          ..addAll(result.data);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshList() async {
    await _fetchData();
  }

  // ==========================
  // MANEJO DE RANGO DE FECHAS
  // ==========================
  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    // Si ya hay rango, se usa como inicial; si no, últimos 7 días
    final DateTimeRange initialRange = (_fromDate != null && _toDate != null)
        ? DateTimeRange(start: _fromDate!, end: _toDate!)
        : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });

      // Si quieres que al seleccionar el rango ya se apliquen los filtros:
      await _fetchData();
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _fetchData();
  }

  String _rangeLabel() {
    if (_fromDate == null || _toDate == null) {
      return 'Seleccione las Fechas';
    }
    return '${_displayFormat.format(_fromDate!)} - ${_displayFormat.format(_toDate!)}';
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFiltersBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshList,
            child: _isLoading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ExpansionTile(
                        leading: const Icon(Icons.directions_boat),
                        title: Text(item.responsibleName),
                        subtitle: Text("Hora: ${item.arrivalTime}"),
                        trailing: const Icon(Icons.expand_more),
                        children: item.customers!.map((customer) {
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(customer.fullName),
                            subtitle: Text(
                              "Cédula: ${customer.documentNumber}",
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Edad: ${customer.age}"),
                                Text("Tipo: ${customer.type}"),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Botón único para rango de fechas
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(_rangeLabel()),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear),
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
    );
  }
}
