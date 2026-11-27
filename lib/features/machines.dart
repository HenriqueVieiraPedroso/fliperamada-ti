import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});
  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  String _filter = 'Todas';
  @override
  Widget build(BuildContext context) =>
      Consumer<AppController>(builder: (context, app, _) {
        final width = MediaQuery.sizeOf(context).width;
        final pad = width < 620 ? 16.0 : 26.0;
        final filtered = app.machines
            .where((machine) =>
                _filter == 'Todas' || machine.statusLabel == _filter)
            .toList();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 23, pad, 28),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageTitle(
              title: 'Máquinas de Arcade',
              subtitle: 'Cada gabinete conta uma parte da história da arena.',
              trailing: DropdownButton<String>(
                value: _filter,
                dropdownColor: arcadeSurfaceColor(context),
                underline: const SizedBox.shrink(),
                items: ['Todas', 'Ativa', 'Em Manutenção', 'Inativa']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child:
                              Text(value, style: const TextStyle(fontSize: 10)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _filter = value ?? 'Todas'),
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, constraints) {
              final count = constraints.maxWidth > 1140
                  ? 3
                  : constraints.maxWidth > 720
                      ? 2
                      : 1;
              final gap = 13.0;
              final itemWidth =
                  (constraints.maxWidth - (count - 1) * gap) / count;
              return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: filtered
                      .map((machine) => SizedBox(
                          width: itemWidth,
                          child: _MachineCard(
                              machine: machine,
                              onTap: () => _details(context, app, machine))))
                      .toList());
            }),
          ]),
        );
      });

  Future<void> _details(
      BuildContext context, AppController app, ArcadeMachine machine) async {
    final records = app.maintenanceRecords
        .where((record) => record['machine_id']?.toString() == machine.id)
        .toList();
    final canRegisterPartExit =
        app.role.canManage || app.role == AppRole.technician;
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: arcadeSurfaceColor(context),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Container(
                        width: 45,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: machine.statusColor.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(13)),
                        child: Icon(Icons.videogame_asset_rounded,
                            color: machine.statusColor, size: 21)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(machine.game,
                              style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          Text('Patrimônio ${machine.asset}',
                              style: const TextStyle(
                                  color: ArcadeColors.muted, fontSize: 10))
                        ])),
                    StatusChip(
                        label: machine.statusLabel, color: machine.statusColor)
                  ]),
                  const SizedBox(height: 21),
                  Wrap(spacing: 30, runSpacing: 14, children: [
                    _Fact(
                        label: 'AQUISIÇÃO', value: shortDate(machine.acquired)),
                    _Fact(
                        label: 'MANUTENÇÕES',
                        value: '${machine.maintenanceCount} registros'),
                    _Fact(label: 'STATUS', value: machine.statusLabel)
                  ]),
                  const SizedBox(height: 21),
                  const PanelHeading('Histórico de manutenções',
                      subtitle: 'Linha do tempo e peças utilizadas.'),
                  const SizedBox(height: 14),
                  if (records.isEmpty)
                    const SizedBox(
                        height: 110,
                        child: EmptyState(
                            message:
                                'Nenhuma manutenção registrada para esta máquina.',
                            icon: Icons.build_outlined))
                  else
                    ...records.map((record) => _MaintenanceEvent(
                        date: _maintenanceDate(record['occurred_at']),
                        title:
                            (record['description'] ?? 'Manutenção').toString(),
                        note: _partsSummary(record['parts']))),
                  if (canRegisterPartExit) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                            label: 'REGISTRAR SAÍDA DE PEÇA',
                            icon: Icons.build_outlined,
                            onPressed: () {
                              Navigator.pop(context);
                              _partExit(context, app, machine);
                            })),
                  ],
                ]))));
  }

  DateTime? _maintenanceDate(Object? value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  }

  String _partsSummary(Object? value) {
    if (value is! List) return 'Nenhuma peça vinculada.';
    final parts = <String>[];
    for (final item in value) {
      if (item is! Map) continue;
      final name = (item['product_name'] ?? 'Peça').toString();
      final quantity = (item['quantity'] ?? 0).toString();
      parts.add('$name × $quantity');
    }
    return parts.isEmpty ? 'Nenhuma peça vinculada.' : parts.join(' · ');
  }

  Future<void> _partExit(
      BuildContext context, AppController app, ArcadeMachine machine) async {
    if (app.products.isEmpty) {
      _message(
          context, 'Cadastre produtos no estoque antes de registrar uma peça.');
      return;
    }
    final product = ValueNotifier<AppProduct>(app.products.first);
    final qty = TextEditingController(text: '1');
    final note = TextEditingController();
    final submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: arcadeSurfaceColor(context),
                title: const Text('Saída de peça',
                    style: TextStyle(fontFamily: 'SpaceGrotesk')),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Máquina vinculada: ${machine.game} · ${machine.asset}',
                          style: const TextStyle(
                              color: ArcadeColors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<AppProduct>(
                          valueListenable: product,
                          builder: (context, value, _) => DropdownButtonFormField<
                                  AppProduct>(
                              initialValue: value,
                              decoration: const InputDecoration(
                                  labelText: 'Produto / peça'),
                              items: app.products
                                  .map((item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                          '${item.name} · ${item.stock} un.')))
                                  .toList(),
                              onChanged: (item) {
                                if (item != null) product.value = item;
                              })),
                      const SizedBox(height: 10),
                      TextField(
                          controller: qty,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Quantidade')),
                      const SizedBox(height: 10),
                      TextField(
                          controller: note,
                          decoration:
                              const InputDecoration(labelText: 'Observação'))
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  NeonButton(
                      label: 'REGISTRAR SAÍDA',
                      danger: true,
                      onPressed: () => Navigator.pop(context, true))
                ]));
    if (submit != true) return;
    try {
      await app.registerPartExit(
          machineId: machine.id,
          productId: product.value.id,
          quantity: int.tryParse(qty.text) ?? 0,
          note: note.text);
      if (context.mounted) {
        _message(context, 'Saída vinculada a ${machine.asset} registrada.');
      }
    } on Object catch (error) {
      if (context.mounted) _message(context, error);
    }
  }

  void _message(BuildContext context, Object error) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error));
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({required this.machine, required this.onTap});
  final ArcadeMachine machine;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GlassCard(
      glow: machine.statusColor,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(children: [
        Container(
            height: 12,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              machine.statusColor.withValues(alpha: .68),
              machine.statusColor.withValues(alpha: .08)
            ]))),
        Padding(
            padding: const EdgeInsets.all(17),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 52,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: arcadeSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: machine.statusColor.withValues(alpha: .3),
                          width: 1.2)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 25,
                            height: 20,
                            decoration: BoxDecoration(
                                color: ArcadeColors.bg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: machine.statusColor
                                        .withValues(alpha: .7))),
                            child: const Icon(Icons.sports_esports_outlined,
                                size: 13, color: ArcadeColors.cyan)),
                        const SizedBox(height: 5),
                        Container(
                            width: 19,
                            height: 3,
                            decoration: BoxDecoration(
                                color: machine.statusColor,
                                borderRadius: BorderRadius.circular(3)))
                      ])),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(machine.game,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('PATRIMÔNIO ${machine.asset}',
                        style: const TextStyle(
                            color: ArcadeColors.muted,
                            fontSize: 8,
                            letterSpacing: .7,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 9),
                    StatusChip(
                        label: machine.statusLabel, color: machine.statusColor)
                  ])),
              const Icon(Icons.chevron_right_rounded,
                  color: ArcadeColors.muted, size: 19),
            ])),
        const Divider(height: 1, color: ArcadeColors.divider),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
            child: Row(children: [
              Expanded(
                  child: _Fact(
                      label: 'AQUISIÇÃO', value: shortDate(machine.acquired))),
              Expanded(
                  child: _Fact(
                      label: 'MANUTENÇÕES',
                      value: '${machine.maintenanceCount}'))
            ])),
      ]));
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: ArcadeColors.muted,
                fontSize: 7,
                letterSpacing: .8,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))
      ]);
}

class _MaintenanceEvent extends StatelessWidget {
  const _MaintenanceEvent(
      {required this.date, required this.title, required this.note});
  final DateTime? date;
  final String title;
  final String note;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ArcadeColors.yellow.withValues(alpha: .1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.build_outlined,
                  color: ArcadeColors.yellow, size: 13)),
          Container(width: 1, height: 28, color: ArcadeColors.divider)
        ]),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(note,
              style: const TextStyle(color: ArcadeColors.muted, fontSize: 9)),
          const SizedBox(height: 3),
          Text(shortDate(date),
              style: const TextStyle(color: ArcadeColors.cyan, fontSize: 8))
        ])),
      ]));
}
