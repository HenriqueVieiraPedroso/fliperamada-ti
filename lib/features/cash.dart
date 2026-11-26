import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/money.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class CashScreen extends StatelessWidget {
  const CashScreen({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) =>
          Consumer<AppController>(builder: (context, app, _) {
            final width = constraints.maxWidth;
            final pad = width < 620 ? 16.0 : 26.0;
            final contentWidth = width - 2 * pad;
            final narrow = contentWidth < 960;
            return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 23, pad, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title: 'Caixa',
                          subtitle:
                              'Um turno organizado, do primeiro troco ao fechamento.'),
                      const SizedBox(height: 19),
                      GlassCard(
                          glow: app.cashOpen
                              ? ArcadeColors.lime
                              : ArcadeColors.yellow,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Row(children: [
                                        Container(
                                            width: 48,
                                            height: 48,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: (app.cashOpen
                                                        ? ArcadeColors.lime
                                                        : ArcadeColors.yellow)
                                                    .withValues(alpha: .1),
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Icon(
                                                app.cashOpen
                                                    ? Icons.lock_open_rounded
                                                    : Icons.lock_clock_outlined,
                                                color: app.cashOpen
                                                    ? ArcadeColors.lime
                                                    : ArcadeColors.yellow,
                                                size: 22)),
                                        const SizedBox(width: 13),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              StatusChip(
                                                  label: app.cashOpen
                                                      ? 'Aberto'
                                                      : 'Fechado',
                                                  color: app.cashOpen
                                                      ? ArcadeColors.lime
                                                      : ArcadeColors.yellow),
                                              const SizedBox(height: 7),
                                              Text(
                                                  app.cashOpen
                                                      ? 'Turno em andamento'
                                                      : 'Nenhum turno ativo',
                                                  style: TextStyle(
                                                      color:
                                                          arcadeSemanticColor(
                                                              context,
                                                              ArcadeColors
                                                                  .muted),
                                                      fontSize: 12))
                                            ]),
                                      ])),
                                      if (!narrow)
                                        Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if (!app.cashOpen)
                                                NeonButton(
                                                    label: 'ABRIR CAIXA',
                                                    icon:
                                                        Icons.lock_open_rounded,
                                                    compact: true,
                                                    onPressed: () =>
                                                        _openDialog(
                                                            context, app)),
                                              if (app.cashOpen) ...[
                                                NeonButton(
                                                    label: 'SUPRIMENTO',
                                                    icon: Icons
                                                        .add_circle_outline_rounded,
                                                    compact: true,
                                                    onPressed: () =>
                                                        _adjustDialog(
                                                            context, app,
                                                            withdrawal: false)),
                                                NeonButton(
                                                    label: 'SANGRIA',
                                                    icon: Icons
                                                        .remove_circle_outline_rounded,
                                                    danger: true,
                                                    compact: true,
                                                    onPressed: app
                                                            .role.canWithdraw
                                                        ? () => _adjustDialog(
                                                            context, app,
                                                            withdrawal: true)
                                                        : null),
                                                NeonButton(
                                                    label: 'FECHAR CAIXA',
                                                    icon: Icons.lock_rounded,
                                                    compact: true,
                                                    onPressed: () =>
                                                        _closeWizard(
                                                            context, app)),
                                              ],
                                            ]),
                                    ]),
                                Divider(
                                    height: 29,
                                    color: arcadeBorderColor(context)),
                                Wrap(spacing: 35, runSpacing: 15, children: [
                                  _Info(
                                      label: 'OPERADOR',
                                      value: app.user?.name ?? '—'),
                                  _Info(
                                      label: 'ABERTURA',
                                      value: app.cashOpenedAt == null
                                          ? '—'
                                          : '${shortDate(app.cashOpenedAt)}  ${shortTime(app.cashOpenedAt!)}'),
                                  _Info(
                                      label: 'FUNDO DE TROCO',
                                      value: money(app.openingFloat),
                                      highlight: ArcadeColors.cyan),
                                  _Info(
                                      label: 'SALDO EM DINHEIRO',
                                      value: money(app.cashBalance),
                                      highlight: arcadeSemanticColor(
                                          context, ArcadeColors.lime)),
                                ]),
                                if (narrow) ...[
                                  const SizedBox(height: 16),
                                  Wrap(spacing: 8, runSpacing: 8, children: [
                                    if (!app.cashOpen)
                                      NeonButton(
                                          label: 'ABRIR CAIXA',
                                          icon: Icons.lock_open_rounded,
                                          compact: true,
                                          onPressed: () =>
                                              _openDialog(context, app)),
                                    if (app.cashOpen) ...[
                                      NeonButton(
                                          label: 'SUPRIMENTO',
                                          icon:
                                              Icons.add_circle_outline_rounded,
                                          compact: true,
                                          onPressed: () => _adjustDialog(
                                              context, app,
                                              withdrawal: false)),
                                      NeonButton(
                                          label: 'SANGRIA',
                                          icon: Icons
                                              .remove_circle_outline_rounded,
                                          danger: true,
                                          compact: true,
                                          onPressed: app.role.canWithdraw
                                              ? () => _adjustDialog(
                                                  context, app,
                                                  withdrawal: true)
                                              : null),
                                      NeonButton(
                                          label: 'FECHAR',
                                          icon: Icons.lock_rounded,
                                          compact: true,
                                          onPressed: () =>
                                              _closeWizard(context, app)),
                                    ],
                                  ]),
                                ],
                              ])),
                      const SizedBox(height: 15),
                      Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            SizedBox(
                                width:
                                    narrow ? contentWidth : contentWidth * .62,
                                child: GlassCard(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      const PanelHeading(
                                          'Movimentações do turno',
                                          subtitle:
                                              'Vendas, suprimentos e sangrias'),
                                      const SizedBox(height: 17),
                                      if (app.cashEntries.isEmpty)
                                        const SizedBox(
                                            height: 170, child: EmptyState())
                                      else
                                        ...app.cashEntries.take(8).map(
                                            (entry) =>
                                                _MovementTile(entry: entry)),
                                    ]))),
                            SizedBox(
                                width:
                                    narrow ? contentWidth : contentWidth * .34,
                                child: GlassCard(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      const PanelHeading('Recebimentos',
                                          subtitle: 'Por forma de pagamento'),
                                      const SizedBox(height: 10),
                                      Center(
                                          child: NeonDonut(
                                              values: _methodValues(app),
                                              colors: const [
                                                ArcadeColors.lime,
                                                ArcadeColors.cyan,
                                                ArcadeColors.purple,
                                                ArcadeColors.magenta
                                              ],
                                              total: money(app.sessionSales
                                                  .fold<double>(
                                                      0,
                                                      (sum, sale) =>
                                                          sum + sale.total)),
                                              label: 'VENDAS')),
                                      const SizedBox(height: 10),
                                      _PaymentLegend(
                                          values: _methodValues(app)),
                                    ]))),
                          ]),
                    ]));
          }));

  List<double> _methodValues(AppController app) => PaymentMethod.values
      .map((method) => app.sessionPaymentTotals[method] ?? 0)
      .toList();

  Future<void> _openDialog(BuildContext context, AppController app) async {
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
                      Text('O valor será registrado como fundo de troco.',
                          style: TextStyle(
                              color: arcadeSemanticColor(
                                  context, ArcadeColors.muted),
                              fontSize: 12)),
                      const SizedBox(height: 14),
                      TextField(
                          controller: amount,
                          autofocus: true,
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
                      label: 'ABRIR TURNO',
                      onPressed: () =>
                          Navigator.pop(context, _parse(amount.text)))
                ]));
    if (value == null) return;
    try {
      await app.openCash(value);
    } on Object catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  Future<void> _adjustDialog(BuildContext context, AppController app,
      {required bool withdrawal}) async {
    final amount = TextEditingController();
    final note = TextEditingController();
    final result = await showModalBottomSheet<({double amount, String note})>(
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: arcadeSurfaceColor(context),
                title: Text(
                    withdrawal ? 'Registrar sangria' : 'Registrar suprimento',
                    style: const TextStyle(fontFamily: 'SpaceGrotesk')),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Valor', prefixText: 'R\$ ')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: note,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Justificativa obrigatória',
                          hintText:
                              'Ex.: reforço de troco / retirada para cofre'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  NeonButton(
                      label: withdrawal
                          ? 'CONFIRMAR SANGRIA'
                          : 'CONFIRMAR SUPRIMENTO',
                      danger: withdrawal,
                      onPressed: () => Navigator.pop(context,
                          (amount: _parse(amount.text), note: note.text)))
                ]));
    if (result == null) return;
    try {
      await app.recordCashAdjustment(
          withdrawal: withdrawal,
          amount: result.amount,
          justification: result.note);
    } on Object catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  Future<void> _closeWizard(BuildContext context, AppController app) async {
    final counted =
        await showDialog<({Map<String, double> values, String note})>(
            context: context,
            barrierDismissible: false,
            builder: (context) => _CloseWizard(app: app));
    if (counted == null) return;
    try {
      await app.closeCash(counted: counted.values, note: counted.note);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fechamento do caixa concluído.')));
      }
    } on Object catch (error) {
      if (context.mounted) _error(context, error);
    }
  }

  void _error(BuildContext context, Object error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
          backgroundColor: const Color(0xFF8B1E2D)));
  double _parse(String value) => parseMoney(value) ?? double.nan;
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value, this.highlight});
  final String label;
  final String value;
  final Color? highlight;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: arcadeSemanticColor(context, ArcadeColors.muted),
                fontSize: 10,
                letterSpacing: .9,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 13,
                color: highlight == null
                    ? Theme.of(context).colorScheme.onSurface
                    : arcadeSemanticColor(context, highlight!),
                fontWeight: FontWeight.w700))
      ]);
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.entry});
  final CashEntry entry;
  @override
  Widget build(BuildContext context) {
    final color = arcadeSemanticColor(
        context,
        switch (entry.type) {
          'Sangria' => ArcadeColors.red,
          'Suprimento' => ArcadeColors.lime,
          'Venda' => ArcadeColors.cyan,
          'Fechamento' => ArcadeColors.yellow,
          _ => ArcadeColors.purple
        });
    final icon = switch (entry.type) {
      'Sangria' => Icons.south_west_rounded,
      'Suprimento' => Icons.north_east_rounded,
      'Venda' => Icons.point_of_sale_rounded,
      'Fechamento' => Icons.lock_rounded,
      _ => Icons.account_balance_wallet_outlined
    };
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
                width: 31,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 15)),
            Container(width: 1, height: 28, color: arcadeBorderColor(context))
          ]),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(entry.type,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                    entry.note.isEmpty
                        ? 'Operador · ${shortTime(entry.createdAt)}'
                        : '${entry.note} · ${shortTime(entry.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: arcadeSemanticColor(context, ArcadeColors.muted),
                        fontSize: 10))
              ])),
          Text(money(entry.amount),
              style: TextStyle(
                  color: color,
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]));
  }
}

class _PaymentLegend extends StatelessWidget {
  const _PaymentLegend({required this.values});
  final List<double> values;
  @override
  Widget build(BuildContext context) => Column(
      children: List.generate(
          4,
          (i) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                        color: [
                          arcadeSemanticColor(context, ArcadeColors.lime),
                          ArcadeColors.cyan,
                          ArcadeColors.purple,
                          ArcadeColors.magenta
                        ][i],
                        shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(['Dinheiro', 'PIX', 'Débito', 'Crédito'][i],
                        style: TextStyle(
                            color: arcadeSemanticColor(
                                context, ArcadeColors.muted),
                            fontSize: 11))),
                Text(money(values[i]),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700))
              ]))));
}

class _CloseWizard extends StatefulWidget {
  const _CloseWizard({required this.app});
  final AppController app;
  @override
  State<_CloseWizard> createState() => _CloseWizardState();
}

class _CloseWizardState extends State<_CloseWizard> {
  int _step = 0;
  final _fields = {
    for (final key in ['Dinheiro', 'PIX', 'Débito', 'Crédito'])
      key: TextEditingController()
  };
  final _note = TextEditingController();
  String? _error;
  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  double _value(String key) => parseMoney(_fields[key]?.text ?? '') ?? 0;
  double get _difference => _fields.keys
      .fold<double>(0, (sum, key) => sum + _value(key) - _expected[key]!);
  Map<String, double> get _expected => widget.app.expectedCash;
  bool get _divergent =>
      _fields.keys.any((key) => (_value(key) - _expected[key]!).abs() > .001);
  Map<String, double> get _counts =>
      {for (final key in _fields.keys) key: _value(key)};

  @override
  Widget build(BuildContext context) => Dialog(
      backgroundColor: arcadeSurfaceColor(context),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: ArcadeColors.cyan.withValues(alpha: .18))),
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
              padding: const EdgeInsets.all(23),
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Fechamento de caixa',
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700))),
                      Text('ETAPA ${_step + 1} DE 2',
                          style: const TextStyle(
                              color: ArcadeColors.cyan,
                              fontSize: 9,
                              letterSpacing: .7,
                              fontWeight: FontWeight.w800))
                    ]),
                    const SizedBox(height: 6),
                    Text(
                        _step == 0
                            ? 'Informe o valor contado por forma de pagamento.'
                            : 'Compare o valor contado com o esperado.',
                        style: TextStyle(
                            color: arcadeSemanticColor(
                                context, ArcadeColors.muted),
                            fontSize: 12)),
                    const SizedBox(height: 18),
                    if (_step == 0) ...[
                      for (final key in _fields.keys)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: TextField(
                                controller: _fields[key],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                    labelText: key, prefixText: 'R\$ '))),
                    ] else ...[
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          decoration: BoxDecoration(
                              color: arcadeSoftSurfaceColor(context),
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: Text('FORMA',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: arcadeSemanticColor(
                                              context, ArcadeColors.muted)))),
                              Text('ESPERADO',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: arcadeSemanticColor(
                                          context, ArcadeColors.muted))),
                              const SizedBox(width: 18),
                              Text('CONTADO',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: arcadeSemanticColor(
                                          context, ArcadeColors.muted)))
                            ]),
                            for (final key in _fields.keys)
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(key,
                                            style: TextStyle(
                                                color: arcadeSemanticColor(
                                                    context,
                                                    ArcadeColors.muted),
                                                fontSize: 11))),
                                    Text(money(_expected[key]!),
                                        style: const TextStyle(fontSize: 10)),
                                    const SizedBox(width: 12),
                                    Text(money(_value(key)),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800))
                                  ])),
                            Divider(color: arcadeBorderColor(context)),
                            Row(children: [
                              const Expanded(
                                  child: Text('DIFERENÇA',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          letterSpacing: .8))),
                              Text(money(_difference.abs()),
                                  style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: _difference.abs() < .01
                                          ? ArcadeColors.lime
                                          : _difference > 0
                                              ? ArcadeColors.yellow
                                              : ArcadeColors.red))
                            ]),
                            const SizedBox(height: 6),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: StatusChip(
                                    label: !_divergent
                                        ? 'Caixa bateu'
                                        : _difference.abs() < .01
                                            ? 'Diferenças entre formas'
                                            : _difference > 0
                                                ? 'Sobra de caixa'
                                                : 'Quebra de caixa',
                                    color: _difference.abs() < .01
                                        ? ArcadeColors.lime
                                        : _difference > 0
                                            ? ArcadeColors.yellow
                                            : ArcadeColors.red)),
                          ])),
                      if (_divergent) ...[
                        const SizedBox(height: 13),
                        TextField(
                            controller: _note,
                            minLines: 2,
                            maxLines: 3,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                                labelText: 'Observação obrigatória',
                                hintText: 'Descreva a diferença encontrada'))
                      ],
                    ],
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: ArcadeColors.red, fontSize: 10))),
                    const SizedBox(height: 18),
                    Row(children: [
                      TextButton(
                          onPressed: _step == 0
                              ? () => Navigator.pop(context)
                              : () => setState(() {
                                    _step = 0;
                                    _error = null;
                                  }),
                          child: Text(_step == 0 ? 'Cancelar' : 'Voltar')),
                      const Spacer(),
                      NeonButton(
                          label: _step == 0
                              ? 'REVISAR FECHAMENTO'
                              : 'CONCLUIR CAIXA',
                          icon: _step == 0
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_rounded,
                          onPressed: _next)
                    ]),
                  ])))));

  void _next() {
    if (_step == 0 &&
        _fields.values.any((field) =>
            parseMoney(field.text) == null ||
            (parseMoney(field.text) ?? -1) < 0)) {
      setState(() => _error =
          'Informe os quatro valores contados (zero quando não houver recebimentos).');
      return;
    }
    if (_step == 0) {
      setState(() {
        _step = 1;
        _error = null;
      });
      return;
    }
    if (_divergent && _note.text.trim().length < 3) {
      setState(() => _error = 'Informe uma observação antes de concluir.');
      return;
    }
    Navigator.pop(context, (values: _counts, note: _note.text));
  }
}
