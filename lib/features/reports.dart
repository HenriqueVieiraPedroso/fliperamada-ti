import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) =>
          Consumer<AppController>(builder: (context, app, _) {
            final pad = constraints.maxWidth < 620 ? 16.0 : 26.0;
            final width = constraints.maxWidth - pad * 2;
            final count = width > 1020
                ? 4
                : width > 600
                    ? 2
                    : 1;
            final cardWidth = (width - 12 * (count - 1)) / count;
            final payments = PaymentMethod.values
                .map((method) => app.paymentTotals[method] ?? 0)
                .toList();
            return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 23, pad, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title: 'Financeiro',
                          subtitle:
                              'Entradas e margem de vendas da arena, sem estimativas fictícias.',
                          trailing: SegmentedPills(
                              items: const ['Hoje', '7 dias', 'Mês'],
                              value: app.selectedPeriod,
                              onChanged: app.setPeriod)),
                      const SizedBox(height: 20),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(
                            width: cardWidth,
                            child: KpiCard(
                                label: 'Receita de vendas',
                                value: money(app.revenue),
                                color: ArcadeColors.cyan,
                                change: app.revenueChange,
                                icon: Icons.south_west_rounded,
                                spark: app.periodSeries)),
                        SizedBox(
                            width: cardWidth,
                            child: KpiCard(
                                label: 'Custo dos itens vendidos',
                                value: money(app.costOfSales),
                                color: ArcadeColors.magenta,
                                change: 'CUSTO REGISTRADO',
                                icon: Icons.shopping_bag_outlined,
                                spark: app.costSeries)),
                        SizedBox(
                            width: cardWidth,
                            child: KpiCard(
                                label: 'Margem bruta de vendas',
                                value: money(app.revenue - app.costOfSales),
                                color: ArcadeColors.lime,
                                change: app.revenue == 0
                                    ? 'SEM VENDAS'
                                    : '${((app.revenue - app.costOfSales) / app.revenue * 100).toStringAsFixed(1)}%',
                                icon: Icons.account_balance_outlined,
                                spark: app.marginSeries)),
                        SizedBox(
                            width: cardWidth,
                            child: KpiCard(
                                label: 'Saldo do caixa atual',
                                value: money(app.cashBalance),
                                color: ArcadeColors.yellow,
                                change: app.cashOpen ? 'ABERTO' : 'FECHADO',
                                icon: Icons.point_of_sale_rounded,
                                spark: app.cashSeries)),
                      ]),
                      const SizedBox(height: 14),
                      GlassCard(
                          glow: ArcadeColors.yellow,
                          child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: ArcadeColors.yellow, size: 17),
                                SizedBox(width: 9),
                                Expanded(
                                    child: Text(
                                        'A margem considera o custo unitário registrado na venda. Não inclui impostos, despesas fixas, folha ou integrações bancárias. Suprimentos e sangrias não são receita nem despesa de vendas.',
                                        style: TextStyle(
                                            color: ArcadeColors.muted,
                                            fontSize: 10,
                                            height: 1.5)))
                              ])),
                      const SizedBox(height: 14),
                      Wrap(spacing: 14, runSpacing: 14, children: [
                        SizedBox(
                            width: width > 900 ? (width - 14) * .64 : width,
                            child: GlassCard(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const PanelHeading('Receita de vendas',
                                      subtitle:
                                          'Período atual e anterior de mesma duração'),
                                  const SizedBox(height: 17),
                                  SmoothAreaChart(
                                      values: app.periodSeries,
                                      previous: app.previousPeriodSeries,
                                      color: ArcadeColors.cyan),
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('INÍCIO',
                                            style: TextStyle(
                                                color: ArcadeColors.muted,
                                                fontSize: 8)),
                                        Text('MEIO',
                                            style: TextStyle(
                                                color: ArcadeColors.muted,
                                                fontSize: 8)),
                                        Text('FIM',
                                            style: TextStyle(
                                                color: ArcadeColors.muted,
                                                fontSize: 8))
                                      ]),
                                ]))),
                        SizedBox(
                            width: width > 900 ? (width - 14) * .36 : width,
                            child: GlassCard(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const PanelHeading('Composição de vendas',
                                      subtitle:
                                          'Pagamentos combinados separados por forma'),
                                  const SizedBox(height: 10),
                                  Center(
                                      child: NeonDonut(
                                          values: payments,
                                          colors: const [
                                            ArcadeColors.lime,
                                            ArcadeColors.cyan,
                                            ArcadeColors.purple,
                                            ArcadeColors.magenta
                                          ],
                                          total: money(app.revenue))),
                                  const SizedBox(height: 9),
                                  ...List.generate(
                                      4,
                                      (i) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(children: [
                                            Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: [
                                                      ArcadeColors.lime,
                                                      ArcadeColors.cyan,
                                                      ArcadeColors.purple,
                                                      ArcadeColors.magenta
                                                    ][i])),
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
                                                            ArcadeColors.muted,
                                                        fontSize: 9))),
                                            Text(money(payments[i]),
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w700))
                                          ]))),
                                ]))),
                      ]),
                    ]));
          }));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) =>
          Consumer<AppController>(builder: (context, app, _) {
            final pad = constraints.maxWidth < 620 ? 16.0 : 26.0;
            final width = constraints.maxWidth - pad * 2;
            final count = width > 980
                ? 3
                : width > 600
                    ? 2
                    : 1;
            final kpiWidth = (width - 12 * (count - 1)) / count;
            return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 23, pad, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title: 'Relatórios',
                          subtitle:
                              'Transações registradas no período selecionado.',
                          trailing: SegmentedPills(
                              items: const ['Hoje', '7 dias', 'Mês'],
                              value: app.selectedPeriod,
                              onChanged: app.setPeriod)),
                      const SizedBox(height: 19),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Vendas',
                                value: '${app.sales.length}',
                                color: ArcadeColors.cyan,
                                change: app.selectedPeriod.toUpperCase(),
                                icon: Icons.receipt_long_outlined,
                                spark: app.countSeries)),
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Faturamento',
                                value: money(app.revenue),
                                color: ArcadeColors.magenta,
                                change: app.revenueChange,
                                icon: Icons.payments_outlined,
                                spark: app.periodSeries)),
                        SizedBox(
                            width: kpiWidth,
                            child: KpiCard(
                                label: 'Ticket médio',
                                value: money(app.ticketAverage),
                                color: ArcadeColors.lime,
                                change: app.ticketChange,
                                icon: Icons.confirmation_number_outlined,
                                spark: app.ticketSeries)),
                      ]),
                      const SizedBox(height: 14),
                      GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: PanelHeading('Vendas do período',
                                        subtitle:
                                            '${app.sales.length} transações · ${app.selectedPeriod.toLowerCase()}')),
                                if (app.sales.isEmpty)
                                  const SizedBox(
                                      height: 180, child: EmptyState())
                                else ...[
                                  const Divider(
                                      height: 1, color: ArcadeColors.divider),
                                  for (final sale in app.sales)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                        child: Row(children: [
                                          Container(
                                              width: 31,
                                              height: 31,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: ArcadeColors.cyan
                                                      .withValues(alpha: .09),
                                                  borderRadius:
                                                      BorderRadius.circular(9)),
                                              child: const Icon(
                                                  Icons.receipt_outlined,
                                                  color: ArcadeColors.cyan,
                                                  size: 15)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(
                                                    'Venda #${sale.id.length > 8 ? sale.id.substring(0, 8).toUpperCase() : sale.id.toUpperCase()}',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800)),
                                                const SizedBox(height: 3),
                                                Text(
                                                    '${shortDate(sale.createdAt)} · ${shortTime(sale.createdAt)} · ${sale.items} item(ns)',
                                                    style: const TextStyle(
                                                        color:
                                                            ArcadeColors.muted,
                                                        fontSize: 8)),
                                                const SizedBox(height: 3),
                                                Text(
                                                    PaymentMethod.values
                                                        .where((method) =>
                                                            sale.paidBy(
                                                                method) >
                                                            0)
                                                        .map((method) =>
                                                            '${_method(method)} ${money(sale.paidBy(method))}')
                                                        .join(' + '),
                                                    style: const TextStyle(
                                                        color:
                                                            ArcadeColors.muted,
                                                        fontSize: 9))
                                              ])),
                                          const SizedBox(width: 10),
                                          Text(money(sale.total),
                                              style: const TextStyle(
                                                  fontFamily: 'SpaceGrotesk',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12)),
                                        ])),
                                ],
                              ])),
                      const SizedBox(height: 13),
                      GlassCard(
                          child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Icon(Icons.shield_outlined,
                                color: ArcadeColors.purple, size: 17),
                            SizedBox(width: 9),
                            Expanded(
                                child: Text(
                                    'Relatórios gerenciais. Esta versão não emite documentos fiscais nem substitui um sistema contábil.',
                                    style: TextStyle(
                                        color: ArcadeColors.muted,
                                        fontSize: 10,
                                        height: 1.5)))
                          ])),
                    ]));
          }));
  String _method(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'Dinheiro',
        PaymentMethod.pix => 'PIX',
        PaymentMethod.debit => 'Débito',
        PaymentMethod.credit => 'Crédito'
      };
}
