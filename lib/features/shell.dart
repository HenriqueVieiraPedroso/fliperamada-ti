import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';
import 'cash.dart';
import 'dashboard.dart';
import 'inventory.dart';
import 'machines.dart';
import 'pos.dart';
import 'reports.dart';
import 'team.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _expanded = false;
  final _search = TextEditingController();

  List<AppSection> _sections(AppRole role) => switch (role) {
        AppRole.admin || AppRole.manager => AppSection.values,
        AppRole.cashier => const [
            AppSection.dashboard,
            AppSection.pos,
            AppSection.cash,
            AppSection.inventory,
            AppSection.machines,
            AppSection.team
          ],
        AppRole.technician => const [
            AppSection.dashboard,
            AppSection.inventory,
            AppSection.machines,
            AppSection.team
          ],
      };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Consumer<AppController>(builder: (context, app, _) {
        final mobile = MediaQuery.sizeOf(context).width < 860;
        return Scaffold(
          body: SafeArea(
              top: false,
              bottom: mobile ? false : true,
              child: Row(children: [
                if (!mobile)
                  _SideRail(
                      expanded: _expanded,
                      onToggle: () => setState(() => _expanded = !_expanded),
                      sections: _sections(app.role),
                      selected: app.section,
                      onSelect: app.navigate),
                Expanded(
                    child: Column(children: [
                  _TopBar(
                      search: _search,
                      onLogout: app.signOut,
                      onSearch: () => _globalSearch(app)),
                  if (app.isDemo) const _DemoBanner(),
                  Expanded(
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          child:
                              _page(app.section, key: ValueKey(app.section)))),
                ])),
              ])),
          bottomNavigationBar: mobile
              ? _MobileNav(
                  sections: _sections(app.role),
                  selected: app.section,
                  onSelect: app.navigate)
              : null,
        );
      });

  void _globalSearch(AppController app) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return;
    final results = <({String label, String detail, AppSection section})>[];
    for (final section in _sections(app.role)) {
      if (section.label.toLowerCase().contains(query)) {
        results.add((label: section.label, detail: 'Módulo', section: section));
      }
    }
    if (app.canAccess(AppSection.inventory)) {
      for (final product in app.products) {
        if (product.name.toLowerCase().contains(query)) {
          results.add((
            label: product.name,
            detail: '${product.category} · ${product.stock} un.',
            section: AppSection.inventory
          ));
        }
      }
    }
    for (final machine in app.machines) {
      if ('${machine.game} ${machine.asset}'.toLowerCase().contains(query)) {
        results.add((
          label: machine.game,
          detail: '${machine.asset} · ${machine.statusLabel}',
          section: AppSection.machines
        ));
      }
    }
    if (_sections(app.role).contains(AppSection.team)) {
      for (final person in app.team) {
        if ('${person.name} ${person.position}'.toLowerCase().contains(query)) {
          results.add((
            label: person.name,
            detail: person.position,
            section: AppSection.team
          ));
        }
      }
    }
    for (final supplier in app.suppliers) {
      if (supplier.name.toLowerCase().contains(query)) {
        results.add((
          label: supplier.name,
          detail: 'Fornecedor',
          section: AppSection.inventory
        ));
      }
    }
    if (_sections(app.role).contains(AppSection.inventory)) {
      for (final movement in app.inventoryMovements.take(30)) {
        if ('${movement['product_name']} ${movement['operator']}'
            .toLowerCase()
            .contains(query)) {
          results.add((
            label: (movement['product_name'] ?? 'Movimentação').toString(),
            detail: 'Movimentação · ${movement['quantity']} un.',
            section: AppSection.inventory
          ));
        }
      }
    }
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: const Color(0xFF14152C),
        builder: (sheetContext) => SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .7,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(
                        child: Text('Busca: ${_search.text}',
                            style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 20,
                                fontWeight: FontWeight.w700))),
                    IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded))
                  ])),
              Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text(
                              'GAME OVER... nenhum resultado para essa busca.'))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return ListTile(
                                leading: Icon(result.section.icon,
                                    color: ArcadeColors.cyan),
                                title: Text(result.label),
                                subtitle: Text(result.detail),
                                trailing:
                                    const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  app.navigate(result.section);
                                });
                          }))
            ])));
  }

  Widget _page(AppSection section, {required Key key}) => switch (section) {
        AppSection.dashboard => DashboardScreen(key: key),
        AppSection.pos => PosScreen(key: key),
        AppSection.cash => CashScreen(key: key),
        AppSection.inventory => InventoryScreen(key: key),
        AppSection.machines => MachinesScreen(key: key),
        AppSection.team => TeamScreen(key: key),
        AppSection.finance => FinanceScreen(key: key),
        AppSection.reports => ReportsScreen(key: key),
      };
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 8),
      color: ArcadeColors.yellow.withValues(alpha: .075),
      child: const Row(children: [
        Icon(Icons.science_outlined, size: 14, color: ArcadeColors.yellow),
        SizedBox(width: 8),
        Expanded(
            child: Text(
                'MODO DEMONSTRAÇÃO — dados fictícios; nenhuma alteração é salva no Supabase.',
                style: TextStyle(
                    color: ArcadeColors.yellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w700))),
      ]));
}

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.search, required this.onLogout, required this.onSearch});
  final TextEditingController search;
  final Future<void> Function() onLogout;
  final VoidCallback onSearch;
  @override
  Widget build(BuildContext context) =>
      Consumer<AppController>(builder: (context, app, _) {
        final compact = MediaQuery.sizeOf(context).width < 620;
        final user = app.user!;
        return Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 26),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: ArcadeColors.divider))),
            child: Row(children: [
              if (compact) ...[
                const Icon(Icons.sports_esports_rounded,
                    color: ArcadeColors.cyan, size: 20),
                const SizedBox(width: 9)
              ],
              Expanded(
                  flex: 2,
                  child: Container(
                      height: 38,
                      constraints: const BoxConstraints(maxWidth: 360),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .035),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ArcadeColors.divider)),
                      child: TextField(
                          controller: search,
                          onSubmitted: (_) => onSearch(),
                          style: const TextStyle(fontSize: 11),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  tooltip: 'Buscar na arena',
                                  onPressed: onSearch,
                                  icon: const Icon(Icons.arrow_forward_rounded,
                                      size: 16)),
                              prefixIcon:
                                  const Icon(Icons.search_rounded, size: 17),
                              hintText: compact
                                  ? 'Buscar...'
                                  : 'Buscar produtos, movimentos, equipe...',
                              hintStyle: const TextStyle(fontSize: 10),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.only(top: 10, right: 8))))),
              const Spacer(),
              if (!compact) ...[
                _CashIndicator(open: app.cashOpen),
                const SizedBox(width: 17),
              ],
              PopupMenuButton<String>(
                tooltip: context.watch<ThemeController>().isDark
                    ? 'Ativar tema claro'
                    : 'Ativar tema escuro',
                onSelected: (value) {
                  if (value == 'theme') {
                    context.read<ThemeController>().toggle();
                  }
                  if (value == 'logout') {
                    onLogout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'theme',
                    child: Row(children: [
                      Icon(context.watch<ThemeController>().isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined),
                      const SizedBox(width: 9),
                      Text(context.watch<ThemeController>().isDark
                          ? 'Usar tema claro'
                          : 'Usar tema escuro'),
                    ]),
                  ),
                ],
                child: IconButton(
                  tooltip: context.watch<ThemeController>().isDark
                      ? 'Tema claro'
                      : 'Tema escuro',
                  onPressed: context.read<ThemeController>().toggle,
                  icon: Icon(context.watch<ThemeController>().isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Perfil e sessão',
                onSelected: (value) {
                  if (value == 'logout') onLogout();
                },
                color: Theme.of(context).colorScheme.surface,
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(user.role.label,
                                style: const TextStyle(
                                    color: ArcadeColors.muted, fontSize: 11))
                          ])),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                      value: 'logout',
                      child: Row(children: [
                        Icon(Icons.logout_rounded,
                            color: ArcadeColors.red, size: 17),
                        SizedBox(width: 9),
                        Text('Encerrar sessão')
                      ]))
                ],
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            ArcadeColors.cyan.withValues(alpha: .42),
                            ArcadeColors.purple.withValues(alpha: .62)
                          ]),
                          border: Border.all(
                              color: ArcadeColors.cyan.withValues(alpha: .45))),
                      child: Text(
                          user.name.isEmpty
                              ? '?'
                              : user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13))),
                  if (!compact) ...[
                    const SizedBox(width: 9),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user.name.split(' ').first,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(user.role.label,
                              style: const TextStyle(
                                  fontSize: 9, color: ArcadeColors.muted))
                        ]),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: ArcadeColors.muted)
                  ],
                ]),
              ),
            ]));
      });
}

class _CashIndicator extends StatelessWidget {
  const _CashIndicator({required this.open});
  final bool open;
  @override
  Widget build(BuildContext context) {
    final color = open ? ArcadeColors.lime : ArcadeColors.red;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .16))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _PulseDot(color: color),
          const SizedBox(width: 8),
          Text('CAIXA ${open ? 'ABERTO' : 'FECHADO'}',
              style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7)),
        ]));
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: Tween(begin: .45, end: 1.0).animate(_controller),
      child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: widget.color.withValues(alpha: .6), blurRadius: 8)
              ])));
}

class _SideRail extends StatelessWidget {
  const _SideRail(
      {required this.expanded,
      required this.onToggle,
      required this.sections,
      required this.selected,
      required this.onSelect});
  final bool expanded;
  final VoidCallback onToggle;
  final List<AppSection> sections;
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      width: expanded ? 226 : 82,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(right: BorderSide(color: ArcadeColors.divider))),
      child: Column(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(
                expanded ? 18 : 0, 23, expanded ? 18 : 0, 26),
            child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                          color: ArcadeColors.cyan.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: ArcadeColors.cyan.withValues(alpha: .22))),
                      child: const Icon(Icons.sports_esports_rounded,
                          color: ArcadeColors.cyan, size: 20)),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    const Expanded(
                        child: Text('FLIPERAMADA\nTI / ARCADE',
                            style: TextStyle(
                                fontFamily: 'PressStart2P',
                                color: ArcadeColors.ink,
                                fontSize: 8,
                                height: 1.8)))
                  ],
                ])),
        if (expanded)
          const Padding(
              padding: EdgeInsets.fromLTRB(19, 0, 14, 12),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('MENU PRINCIPAL',
                      style: TextStyle(
                          color: ArcadeColors.muted,
                          fontSize: 8,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800)))),
        Expanded(
            child: ListView(
                padding: EdgeInsets.symmetric(horizontal: expanded ? 10 : 13),
                children: sections
                    .map((section) => _NavTile(
                        section: section,
                        selected: section == selected,
                        expanded: expanded,
                        onTap: () => onSelect(section)))
                    .toList())),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: expanded ? 14 : 0, vertical: 8),
            child: expanded
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: ArcadeColors.cyan.withValues(alpha: .045),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: ArcadeColors.cyan.withValues(alpha: .12))),
                    child: const Row(children: [
                      Icon(Icons.bolt_rounded,
                          size: 15, color: ArcadeColors.cyan),
                      SizedBox(width: 8),
                      Text('SISTEMA ONLINE',
                          style: TextStyle(
                              color: ArcadeColors.cyan,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5))
                    ]))
                : const Icon(Icons.bolt_rounded,
                    size: 17, color: ArcadeColors.cyan)),
        const SizedBox(height: 10),
        IconButton(
            onPressed: onToggle,
            tooltip: expanded ? 'Recolher menu' : 'Expandir menu',
            icon: Icon(
                expanded
                    ? Icons.keyboard_double_arrow_left_rounded
                    : Icons.keyboard_double_arrow_right_rounded,
                color: ArcadeColors.muted,
                size: 20)),
        const SizedBox(height: 10),
      ]));
}

class _NavTile extends StatelessWidget {
  const _NavTile(
      {required this.section,
      required this.selected,
      required this.expanded,
      required this.onTap});
  final AppSection section;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = selected ? ArcadeColors.cyan : ArcadeColors.muted;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Tooltip(
            message: section.label,
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(13),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 45,
                    padding:
                        EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
                    decoration: BoxDecoration(
                        color: selected
                            ? ArcadeColors.cyan.withValues(alpha: .095)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: selected
                                ? ArcadeColors.cyan.withValues(alpha: .18)
                                : Colors.transparent)),
                    child: Row(
                        mainAxisAlignment: expanded
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(section.icon, size: 19, color: color),
                          if (expanded) ...[
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(section.label,
                                    style: TextStyle(
                                        color: selected
                                            ? ArcadeColors.ink
                                            : ArcadeColors.muted,
                                        fontSize: 11,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w600))),
                            if (selected)
                              Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: ArcadeColors.cyan,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: ArcadeColors.cyan
                                                .withValues(alpha: .6),
                                            blurRadius: 8)
                                      ]))
                          ],
                        ])))));
  }
}

class _MobileNav extends StatelessWidget {
  const _MobileNav(
      {required this.sections, required this.selected, required this.onSelect});
  final List<AppSection> sections;
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  @override
  Widget build(BuildContext context) {
    final primary = sections.take(4).toList();
    final extra = sections.skip(4).toList();
    final selectedInExtra = extra.contains(selected);
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: const Border(top: BorderSide(color: ArcadeColors.divider))),
        child: SafeArea(
            top: false,
            child: NavigationBar(
              height: 65,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: ArcadeColors.cyan.withValues(alpha: .1),
              selectedIndex:
                  selectedInExtra ? 4 : primary.indexOf(selected).clamp(0, 3),
              onDestinationSelected: (index) {
                if (index < primary.length) {
                  onSelect(primary[index]);
                  return;
                }
                showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    builder: (context) => SafeArea(
                        child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: extra
                                    .map((section) => ListTile(
                                        leading: Icon(section.icon,
                                            color: section == selected
                                                ? ArcadeColors.cyan
                                                : ArcadeColors.muted),
                                        title: Text(section.label),
                                        onTap: () {
                                          Navigator.pop(context);
                                          onSelect(section);
                                        }))
                                    .toList()))));
              },
              destinations: [
                for (final section in primary)
                  NavigationDestination(
                      icon: Icon(section.icon, size: 19),
                      selectedIcon: Icon(section.icon,
                          size: 19, color: ArcadeColors.cyan),
                      label: section.label),
                if (extra.isNotEmpty)
                  NavigationDestination(
                      icon: Icon(Icons.more_horiz_rounded,
                          color: selectedInExtra
                              ? ArcadeColors.cyan
                              : ArcadeColors.muted),
                      label: 'Mais'),
              ],
            )));
  }
}
