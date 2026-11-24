import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) =>
          Consumer<AppController>(builder: (context, app, _) {
            final width = constraints.maxWidth;
            final pad = width < 620 ? 16.0 : 26.0;
            final dataWidth = width - pad * 2;
            final kpiCount = dataWidth > 1120
                ? 4
                : dataWidth > 600
                    ? 2
                    : 1;
            final kpiWidth = (dataWidth - (kpiCount - 1) * 12) / kpiCount;
            final chartWide = dataWidth > 850;
            final revenue = app.revenue;
            final spark = app.periodSeries;
            final paymentValues = PaymentMethod.values
                .map((method) => app.sales
                    .fold<double>(0, (sum, sale) => sum + sale.paidBy(method)))
                .toList();
            final paymentColors = const [
              ArcadeColors.lime,
              ArcadeColors.cyan,
              ArcadeColors.purple,
              ArcadeColors.magenta
            ];
            final products = app.products;
            final categoryValues = ['Fichas', 'Bebidas', 'Snacks']
                .map((category) => app.categoryTotals[category] ?? 0)
                .toList();
            final categoryMax = categoryValues.fold<double>(1, math.max);
            final top = app.topProducts;
            final today = DateTime.now();
            final salutation = today.hour < 12
                ? 'Bom dia'
                : today.hour < 18
                    ? 'Boa tarde'
                    : 'Boa noite';
            return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 24, pad, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title:
                              '$salutation, ${app.user?.name.split(' ').first ?? 'equipe'}!',
                          subtitle: 'A operação da arena em uma só tela.',
                          trailing: SegmentedPills(
                              items: const ['Hoje', '7 dias', 'Mês'],
                              value: app.selectedPeriod,
                              onChanged: app.setPeriod)),
                      const SizedBox(height: 22),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Faturamento do período',
                                value: money(revenue),
                                color: ArcadeColors.cyan,
                                change: app.revenueChange,
                                icon: Icons.trending_up_rounded,
                                spark: spark)),
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Fichas vendidas',
                                value: '${app.tokensSold}',
                                color: ArcadeColors.magenta,
                                change: app.itemChange,
                                icon: Icons.toll_rounded,
                                spark: app.tokenSeries)),
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Ticket médio',
                                value: money(app.ticketAverage),
                                color: ArcadeColors.lime,
                                change: app.ticketChange,
                                icon: Icons.receipt_long_outlined,
                                spark: app.ticketSeries)),
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Saldo do caixa atual',
                                value: money(app.cashBalance),
                                color: ArcadeColors.yellow,
                                change: app.cashOpen ? 'ABERTO' : 'FECHADO',
                                icon: Icons.account_balance_wallet_outlined,
                                spark: app.cashSeries)),
                      ]),
                      const SizedBox(height: 14),
                      Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            SizedBox(
                                width: chartWide ? dataWidth * .64 : dataWidth,
                                child: GlassCard(
                                    glow: ArcadeColors.cyan,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PanelHeading('Faturamento da arena',
                                              subtitle:
                                                  '${app.selectedPeriod} · comparativo com período anterior',
                                              trailing: HeaderBadge(
                                                  icon: Icons.circle,
                                                  label: app.isDemo
                                                      ? 'DEMONSTRAÇÃO'
                                                      : 'REGISTROS',
                                                  color: ArcadeColors.lime)),
                                          const SizedBox(height: 15),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                    child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                            money(revenue),
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'SpaceGrotesk',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    23)))),
                                                const SizedBox(width: 10),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4),
                                                    child: Text(
                                                        app.revenueChange,
                                                        style: TextStyle(
                                                            color: ArcadeColors
                                                                .lime,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)))
                                              ]),
                                          const SizedBox(height: 10),
                                          SmoothAreaChart(
                                              values: app.periodSeries,
                                              previous:
                                                  app.previousPeriodSeries,
                                              color: ArcadeColors.cyan),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: (app.selectedPeriod ==
                                                          'Hoje'
                                                      ? [
                                                          '00h',
                                                          '04h',
                                                          '08h',
                                                          '12h',
                                                          '16h',
                                                          '20h',
                                                          '24h'
                                                        ]
                                                      : [
                                                          'Início',
                                                          'Meio',
                                                          'Fim'
                                                        ])
                                                  .map((label) => Text(label,
                                                      style: TextStyle(
                                                          color: ArcadeColors
                                                              .muted,
                                                          fontSize: 9)))
                                                  .toList()),
                                          const SizedBox(height: 7),
                                          Wrap(
                                              spacing: 15,
                                              runSpacing: 8,
                                              children: [
                                                Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                          width: 16,
                                                          height: 2,
                                                          color: ArcadeColors
                                                              .cyan),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                          'Período atual',
                                                          style: TextStyle(
                                                              color:
                                                                  ArcadeColors
                                                                      .muted,
                                                              fontSize: 9)),
                                                    ]),
                                                Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                          width: 16,
                                                          height: 1,
                                                          color: ArcadeColors
                                                              .purple),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                          'Período anterior',
                                                          style: TextStyle(
                                                              color:
                                                                  ArcadeColors
                                                                      .muted,
                                                              fontSize: 9))
                                                    ]),
                                              ]),
                                        ]))),
                            SizedBox(
                                width: chartWide ? dataWidth * .32 : dataWidth,
                                child: GlassCard(
                                    glow: ArcadeColors.magenta,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const PanelHeading(
                                              'Formas de pagamento',
                                              subtitle:
                                                  'Recebimentos no período'),
                                          const SizedBox(height: 10),
                                          Center(
                                              child: NeonDonut(
                                                  values: paymentValues,
                                                  colors: paymentColors,
                                                  total: money(revenue))),
                                          const SizedBox(height: 10),
                                          ...List.generate(
                                              4,
                                              (i) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Row(children: [
                                                    Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                paymentColors[
                                                                    i],
                                                            shape: BoxShape
                                                                .circle)),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: Text(
                                                            [
                                                              'Dinheiro',
                                                              'PIX',
                                                              'Débito',
                                                              'Crédito'
                                                            ][i],
                                                            style: const TextStyle(
                                                                color:
                                                                    ArcadeColors
                                                                        .muted,
                                                                fontSize: 10))),
                                                    Text(
                                                        money(paymentValues[i]),
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700))
                                                  ]))),
                                        ]))),
                          ]),
                      const SizedBox(height: 14),
                      Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            SizedBox(
                                width: chartWide ? dataWidth * .315 : dataWidth,
                                child: GlassCard(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      const PanelHeading('Vendas por categoria',
                                          subtitle: 'Fichas e conveniência'),
                                      const SizedBox(height: 22),
                                      for (var i = 0; i < 3; i++) ...[
                                        NeonBar(
                                            label: [
                                              'Fichas',
                                              'Bebidas',
                                              'Snacks'
                                            ][i],
                                            value: categoryValues[i],
                                            max: categoryMax,
                                            color: [
                                              ArcadeColors.cyan,
                                              ArcadeColors.magenta,
                                              ArcadeColors.yellow
                                            ][i],
                                            valueLabel:
                                                money(categoryValues[i])),
                                        const SizedBox(height: 17),
                                      ],
                                    ]))),
                            SizedBox(
                                width: chartWide ? dataWidth * .315 : dataWidth,
                                child: GlassCard(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      const PanelHeading('Mapa de movimento',
                                          subtitle:
                                              'Picos por dia da semana × horário'),
                                      const SizedBox(height: 18),
                                      _Heatmap(values: app.heatmap),
                                      const SizedBox(height: 13),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Text('MENOS',
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    color: ArcadeColors.muted)),
                                            const SizedBox(width: 7),
                                            ...[
                                              ArcadeColors.purple
                                                  .withValues(alpha: .25),
                                              ArcadeColors.purple,
                                              const Color(0xFF4F88E8),
                                              ArcadeColors.cyan
                                            ].map((color) => Container(
                                                margin: const EdgeInsets.only(
                                                    left: 3),
                                                width: 11,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)))),
                                            const SizedBox(width: 7),
                                            const Text('MAIS',
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    color: ArcadeColors.muted))
                                          ]),
                                    ]))),
                            SizedBox(
                                width: chartWide ? dataWidth * .315 : dataWidth,
                                child: GlassCard(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      PanelHeading('Top 5 produtos',
                                          subtitle: 'Mais procurados',
                                          trailing: const Icon(
                                              Icons.north_east_rounded,
                                              color: ArcadeColors.muted,
                                              size: 15)),
                                      const SizedBox(height: 17),
                                      if (top.isEmpty)
                                        const EmptyState()
                                      else
                                        for (var i = 0;
                                            i < math.min(5, top.length);
                                            i++) ...[
                                          Row(children: [
                                            Container(
                                                width: 23,
                                                height: 23,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: [
                                                      ArcadeColors.cyan,
                                                      ArcadeColors.magenta,
                                                      ArcadeColors.purple,
                                                      ArcadeColors.yellow,
                                                      ArcadeColors.lime
                                                    ][i]
                                                        .withValues(alpha: .12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Text('0${i + 1}',
                                                    style: TextStyle(
                                                        color: [
                                                          ArcadeColors.cyan,
                                                          ArcadeColors.magenta,
                                                          ArcadeColors.purple,
                                                          ArcadeColors.yellow,
                                                          ArcadeColors.lime
                                                        ][i],
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w900))),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(top[i].key,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                            Text('${top[i].value.toInt()} un.',
                                                style: const TextStyle(
                                                    color: ArcadeColors.muted,
                                                    fontSize: 9))
                                          ]),
                                          const SizedBox(height: 10),
                                          NeonBar(
                                              label: '',
                                              value: top[i].value,
                                              max: top.first.value,
                                              color: ArcadeColors.cyan,
                                              valueLabel:
                                                  '${top[i].value.toInt()} un.'),
                                          if (i < math.min(5, top.length) - 1)
                                            const SizedBox(height: 12),
                                        ],
                                    ]))),
                          ]),
                      const SizedBox(height: 14),
                      Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            SizedBox(
                                width: chartWide ? dataWidth * .53 : dataWidth,
                                child: GlassCard(
                                    glow: ArcadeColors.red,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PanelHeading('Alertas de estoque',
                                              subtitle:
                                                  '${app.lowStockCount} item(ns) abaixo do mínimo',
                                              trailing: StatusChip(
                                                  label:
                                                      '${app.lowStockCount} críticos',
                                                  color: app.lowStockCount > 0
                                                      ? ArcadeColors.red
                                                      : ArcadeColors.lime)),
                                          const SizedBox(height: 13),
                                          if (products
                                              .where((product) => product.isLow)
                                              .isEmpty)
                                            const EmptyState(
                                                message:
                                                    'Tudo sob controle. O estoque está em dia.',
                                                icon: Icons
                                                    .check_circle_outline_rounded)
                                          else
                                            ...products
                                                .where(
                                                    (product) => product.isLow)
                                                .take(4)
                                                .map((product) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: Row(children: [
                                                      Container(
                                                          width: 31,
                                                          height: 31,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              color: ArcadeColors
                                                                  .red
                                                                  .withValues(
                                                                      alpha:
                                                                          .09),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9)),
                                                          child: Icon(
                                                              product.icon,
                                                              color:
                                                                  ArcadeColors
                                                                      .red,
                                                              size: 16)),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                          child: Text(
                                                              product.name,
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700))),
                                                      Text(
                                                          '${product.stock} un. / mín. ${product.minimum}',
                                                          style: const TextStyle(
                                                              color:
                                                                  ArcadeColors
                                                                      .red,
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800))
                                                    ]))),
                                        ]))),
                            SizedBox(
                                width: chartWide ? dataWidth * .43 : dataWidth,
                                child: GlassCard(
                                    glow: ArcadeColors.lime,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const PanelHeading('Máquinas',
                                              subtitle:
                                                  'Status da frota arcade'),
                                          const SizedBox(height: 23),
                                          Row(children: [
                                            _MachineCounter(
                                                label: 'ATIVAS',
                                                count: app.activeMachines,
                                                total: app.machines.length,
                                                color: ArcadeColors.lime),
                                            const SizedBox(width: 12),
                                            _MachineCounter(
                                                label: 'MANUTENÇÃO',
                                                count:
                                                    app.machinesInMaintenance,
                                                total: app.machines.length,
                                                color: ArcadeColors.yellow),
                                            const SizedBox(width: 12),
                                            _MachineCounter(
                                                label: 'INATIVAS',
                                                count: app.inactiveMachines,
                                                total: app.machines.length,
                                                color: ArcadeColors.muted),
                                          ]),
                                        ]))),
                          ]),
                    ]));
          }));
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.values});
  final List<List<double>> values;
  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          const SizedBox(width: 22),
          ...['10h', '12h', '14h', '16h', '18h', '20h', '22h'].map((hour) =>
              Expanded(
                  child: Center(
                      child: Text(hour,
                          style: const TextStyle(
                              color: ArcadeColors.muted, fontSize: 7)))))
        ]),
        const SizedBox(height: 6),
        ...List.generate(
            7,
            (day) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  SizedBox(
                      width: 22,
                      child: Text(['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][day],
                          style: const TextStyle(
                              color: ArcadeColors.muted, fontSize: 8))),
                  ...List.generate(7, (hour) {
                    final maxValue =
                        values.expand((row) => row).fold<double>(1, math.max);
                    final value = values[day][hour] / maxValue;
                    final color = Color.lerp(
                        ArcadeColors.purple, ArcadeColors.cyan, value)!;
                    return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Tooltip(
                                message: '${[
                                  'Seg',
                                  'Ter',
                                  'Qua',
                                  'Qui',
                                  'Sex',
                                  'Sáb',
                                  'Dom'
                                ][day]} · ${10 + hour * 2}h · ${money(values[day][hour])}',
                                child: Container(
                                    height: 13,
                                    decoration: BoxDecoration(
                                        color: color.withValues(
                                            alpha: .17 + value * .72),
                                        borderRadius:
                                            BorderRadius.circular(3))))));
                  })
                ]))),
      ]);
}

class _MachineCounter extends StatelessWidget {
  const _MachineCounter(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});
  final String label;
  final int count;
  final int total;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        SizedBox(
            width: 62,
            height: 62,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: total == 0 ? 0 : count / total,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: .065),
                  valueColor: AlwaysStoppedAnimation(color)),
              Text('$count',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ])),
        const SizedBox(height: 10),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: ArcadeColors.muted,
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: .4)),
      ]));
}
