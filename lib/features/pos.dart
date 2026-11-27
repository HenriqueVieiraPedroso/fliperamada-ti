import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _category = 'Tudo';
  final _categories = const ['Tudo', 'Fichas', 'Bebidas', 'Snacks'];

  void _message(String text, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null));

  @override
  Widget build(BuildContext context) =>
      Consumer<AppController>(builder: (context, app, _) {
        final pageWidth = MediaQuery.sizeOf(context).width;
        final isWide = pageWidth >= 1050;
        final products = app.products
            .where((product) =>
                _category == 'Tudo' || product.category == _category)
            .toList();
        if (!app.cashOpen) return _ClosedRegister(onOpen: () => _openCash(app));
        return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pageWidth < 620 ? 16 : 24, 23,
                    pageWidth < 620 ? 16 : 24, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title: 'PDV Arcade',
                          subtitle:
                              'Venda rápida. A próxima ficha está a um toque.',
                          trailing: pageWidth > 620
                              ? const HeaderBadge(
                                  icon: Icons.circle,
                                  label: 'CAIXA ABERTO',
                                  color: ArcadeColors.lime)
                              : null),
                      const SizedBox(height: 17),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Expanded(child: _productArea(app, products)),
                                  const SizedBox(width: 18),
                                  SizedBox(width: 350, child: _cartArea(app)),
                                ])
                          : Column(children: [
                              _productArea(app, products),
                              const SizedBox(height: 16),
                              _cartArea(app),
                            ]),
                    ])));
      });

  Widget _productArea(AppController app, List<AppProduct> products) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = category),
                    backgroundColor: arcadeSurfaceColor(context),
                    selectedColor: ArcadeColors.cyan.withValues(alpha: .14),
                    side: BorderSide(
                      color: _category == category
                          ? ArcadeColors.cyan.withValues(alpha: .35)
                          : ArcadeColors.divider,
                    ),
                    labelStyle: TextStyle(
                      color: _category == category
                          ? ArcadeColors.cyan
                          : ArcadeColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 560
                ? 3
                : constraints.maxWidth > 355
                    ? 2
                    : 1;
        final gap = 11.0;
        final itemWidth = (constraints.maxWidth - gap * (count - 1)) / count;
        return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: products
                .map((product) => SizedBox(
                    width: itemWidth,
                    child: _ProductTile(
                        product: product,
                        onAdd: () {
                          try {
                            app.addToCart(product);
                          } on StateError catch (error) {
                            _message(error.message, error: true);
                          }
                        })))
                .toList());
      }),
    ]);
  }

  Widget _cartArea(AppController app) => GlassCard(
      glow: ArcadeColors.magenta,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: PanelHeading('Seu carrinho',
                  subtitle: 'Revise antes de fechar a venda')),
          if (app.cart.isNotEmpty)
            TextButton(
                onPressed: app.clearCart,
                child: const Text('Limpar',
                    style: TextStyle(color: ArcadeColors.red, fontSize: 10)))
        ]),
        const SizedBox(height: 14),
        if (app.cart.isEmpty)
          const SizedBox(
              height: 115,
              child: EmptyState(
                  message: 'Adicione uma ficha\ne comece a partida.',
                  icon: Icons.add_shopping_cart_rounded))
        else ...[
          ...app.cart.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Row(children: [
                Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: ArcadeColors.cyan.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(line.product.icon,
                        color: ArcadeColors.cyan, size: 17)),
                const SizedBox(width: 9),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(line.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(money(line.product.price),
                          style: const TextStyle(
                              color: ArcadeColors.muted, fontSize: 9))
                    ])),
                _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      try {
                        app.changeCartQuantity(line.product.id, -1);
                      } on StateError catch (error) {
                        _message(error.message, error: true);
                      }
                    }),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text('${line.quantity}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800))),
                _QtyButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      try {
                        app.changeCartQuantity(line.product.id, 1);
                      } on StateError catch (error) {
                        _message(error.message, error: true);
                      }
                    }),
                const SizedBox(width: 8),
                SizedBox(
                    width: 55,
                    child: Text(money(line.total),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700))),
              ]))),
        ],
        const Divider(height: 23, color: ArcadeColors.divider),
        Row(children: [
          const Expanded(
              child: Text('Subtotal',
                  style: TextStyle(color: ArcadeColors.muted, fontSize: 10))),
          Text(money(app.cartSubtotal),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))
        ]),
        const SizedBox(height: 9),
        Row(children: [
          const Expanded(
              child: Text('Desconto',
                  style: TextStyle(color: ArcadeColors.muted, fontSize: 10))),
          TextButton.icon(
              onPressed: app.cart.isEmpty ? null : () => _discountDialog(app),
              icon: const Icon(Icons.local_offer_outlined, size: 13),
              label: Text(
                  app.cartDiscount > 0 ? money(app.cartDiscount) : 'Adicionar',
                  style: const TextStyle(fontSize: 9)))
        ]),
        const Divider(height: 18, color: ArcadeColors.divider),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Expanded(
              child: Text('TOTAL',
                  style: TextStyle(
                      color: ArcadeColors.muted,
                      fontSize: 9,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800))),
          Text(money(app.cartTotal),
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  letterSpacing: -.8,
                  color: ArcadeColors.ink))
        ]),
        const SizedBox(height: 15),
        SizedBox(
            width: double.infinity,
            child: NeonButton(
                label: 'FINALIZAR VENDA',
                icon: Icons.bolt_rounded,
                onPressed:
                    app.cart.isEmpty ? null : () => _paymentDialog(app))),
        const SizedBox(height: 8),
        const Center(
            child: Text('F4 · FINALIZAR     ESC · LIMPAR CARRINHO',
                style: TextStyle(
                    fontSize: 7,
                    color: ArcadeColors.muted,
                    letterSpacing: .5))),
      ]));

  Future<void> _openCash(AppController app) async {
    final amount = TextEditingController(text: app.isDemo ? '150' : '');
    final value = await showDialog<double>(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: arcadeSurfaceColor(context),
                title: const Text('Abrir caixa',
                    style: TextStyle(fontFamily: 'SpaceGrotesk')),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informe o fundo de troco inicial.',
                          style: TextStyle(
                              color: ArcadeColors.muted, fontSize: 12)),
                      const SizedBox(height: 14),
                      TextField(
                          controller: amount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Valor inicial', prefixText: 'R\$ '))
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  NeonButton(
                      label: 'ABRIR CAIXA',
                      onPressed: () => Navigator.pop(
                          context, parseMoney(amount.text) ?? double.nan))
                ]));
    if (value == null) return;
    try {
      await app.openCash(value);
    } on Object catch (error) {
      _message(error.toString(), error: true);
    }
  }

  Future<void> _discountDialog(AppController app) async {
    final amount =
        TextEditingController(text: app.cartDiscount.toStringAsFixed(2));
    final value = await showDialog<double>(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: arcadeSurfaceColor(context),
                title: const Text('Desconto autorizado',
                    style: TextStyle(fontFamily: 'SpaceGrotesk')),
                content: TextField(
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Valor do desconto', prefixText: 'R\$ ')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  NeonButton(
                      label: 'APLICAR',
                      onPressed: () => Navigator.pop(context,
                          double.tryParse(amount.text.replaceAll(',', '.'))))
                ]));
    if (value == null) return;
    try {
      app.setDiscount(value);
    } on StateError catch (error) {
      _message(error.message, error: true);
    }
  }

  Future<void> _paymentDialog(AppController app) async {
    final payments = await showDialog<List<PaymentPart>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PaymentDialog(total: app.cartTotal));
    if (payments == null) return;
    try {
      await app.completeSale(payments);
      if (!mounted) return;
      await showDialog<void>(
          context: context, builder: (context) => const _SaleSuccessDialog());
    } on Object catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Bad state: ', ''), error: true);
      }
    }
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onAdd});
  final AppProduct product;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final unavailable = product.stock == 0;
    return GlassCard(
        glow: unavailable ? null : ArcadeColors.cyan,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      ArcadeColors.cyan.withValues(alpha: .14),
                      ArcadeColors.purple.withValues(alpha: .12)
                    ]),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(product.icon, color: ArcadeColors.cyan, size: 20)),
            const Spacer(),
            if (product.isLow)
              StatusChip(label: 'Baixo', color: ArcadeColors.red, dot: false)
          ]),
          const SizedBox(height: 12),
          Text(product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, height: 1.25)),
          const SizedBox(height: 4),
          Text('${product.category} · ${product.stock} un.',
              style: const TextStyle(color: ArcadeColors.muted, fontSize: 9)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Text(money(product.price),
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 17,
                        fontWeight: FontWeight.w700))),
            Material(
                color: unavailable
                    ? arcadeSoftSurfaceColor(context)
                    : ArcadeColors.cyan.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                    onTap: unavailable ? null : onAdd,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                            unavailable
                                ? Icons.block_rounded
                                : Icons.add_rounded,
                            color: unavailable
                                ? ArcadeColors.muted
                                : ArcadeColors.cyan,
                            size: 17))))
          ]),
        ]));
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
          width: 23,
          height: 23,
          decoration: BoxDecoration(
              color: arcadeSoftSurfaceColor(context),
              borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, color: ArcadeColors.cyan, size: 14)));
}

class _ClosedRegister extends StatelessWidget {
  const _ClosedRegister({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(22),
          child: GlassCard(
              glow: ArcadeColors.yellow,
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: ArcadeColors.yellow.withValues(alpha: .1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.lock_clock_outlined,
                        color: ArcadeColors.yellow, size: 27)),
                const SizedBox(height: 18),
                const Text('CAIXA FECHADO',
                    style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 11,
                        color: ArcadeColors.yellow)),
                const SizedBox(height: 11),
                const Text('Abra um turno de caixa para liberar as vendas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ArcadeColors.muted, fontSize: 12)),
                const SizedBox(height: 19),
                NeonButton(
                    label: 'ABRIR CAIXA',
                    icon: Icons.lock_open_rounded,
                    onPressed: onOpen),
              ]))));
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.total});
  final double total;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _methods = <PaymentMethod>[PaymentMethod.cash];
  final _amounts = <TextEditingController>[];
  final _received = <TextEditingController>[];
  String? _error;

  @override
  void initState() {
    super.initState();
    final initialAmount = widget.total.toStringAsFixed(2);
    _amounts.add(TextEditingController(text: initialAmount));
    _received.add(TextEditingController(text: initialAmount));
  }

  @override
  void dispose() {
    for (final controller in _amounts) {
      controller.dispose();
    }
    for (final controller in _received) {
      controller.dispose();
    }
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      parseMoney(controller.text) ?? 0;

  double get _sum => _amounts.fold(0, (sum, field) => sum + _parse(field));

  double _changeAt(int index) =>
      math.max(0, _parse(_received[index]) - _parse(_amounts[index]));

  List<PaymentMethod> _availableMethodsFor(int index) => PaymentMethod.values
      .where(
        (method) =>
            method == _methods[index] ||
            !_methods.asMap().entries.any(
                  (entry) => entry.key != index && entry.value == method,
                ),
      )
      .toList();

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: arcadeSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: ArcadeColors.cyan.withValues(alpha: .22)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(23),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pagamento',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Escolha uma ou mais formas para concluir.',
                    style: TextStyle(color: ArcadeColors.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 17),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: ArcadeColors.cyan.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TOTAL A PAGAR',
                            style: TextStyle(
                              color: ArcadeColors.muted,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          money(widget.total),
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ArcadeColors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  for (var i = 0; i < _methods.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<PaymentMethod>(
                            initialValue: _methods[i],
                            decoration:
                                const InputDecoration(labelText: 'Forma'),
                            items: _availableMethodsFor(i)
                                .map(
                                  (method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(_label(method)),
                                  ),
                                )
                                .toList(),
                            onChanged: (method) => setState(() {
                              if (method != null) {
                                _methods[i] = method;
                                _error = null;
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _amounts[i],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Valor',
                              prefixText: 'R\$ ',
                            ),
                          ),
                        ),
                        if (_methods.length > 1)
                          IconButton(
                            onPressed: () => setState(() {
                              _methods.removeAt(i);
                              _amounts.removeAt(i).dispose();
                              _received.removeAt(i).dispose();
                              _error = null;
                            }),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: ArcadeColors.red,
                              size: 17,
                            ),
                          ),
                      ],
                    ),
                    if (_methods[i] == PaymentMethod.cash) ...[
                      const SizedBox(height: 9),
                      TextField(
                        controller: _received[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Valor recebido em dinheiro',
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Troco',
                              style: TextStyle(
                                color: ArcadeColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            money(_changeAt(i)),
                            style: const TextStyle(
                              color: ArcadeColors.lime,
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 11),
                  ],
                  if (_methods.length < PaymentMethod.values.length)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        final next = PaymentMethod.values.firstWhere(
                          (method) => !_methods.contains(method),
                        );
                        final remaining = math.max(0, widget.total - _sum);
                        final amount = remaining.toStringAsFixed(2);
                        _methods.add(next);
                        _amounts.add(TextEditingController(text: amount));
                        _received.add(TextEditingController(text: amount));
                        _error = null;
                      }),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 16),
                      label: const Text('Dividir entre formas de pagamento'),
                    ),
                  const Divider(color: ArcadeColors.divider),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total pago',
                          style: TextStyle(
                            color: ArcadeColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        money(_sum),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: (_sum - widget.total).abs() < .01
                              ? ArcadeColors.lime
                              : ArcadeColors.yellow,
                        ),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: ArcadeColors.red,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      label: 'CONFIRMAR PAGAMENTO',
                      icon: Icons.check_rounded,
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  String _label(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'Dinheiro',
        PaymentMethod.pix => 'PIX',
        PaymentMethod.debit => 'Débito',
        PaymentMethod.credit => 'Crédito',
      };

  void _confirm() {
    final invalidValues = _methods.asMap().entries.any((entry) {
      final amount = _parse(_amounts[entry.key]);
      if (!amount.isFinite || amount <= 0) return true;
      if (entry.value != PaymentMethod.cash) return false;
      final received = _parse(_received[entry.key]);
      return !received.isFinite || received < amount;
    });
    if (invalidValues) {
      setState(() => _error = 'Confira os valores recebidos e os pagamentos.');
      return;
    }
    if (_methods.toSet().length != _methods.length) {
      setState(() => _error = 'Escolha formas de pagamento diferentes.');
      return;
    }
    if (!widget.total.isFinite ||
        !_sum.isFinite ||
        (_sum - widget.total).abs() > .01) {
      setState(
        () => _error = 'A soma dos pagamentos precisa ser igual ao total.',
      );
      return;
    }
    final parts = List.generate(
      _methods.length,
      (i) => PaymentPart(
        method: _methods[i],
        amount: _parse(_amounts[i]),
        amountReceived: _methods[i] == PaymentMethod.cash
            ? _parse(_received[i])
            : _parse(_amounts[i]),
      ),
    );
    Navigator.pop(context, parts);
  }
}

class _SaleSuccessDialog extends StatelessWidget {
  const _SaleSuccessDialog();
  @override
  Widget build(BuildContext context) => Dialog(
      backgroundColor: arcadeSurfaceColor(context),
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
            height: 270,
            width: 380,
            child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 1500),
                builder: (context, progress, _) =>
                    CustomPaint(painter: _PixelConfettiPainter(progress)))),
        Padding(
            padding: const EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 73,
                  height: 73,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ArcadeColors.lime.withValues(alpha: .13),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: ArcadeColors.lime.withValues(alpha: .25),
                            blurRadius: 25)
                      ]),
                  child: const Icon(Icons.check_rounded,
                      size: 42, color: ArcadeColors.lime)),
              const SizedBox(height: 17),
              const Text('FICHA CONFIRMADA!',
                  style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 11,
                      color: ArcadeColors.lime)),
              const SizedBox(height: 10),
              const Text('Venda concluída com sucesso.',
                  style: TextStyle(color: ArcadeColors.muted, fontSize: 12)),
              const SizedBox(height: 20),
              NeonButton(
                  label: 'PRÓXIMA VENDA',
                  onPressed: () => Navigator.pop(context)),
            ])),
      ]));
}

class _PixelConfettiPainter extends CustomPainter {
  _PixelConfettiPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      ArcadeColors.cyan,
      ArcadeColors.magenta,
      ArcadeColors.lime,
      ArcadeColors.yellow,
      ArcadeColors.purple
    ];
    for (var i = 0; i < 28; i++) {
      final x = ((i * 47 + 13) % size.width.toInt()).toDouble();
      final y =
          (((i * 83 + 25) + progress * 140) % size.height.toInt()).toDouble();
      final rect = Rect.fromLTWH(x, y, i % 3 == 0 ? 5 : 3, i % 3 == 0 ? 5 : 3);
      canvas.drawRect(
          rect,
          Paint()
            ..color =
                colors[i % colors.length].withValues(alpha: .2 + (i % 4) * .1));
    }
  }

  @override
  bool shouldRepaint(covariant _PixelConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
