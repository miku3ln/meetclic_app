
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/dialogs/draft-manager/pos_ticket-payment_modal.dart';

import '../../organisms/items/pos_items_content.dart';

typedef TicketMap = Map<String, dynamic>;

class PosDraftTicketsModal extends StatefulWidget {

  final double widthFactor;
  final double heightFactor;

  const PosDraftTicketsModal({
    super.key,
    this.widthFactor = 0.92,
    this.heightFactor = 0.88,
  });

  static Future<void> show(
      BuildContext context, {
        double widthFactor = 0.92,
        double heightFactor = 0.88,
      }) {
    return showDialog<void>(
      context: context,
      builder: (_) => PosDraftTicketsModal(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
      ),
    );
  }

  @override
  State<PosDraftTicketsModal> createState() =>
      _PosDraftTicketsModalState();
}

class _PosDraftTicketsModalState extends State<PosDraftTicketsModal> {
  final TextEditingController _searchController = TextEditingController();
  late final PosTicketManagementApi _api;
  static const int _rowCount = 20;
  int _totalRecords = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  int _requestVersion = 0;
  Timer? _searchDebounce;
  final ScrollController _scrollController = ScrollController();

  List<TicketMap> _tickets = [];

  DateTime? _startDate;
  DateTime? _endDate;

  String _status = 'DRAFT';
  String _search = '';

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = PosTicketManagementApi(total: 0);
    _scrollController.addListener(_onScroll);
    _load();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loading || _loadingMore || !_hasMore) return;
    if (_scrollController.position.extentAfter < 350) _loadNextPage();
  }

  @override
  void dispose() {
    _requestVersion++;
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null) return null;
    return DateTime.tryParse(text);
  }

  String _dateText(dynamic value) {
    final date = _parseDate(value);
    if (date == null) return '-';

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  double _ticketTotal(TicketMap ticket) {
    final header = _map(ticket['header']);
    final invoiceValue = _number(header['invoice_value']);

    if (invoiceValue > 0) return invoiceValue;

    return _number(header['subtotal']) +
        _number(header['value_taxes']) -
        _number(header['discount_value']);
  }

  String _customerName(TicketMap ticket) {
    final header = _map(ticket['header']);

    final name = [
      header['customer_name'],
      header['customer_last_name'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(' ');

    return name.isEmpty ? 'Consumidor final' : name;
  }

  String _ticketCode(TicketMap ticket) {
    final meta = _map(ticket['meta']);
    final header = _map(ticket['header']);

    return meta['ticket_code']?.toString() ??
        'TICKET-${header['id'] ?? '-'}';
  }

  Future<void> _load() async {
    final version = ++_requestVersion;
    setState(() {
      _tickets = [];
      _totalRecords = 0;
      _currentPage = 1;
      _hasMore = true;
      _loading = true;
      _loadingMore = false;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _fetchPage(version, 1);
  }

  Future<void> _loadNextPage() async {
    if (_loading || _loadingMore || !_hasMore) return;
    await _fetchPage(_requestVersion, _currentPage + 1);
  }

  Future<void> _fetchPage(int version, int page) async {
    if (page > 1) setState(() => _loadingMore = true);
    try {
      final response = await _api.fetchPage(
        current: page,
        rowCount: _rowCount,
        searchCode: _search.trim(),
        status: _status == 'ALL' ? null : _status,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (!mounted || version != _requestVersion) return;
      final batch = response.rows.map((item) {
        final original = item.data?['all'];
        if (original is! Map) {
          throw const FormatException('El ticket no contiene data.all.');
        }
        return Map<String, dynamic>.from(original);
      }).toList();
      setState(() {
        final ids = _tickets.map((t) => _map(t['header'])['id']).toSet();
        for (final ticket in batch) {
          if (ids.add(_map(ticket['header'])['id'])) _tickets.add(ticket);
        }
        _currentPage = page;
        _totalRecords = response.total;
        _hasMore = batch.isNotEmpty &&
            batch.length >= _rowCount &&
            _tickets.length < _totalRecords;
        _error = null;
      });
    } catch (e) {
      if (mounted && version == _requestVersion) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  // Los filtros se aplican en el servidor, no sobre la página actual.
  List<TicketMap> get _filteredTickets => _tickets;

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
    _load();
  }

  // La acción de cobro se conectará posteriormente con el flujo del POS.
  // No se realiza ningún cobro simulado.

  Widget _dateButton(String label, DateTime? date, bool start) {
    return OutlinedButton.icon(
      onPressed: () => _pickDate(start),
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(
        date == null
            ? label
            : '${date.day}/${date.month}/${date.year}',
      ),
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _dateButton('Desde', _startDate, true),
        _dateButton('Hasta', _endDate, false),
        if (_startDate != null || _endDate != null)
          IconButton(
            tooltip: 'Limpiar fechas',
            onPressed: () {
              setState(() { _startDate = null; _endDate = null; });
              _load();
            },
            icon: const Icon(Icons.event_busy_outlined),
          ),
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: 'DRAFT',
                child: Text('Guardados'),
              ),
              DropdownMenuItem(
                value: 'PENDING',
                child: Text('Facturados'),
              ),
              DropdownMenuItem(
                value: 'ALL',
                child: Text('Todos'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
                _load();
              }
            },
          ),
        ),
        SizedBox(
          width: 260,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _search = value);
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 400), _load);
            },
            decoration: const InputDecoration(
              hintText: 'Buscar ticket o cliente',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _ticketCard(TicketMap ticket) {
    final header = _map(ticket['header']);
    final status = (header['status']?.toString()=="DRAFT"?'Guardado':"Pagado") ?? '-';
    final canCollect = status == 'Guardado';
    final List<Widget> actions = [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _viewTicket(ticket),
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Ver'),
        ),
      ),

    ];

    if(canCollect){
      actions.add(SizedBox(width: 8));
      actions.add(    Expanded(
        child: FilledButton.icon(
          onPressed: () => _collectTicket(ticket),
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Cobrar'),
        ),
      ));


    }
final allowPayment=canCollect;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _ticketCode(ticket),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: canCollect ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _customerName(ticket),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _dateText(header['invoice_date']),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              _money(_ticketTotal(ticket)),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _collectTicket(TicketMap ticket) async {
    final result = await PosTicketPaymentModal.show(
      context,
      ticket: ticket,
    );

    if (!mounted || result == null) return;

    // Resultado del modal
    final success = result.success;
    final message = result.message;
    final data = result.data;
    final type = result.type;

    switch (type) {
      case 'saved':
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );

          // Actualizar tickets después del cobro.
          await _load();
        }
        break;

      case 'cancelled':
        debugPrint('Cobro cancelado: $message');
        break;

      case 'closed':
        debugPrint('Modal cerrado: $message');
        break;

      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }

    debugPrint('Success: $success');
    debugPrint('Message: $message');
    debugPrint('Type: $type');
    debugPrint('Data: $data');
  }
  void _viewTicket(TicketMap ticket) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
            maxHeight: 700,
          ),
          child: _SavedTicketPreview(
            ticket: ticket,
            onClose: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final tickets = _filteredTickets;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: media.width * widget.widthFactor,
        height: media.height * widget.heightFactor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tickets guardados',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _filters(),
              const SizedBox(height: 12),
              Text('${tickets.length} tickets cargados de $_totalRecords registros'),
              const SizedBox(height: 8),
              Expanded(
                child: _loading && _tickets.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!))
                    : tickets.isEmpty
                    ? const Center(
                  child: Text('No hay tickets para mostrar'),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 1000
                        ? 4
                        : width >= 650
                        ? 3
                        : width >= 400
                        ? 2
                        : 1;

                    return GridView.builder(
                      controller: _scrollController,
                      itemCount: tickets.length + (_loadingMore ? 1 : 0),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 195,
                      ),
                      itemBuilder: (context, index) {
                        if (index == tickets.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return _ticketCard(tickets[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTicketPreview extends StatelessWidget {
  final TicketMap ticket;
  final VoidCallback onClose;

  const _SavedTicketPreview({
    required this.ticket,
    required this.onClose,
  });

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  double _num(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  String _money(dynamic value) =>
      '\$${_num(value).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final header = _map(ticket['header']);
    final meta = _map(ticket['meta']);

    final details = (ticket['details'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final total = _num(header['subtotal']) +
        _num(header['value_taxes']) -
        _num(header['discount_value']);

    final code = meta['ticket_code'] ??
        'TICKET-${header['id'] ?? '-'}';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'TICKET DE VENTA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$code',
            style: const TextStyle(fontSize: 24),
          ),
          Text('N.º ${header['id'] ?? '-'}'),
          Text('Estado: ${header['status'] ?? '-'}'),
          Text('${header['invoice_date'] ?? '-'}'),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cliente: ${header['customer_name'] ?? ''} '
                  '${header['customer_last_name'] ?? ''}',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: details.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = details[index];

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['quantity']} × ${item['name'] ?? '-'}',
                      ),
                    ),
                    Text(_money(item['total'])),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          _amountRow('Subtotal', header['subtotal']),
          _amountRow('Impuestos', header['value_taxes']),
          _amountRow('Descuento', header['discount_value']),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                _money(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClose,
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, dynamic amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(_money(amount)),
      ],
    );
  }
}



enum TicketPaymentMethod { cash, deposit, card, qr }

class TicketPaymentRequest {
  final int invoiceSaleId;
  final TicketPaymentMethod method;
  final double total;
  final double received;
  final double change;

  const TicketPaymentRequest({
    required this.invoiceSaleId,
    required this.method,
    required this.total,
    required this.received,
    required this.change,
  });

  String get paymentMethodCode => switch (method) {
    TicketPaymentMethod.cash => 'CASH',
    TicketPaymentMethod.deposit => 'DEPOSIT',
    TicketPaymentMethod.card => 'CARD',
    TicketPaymentMethod.qr => 'QR',
  };
}
