import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  final _search = TextEditingController();
  final _movementSearch = TextEditingController();
  String _category = 'Todas';
  String _movementType = 'Todos';
  String _movementPeriod = 'Todos';
  DateTimeRange? _movementRange;

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    _movementSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<AppController>(
        builder: (context, app, _) {
          final width = MediaQuery.sizeOf(context).width;
          final pad = width < 620 ? 16.0 : 26.0;
          final filtered = app.products
              .where((product) =>
                  (_category == 'Todas' || product.category == _category) &&
                  product.name
                      .toLowerCase()
                      .contains(_search.text.trim().toLowerCase()))
              .toList();
          return Padding(
            padding: EdgeInsets.fromLTRB(pad, 23, pad, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  title: 'Estoque',
                  subtitle: 'Posição, entradas e rastreabilidade dos produtos.',
                  trailing: app.role.canManage
                      ? NeonButton(
                          label: 'NOVA ENTRADA',
                          icon: Icons.add_rounded,
                          compact: true,
                          onPressed: () => _receiptDialog(app),
                        )
                      : null,
                ),
                const SizedBox(height: 17),
                Container(
                  decoration: BoxDecoration(
                    color: arcadeSoftSurfaceColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ArcadeColors.divider),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorColor: ArcadeColors.cyan,
                    labelColor: ArcadeColors.cyan,
                    unselectedLabelColor: ArcadeColors.muted,
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: const [
                      Tab(text: 'Posição atual'),
                      Tab(text: 'Entradas'),
                      Tab(text: 'Movimentações'),
                      Tab(text: 'Fornecedores'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _position(app, filtered),
                      _receipts(app),
                      _movements(app),
                      _suppliers(app),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _position(AppController app, List<AppProduct> products) => Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final search = SizedBox(
                height: 44,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, size: 16),
                    hintText: 'Buscar produto...',
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              );
              final category = DropdownButton<String>(
                value: _category,
                dropdownColor: arcadeSurfaceColor(context),
                underline: const SizedBox.shrink(),
                items: ['Todas', 'Fichas', 'Bebidas', 'Snacks']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child:
                              Text(value, style: const TextStyle(fontSize: 10)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? 'Todas'),
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    Align(alignment: Alignment.centerRight, child: category)
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 10),
                  category,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: products.isEmpty
                  ? const EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: products.length + 1,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: ArcadeColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.fromLTRB(10, 3, 10, 12),
                            child: Row(
                              children: [
                                Expanded(flex: 4, child: _TableHead('PRODUTO')),
                                Expanded(
                                    flex: 2, child: _TableHead('CATEGORIA')),
                                Expanded(
                                    flex: 4,
                                    child: _TableHead('NÍVEL DE ESTOQUE')),
                                SizedBox(
                                    width: 68, child: _TableHead('STATUS')),
                              ],
                            ),
                          );
                        }
                        final product = products[index - 1];
                        final color = product.stock <= product.minimum
                            ? ArcadeColors.red
                            : product.stock <= product.minimum * 1.5
                                ? ArcadeColors.yellow
                                : ArcadeColors.lime;
                        final level = product.minimum == 0
                            ? .85
                            : (product.stock / (product.minimum * 2))
                                .clamp(.06, 1.0)
                                .toDouble();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: ArcadeColors.cyan
                                            .withValues(alpha: .08),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(product.icon,
                                          color: ArcadeColors.cyan, size: 16),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700)),
                                          Text(
                                            '${product.stock} un. · mínimo ${product.minimum}',
                                            style: const TextStyle(
                                                color: ArcadeColors.muted,
                                                fontSize: 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(product.category,
                                    style: const TextStyle(
                                        color: ArcadeColors.muted,
                                        fontSize: 9)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(
                                        value: level,
                                        minHeight: 6,
                                        color: color,
                                        backgroundColor:
                                            arcadeSoftSurfaceColor(context),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${product.stock} em estoque',
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 68,
                                child: product.isLow
                                    ? const StatusChip(
                                        label: 'Baixo',
                                        color: ArcadeColors.red,
                                        dot: false,
                                      )
                                    : const StatusChip(
                                        label: 'OK',
                                        color: ArcadeColors.lime,
                                        dot: false,
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      );

  Widget _receipts(AppController app) {
    final receipts = app.inventoryMovements
        .where((movement) => _movementKind(movement) == 'purchase')
        .toList();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelHeading(
            'Entradas de estoque',
            subtitle: 'Compras e reposição refletem automaticamente no saldo.',
          ),
          const SizedBox(height: 14),
          if (receipts.isEmpty)
            const Expanded(child: EmptyState())
          else
            Expanded(
              child: ListView.separated(
                itemCount: receipts.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: ArcadeColors.divider,
                ),
                itemBuilder: (context, index) =>
                    _MovementRow(movement: receipts[index]),
              ),
            ),
          if (app.role.canManage)
            Align(
              alignment: Alignment.centerRight,
              child: NeonButton(
                label: 'REGISTRAR ENTRADA',
                icon: Icons.add_rounded,
                compact: true,
                onPressed: () => _receiptDialog(app),
              ),
            ),
        ],
      ),
    );
  }

  Widget _movements(AppController app) {
    final movements = _filteredMovements(app);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 640;
            final search = SizedBox(
              width: narrow ? constraints.maxWidth : 320,
              height: 44,
              child: TextField(
                controller: _movementSearch,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, size: 16),
                  hintText: 'Produto ou operador...',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            );
            final type = SizedBox(
              width: narrow ? constraints.maxWidth : 175,
              child: DropdownButtonFormField<String>(
                initialValue: _movementType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  'Todos',
                  'purchase',
                  'sale',
                  'maintenance',
                  'loss',
                  'reversal',
                ]
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(_movementTypeLabel(value),
                              style: const TextStyle(fontSize: 10)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _movementType = value ?? 'Todos'),
              ),
            );
            final period = SizedBox(
              width: narrow ? constraints.maxWidth : 155,
              child: DropdownButtonFormField<String>(
                initialValue: _movementPeriod,
                decoration: const InputDecoration(labelText: 'Período'),
                items: const ['Todos', '7 dias', '30 dias', 'Personalizado']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child:
                              Text(value, style: const TextStyle(fontSize: 10)),
                        ))
                    .toList(),
                onChanged: (value) async {
                  final next = value ?? 'Todos';
                  setState(() => _movementPeriod = next);
                  if (next == 'Personalizado') {
                    await _pickMovementRange();
                  } else {
                    setState(() => _movementRange = null);
                  }
                },
              ),
            );
            return Wrap(
              spacing: 9,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                search,
                type,
                period,
                if (_movementPeriod == 'Personalizado')
                  OutlinedButton.icon(
                    onPressed: _pickMovementRange,
                    icon: const Icon(Icons.date_range_rounded, size: 15),
                    label: Text(_movementRange == null
                        ? 'Selecionar datas'
                        : '${shortDate(_movementRange!.start)} – ${shortDate(_movementRange!.end)}'),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: movements.isEmpty
                ? const EmptyState(
                    message: 'Nenhuma movimentação para esses filtros.')
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: movements.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: ArcadeColors.divider,
                      height: 1,
                    ),
                    itemBuilder: (context, index) =>
                        _MovementRow(movement: movements[index]),
                  ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredMovements(AppController app) {
    final query = _movementSearch.text.trim().toLowerCase();
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;
    if (_movementPeriod == '7 dias') {
      start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6));
    } else if (_movementPeriod == '30 dias') {
      start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 29));
    } else if (_movementPeriod == 'Personalizado' && _movementRange != null) {
      start = DateTime(_movementRange!.start.year, _movementRange!.start.month,
          _movementRange!.start.day);
      end = DateTime(_movementRange!.end.year, _movementRange!.end.month,
              _movementRange!.end.day)
          .add(const Duration(days: 1));
    }
    return app.inventoryMovements.where((movement) {
      final kind = _movementKind(movement);
      if (_movementType != 'Todos' && kind != _movementType) return false;
      final product = (movement['product_name'] ?? '').toString();
      final operatorName = (movement['operator'] ?? '').toString();
      final note = (movement['note'] ?? '').toString();
      if (query.isNotEmpty &&
          !'$product $operatorName $note'.toLowerCase().contains(query)) {
        return false;
      }
      final date = _movementDate(movement['created_at']);
      if (start != null && (date == null || date.isBefore(start))) return false;
      if (end != null && (date == null || !date.isBefore(end))) return false;
      if (_movementPeriod == 'Personalizado' && _movementRange == null) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickMovementRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _movementRange,
      helpText: 'Selecione o período',
      saveText: 'APLICAR',
      cancelText: 'CANCELAR',
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _movementRange = picked);
    } else if (_movementRange == null) {
      setState(() => _movementPeriod = 'Todos');
    }
  }

  Widget _suppliers(AppController app) => app.suppliers.isEmpty
      ? const GlassCard(child: EmptyState())
      : LayoutBuilder(builder: (context, constraints) {
          final count = constraints.maxWidth > 1000
              ? 3
              : constraints.maxWidth > 610
                  ? 2
                  : 1;
          final gap = 12.0;
          final width = (constraints.maxWidth - (count - 1) * gap) / count;
          return SingleChildScrollView(
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: app.suppliers
                  .map((supplier) => SizedBox(
                        width: width,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ArcadeColors.purple
                                          .withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_outlined,
                                      color: ArcadeColors.purple,
                                      size: 19,
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusChip(
                                    label:
                                        supplier.active ? 'Ativo' : 'Inativo',
                                    color: supplier.active
                                        ? ArcadeColors.lime
                                        : ArcadeColors.muted,
                                    dot: false,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 13),
                              Text(supplier.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(supplier.taxId,
                                  style: const TextStyle(
                                      color: ArcadeColors.muted, fontSize: 9)),
                              const SizedBox(height: 3),
                              Text(supplier.contact,
                                  style: const TextStyle(
                                      color: ArcadeColors.muted, fontSize: 9)),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: supplier.active
                                      ? () async {
                                          try {
                                            await app.deactivateSupplier(
                                                supplier.id);
                                          } on Object catch (error) {
                                            if (context.mounted) {
                                              _message(context, error);
                                            }
                                          }
                                        }
                                      : null,
                                  icon: Icon(
                                    supplier.active
                                        ? Icons.block_rounded
                                        : Icons.check_circle_outline_rounded,
                                    color: supplier.active
                                        ? ArcadeColors.red
                                        : ArcadeColors.muted,
                                    size: 14,
                                  ),
                                  label: Text(
                                    supplier.active
                                        ? 'Inativar'
                                        : 'Mantido no histórico',
                                    style: TextStyle(
                                      color: supplier.active
                                          ? ArcadeColors.red
                                          : ArcadeColors.muted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        });

  Future<void> _receiptDialog(AppController app) async {
    if (app.products.isEmpty) {
      _message(context,
          'Cadastre produtos no Supabase antes de registrar uma entrada.');
      return;
    }
    final activeSuppliers =
        app.suppliers.where((supplier) => supplier.active).toList();
    final draft = await showModalBottomSheet<_StockReceiptDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: arcadeSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _StockReceiptForm(
        products: app.products,
        suppliers: activeSuppliers,
      ),
    );
    if (draft == null) return;
    try {
      await app.registerStockReceipt(
        supplierId: draft.supplierId,
        lines: draft.lines,
        note: draft.note,
        occurredAt: draft.occurredAt,
      );
      if (mounted) _message(context, 'Entrada registrada e saldo atualizado.');
    } on Object catch (error) {
      if (mounted) _message(context, error);
    }
  }

  void _message(BuildContext context, Object error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString().replaceFirst('Bad state: ', '')),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
}

String _movementKind(Map<String, dynamic> movement) =>
    (movement['type'] ?? movement['movement_type'] ?? '').toString();

String _movementTypeLabel(String type) => switch (type) {
      'Todos' => 'Todos',
      'purchase' => 'Compra',
      'sale' => 'Venda',
      'maintenance' => 'Manutenção',
      'loss' => 'Perda',
      'reversal' => 'Estorno',
      _ => 'Ajuste',
    };

DateTime? _movementDate(dynamic value) {
  if (value is DateTime) return value.toLocal();
  return DateTime.tryParse((value ?? '').toString())?.toLocal();
}

class _StockReceiptDraft {
  const _StockReceiptDraft({
    required this.supplierId,
    required this.lines,
    required this.note,
    required this.occurredAt,
  });

  final String? supplierId;
  final List<Map<String, dynamic>> lines;
  final String note;
  final DateTime occurredAt;
}

class _ReceiptLineDraft {
  _ReceiptLineDraft(this.product)
      : quantity = TextEditingController(text: '1'),
        unitCost =
            TextEditingController(text: product.unitCost.toStringAsFixed(2));

  AppProduct product;
  final TextEditingController quantity;
  final TextEditingController unitCost;

  void dispose() {
    quantity.dispose();
    unitCost.dispose();
  }
}

class _StockReceiptForm extends StatefulWidget {
  const _StockReceiptForm({required this.products, required this.suppliers});

  final List<AppProduct> products;
  final List<Supplier> suppliers;

  @override
  State<_StockReceiptForm> createState() => _StockReceiptFormState();
}

class _StockReceiptFormState extends State<_StockReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  final List<_ReceiptLineDraft> _lines = [];
  String? _supplierId;
  DateTime _occurredAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _supplierId = widget.suppliers.isEmpty ? null : widget.suppliers.first.id;
    _lines.add(_ReceiptLineDraft(widget.products.first));
  }

  @override
  void dispose() {
    _note.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final height = (media.height - keyboard - 24).clamp(300.0, media.height);
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SizedBox(
        height: height * .94,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Material(
              color: arcadeSurfaceColor(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 16, 14),
                    child: Row(
                      children: [
                        const Expanded(
                          child: PanelHeading(
                            'Nova entrada',
                            subtitle:
                                'Registre vários produtos e a data real da compra.',
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ArcadeColors.divider),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                        children: [
                          if (widget.suppliers.isNotEmpty) ...[
                            DropdownButtonFormField<String?>(
                              initialValue: _supplierId,
                              decoration: const InputDecoration(
                                  labelText: 'Fornecedor'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Sem fornecedor'),
                                ),
                                ...widget.suppliers.map(
                                  (supplier) => DropdownMenuItem<String?>(
                                    value: supplier.id,
                                    child: Text(supplier.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _supplierId = value),
                            ),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Nenhum fornecedor ativo; a entrada ficará sem fornecedor.',
                                style: TextStyle(
                                    color: ArcadeColors.muted, fontSize: 10),
                              ),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.event_outlined, size: 17),
                            label: Text(
                                'Data da entrada: ${shortDate(_occurredAt)}'),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Expanded(
                                child: Text('ITENS DA ENTRADA',
                                    style: TextStyle(
                                        color: ArcadeColors.muted,
                                        fontSize: 9,
                                        letterSpacing: .8,
                                        fontWeight: FontWeight.w800)),
                              ),
                              TextButton.icon(
                                onPressed: _addLine,
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Adicionar produto'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ..._lines.asMap().entries.map(
                              (entry) => _lineCard(entry.key, entry.value)),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _note,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Observação / nota fiscal',
                              hintText: 'Ex.: NF 00845',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: ArcadeColors.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const Spacer(),
                        NeonButton(
                          label: 'ATUALIZAR ESTOQUE',
                          icon: Icons.check_rounded,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lineCard(int index, _ReceiptLineDraft line) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: arcadeSoftSurfaceColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ArcadeColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AppProduct>(
                    initialValue: line.product,
                    decoration:
                        InputDecoration(labelText: 'Produto ${index + 1}'),
                    items: widget.products
                        .map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (product) {
                      if (product == null) return;
                      setState(() {
                        line.product = product;
                        line.unitCost.text =
                            product.unitCost.toStringAsFixed(2);
                      });
                    },
                  ),
                ),
                if (_lines.length > 1)
                  IconButton(
                    tooltip: 'Remover item',
                    onPressed: () => _removeLine(index),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: ArcadeColors.red),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            LayoutBuilder(
              builder: (context, constraints) {
                final quantity = TextFormField(
                  controller: line.quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  validator: (value) {
                    final parsed = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'));
                    if (parsed == null || !parsed.isFinite || parsed <= 0) {
                      return 'Informe uma quantidade maior que zero.';
                    }
                    return null;
                  },
                );
                final cost = TextFormField(
                  controller: line.unitCost,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  decoration: const InputDecoration(
                      labelText: 'Custo unitário', prefixText: 'R\$ '),
                  validator: (value) {
                    final parsed = parseMoney(value ?? '');
                    if (parsed == null || !parsed.isFinite || parsed < 0) {
                      return 'Informe custo válido (zero ou maior).';
                    }
                    return null;
                  },
                );
                if (constraints.maxWidth < 460) {
                  return Column(
                    children: [quantity, const SizedBox(height: 9), cost],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: quantity),
                    const SizedBox(width: 10),
                    Expanded(child: cost),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Data da entrada',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
    );
    if (selected != null && mounted) {
      setState(() => _occurredAt = selected);
    }
  }

  void _addLine() =>
      setState(() => _lines.add(_ReceiptLineDraft(widget.products.first)));

  void _removeLine(int index) {
    final line = _lines.removeAt(index);
    line.dispose();
    setState(() {});
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final payload = _lines.map((line) {
      return <String, dynamic>{
        'product_id': line.product.id,
        'quantity':
            double.parse(line.quantity.text.trim().replaceAll(',', '.')),
        'unit_cost': parseMoney(line.unitCost.text)!,
      };
    }).toList();
    Navigator.of(context).pop(
      _StockReceiptDraft(
        supplierId: _supplierId,
        lines: payload,
        note: _note.text.trim(),
        occurredAt: _occurredAt,
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: ArcadeColors.muted,
          fontSize: 7,
          letterSpacing: .6,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});
  final Map<String, dynamic> movement;

  @override
  Widget build(BuildContext context) {
    final type = _movementKind(movement);
    final label = _movementTypeLabel(type);
    final color = switch (type) {
      'purchase' => ArcadeColors.lime,
      'sale' => ArcadeColors.cyan,
      'loss' => ArcadeColors.red,
      'maintenance' => ArcadeColors.yellow,
      'reversal' => ArcadeColors.magenta,
      _ => ArcadeColors.purple,
    };
    final time = _movementDate(movement['created_at']);
    final quantity = movement['quantity'] as num? ?? 0;
    final quantityLabel = quantity == quantity.toInt()
        ? quantity.toInt().toString()
        : quantity.toString();
    final productName =
        (movement['product_name'] ?? movement['product_id'] ?? 'Produto')
            .toString();
    final operatorName = (movement['operator'] ?? 'Equipe').toString();
    final note = (movement['note'] ?? '').toString().trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              type == 'purchase'
                  ? Icons.south_west_rounded
                  : type == 'sale'
                      ? Icons.north_east_rounded
                      : Icons.inventory_2_outlined,
              color: color,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700)),
                Text(
                  '$operatorName · ${time == null ? 'Data indisponível' : shortDate(time)} · ${label.toLowerCase()}${note.isEmpty ? '' : ' · $note'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: ArcadeColors.muted, fontSize: 8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${quantity > 0 ? '+' : ''}$quantityLabel un.',
            style: TextStyle(
              color: color,
              fontFamily: 'SpaceGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
