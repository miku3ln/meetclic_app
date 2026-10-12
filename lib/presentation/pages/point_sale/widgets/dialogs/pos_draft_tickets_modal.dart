
import 'package:flutter/material.dart';

typedef TicketMap = Map<String, dynamic>;

class PosDraftTicketsModal extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() loadTickets;
  final Future<void> Function(TicketMap ticket) onCollect;

  final double widthFactor;
  final double heightFactor;

  const PosDraftTicketsModal({
    super.key,
    required this.loadTickets,
    required this.onCollect,
    this.widthFactor = 0.92,
    this.heightFactor = 0.88,
  });

  static Future<void> show(
      BuildContext context, {
        required Future<Map<String, dynamic>> Function() loadTickets,
        required Future<void> Function(TicketMap ticket) onCollect,
        double widthFactor = 0.92,
        double heightFactor = 0.88,
      }) {
    return showDialog<void>(
      context: context,
      builder: (_) => PosDraftTicketsModal(
        loadTickets: loadTickets,
        onCollect: onCollect,
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
  final TextEditingController _searchController =
  TextEditingController();

  List<TicketMap> _tickets = [];

  DateTime? _startDate;
  DateTime? _endDate;

  String _status = 'DRAFT';
  String _search = '';

  bool _loading = false;
  bool _collecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
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

  double _total(TicketMap ticket) {
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
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.loadTickets();

      // Soporta directamente:
      // { "total": 18, "rows": [...] }
      final rows = response['rows'];

      if (rows is! List) {
        throw Exception('La respuesta no contiene rows.');
      }

      if (!mounted) return;

      setState(() {
        _tickets = rows
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<TicketMap> get _filteredTickets {
    final query = _search.trim().toLowerCase();

    return _tickets.where((ticket) {
      final header = _map(ticket['header']);
      final status = header['status']?.toString() ?? '';

      if (_status != 'ALL' && status != _status) {
        return false;
      }

      final date = _parseDate(header['invoice_date']);

      if (_startDate != null) {
        if (date == null ||
            date.isBefore(DateUtils.dateOnly(_startDate!))) {
          return false;
        }
      }

      if (_endDate != null) {
        if (date == null ||
            !date.isBefore(
              DateUtils.dateOnly(_endDate!)
                  .add(const Duration(days: 1)),
            )) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final searchable = [
          header['id'],
          header['invoice_code'],
          _ticketCode(ticket),
          _customerName(ticket),
          header['employee_user_name'],
          header['customer_identification_document'],
        ].join(' ').toLowerCase();

        if (!searchable.contains(query)) return false;
      }

      return true;
    }).toList();
  }

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
  }

  Future<void> _collect(TicketMap ticket) async {
    final header = _map(ticket['header']);

    if (_collecting || header['status'] != 'DRAFT') return;

    setState(() => _collecting = true);

    try {
      await widget.onCollect(ticket);
      if (mounted) await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cobrar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _collecting = false);
      }
    }
  }

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
            onPressed: () => setState(() {
              _startDate = null;
              _endDate = null;
            }),
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
    final status = header['status']?.toString() ?? '-';
    final canCollect = status == 'DRAFT';

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
              _money(_total(ticket)),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewTicket(ticket),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ver'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canCollect && !_collecting
                        ? () => _collect(ticket)
                        : null,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Cobrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              Text('${tickets.length} tickets encontrados'),
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
                      itemCount: tickets.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 195,
                      ),
                      itemBuilder: (context, index) =>
                          _ticketCard(tickets[index]),
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
