import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/money.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/app_controller.dart';
import '../models/domain.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<AppController>(
        builder: (context, app, _) {
          final width = MediaQuery.sizeOf(context).width;
          final pad = width < 620 ? 16.0 : 26.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(pad, 23, pad, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  title: 'Equipe',
                  subtitle: 'Acesso, escalas e presença no mesmo lugar.',
                  trailing: app.role.canManage
                      ? NeonButton(
                          label: 'NOVO COLABORADOR',
                          icon: Icons.person_add_alt_1_rounded,
                          compact: true,
                          onPressed: () => _editEmployee(app, null),
                        )
                      : null,
                ),
                const SizedBox(height: 17),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.white.withValues(alpha: .025),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: arcadeBorderColor(context)),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorColor:
                        arcadeSemanticColor(context, ArcadeColors.cyan),
                    labelColor: arcadeSemanticColor(context, ArcadeColors.cyan),
                    unselectedLabelColor:
                        arcadeSemanticColor(context, ArcadeColors.muted),
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: const [
                      Tab(text: 'Colaboradores'),
                      Tab(text: 'Escalas'),
                      Tab(text: 'Ponto'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _members(app),
                      _scheduleView(app),
                      _timeClock(app),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _members(AppController app) => LayoutBuilder(
        builder: (context, constraints) {
          final count = constraints.maxWidth > 1150
              ? 3
              : constraints.maxWidth > 740
                  ? 2
                  : 1;
          final gap = 12.0;
          final itemWidth = (constraints.maxWidth - (count - 1) * gap) / count;
          final people = app.role.canManage
              ? app.team
              : app.team.where((member) => member.id == app.user?.id).toList();
          if (people.isEmpty) {
            return const GlassCard(
              child: EmptyState(message: 'Nenhum colaborador disponível.'),
            );
          }
          return SingleChildScrollView(
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: people
                  .map((person) => SizedBox(
                        width: itemWidth,
                        child: _MemberCard(
                          person: person,
                          canSeePrivate: app.role.canManage,
                          onTap: () => _editEmployee(app, person),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      );

  Widget _scheduleView(AppController app) {
    const days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    const shiftNames = ['Manhã', 'Tarde', 'Noite/Fim de Semana'];
    const shiftIcons = [
      Icons.wb_sunny_outlined,
      Icons.wb_twilight_rounded,
      Icons.nights_stay_outlined,
    ];
    const shiftColors = [
      ArcadeColors.yellow,
      ArcadeColors.magenta,
      ArcadeColors.purple,
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelHeading(
            'Escala semanal',
            subtitle: app.role.canManage
                ? 'Arraste um bloco para um turno vazio ou adicione alguém em uma célula livre.'
                : 'Escalas atribuídas pela gestão. Os blocos vêm dos registros da equipe.',
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1080),
                child: SizedBox(
                  width: 1080,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 190),
                          ...days.map((day) => SizedBox(
                                width: 127,
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      color: arcadeSemanticColor(
                                          context, ArcadeColors.muted),
                                      fontSize: 10,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ...List.generate(
                        3,
                        (shiftIndex) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            height: 116,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 190,
                                  child: Row(
                                    children: [
                                      Icon(shiftIcons[shiftIndex],
                                          color: shiftColors[shiftIndex],
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(shiftNames[shiftIndex],
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ...List.generate(7, (weekday) {
                                  final shifts = app.workShifts
                                      .where((shift) =>
                                          shift.weekday == weekday &&
                                          shift.shiftIndex == shiftIndex)
                                      .toList();
                                  return SizedBox(
                                    width: 127,
                                    child: _ScheduleCell(
                                      shifts: shifts,
                                      employees: app.team,
                                      weekday: weekday,
                                      shiftIndex: shiftIndex,
                                      color: shiftColors[shiftIndex],
                                      canManage: app.role.canManage,
                                      onMove: (id) => _moveShift(
                                        app,
                                        id,
                                        weekday,
                                        shiftIndex,
                                      ),
                                      onAdd: () => _assignShift(
                                        app,
                                        weekday,
                                        shiftIndex,
                                      ),
                                      onDropAllowed: (id) {
                                        final atDestination = app.workShifts
                                            .where((shift) =>
                                                shift.weekday == weekday &&
                                                shift.shiftIndex ==
                                                    shiftIndex &&
                                                shift.id != id)
                                            .isNotEmpty;
                                        return !atDestination;
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (app.workShifts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            app.role.canManage
                                ? 'Ainda não há blocos. Use + em uma célula vazia para atribuir um colaborador.'
                                : 'Ainda não há blocos de escala cadastrados.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: arcadeSemanticColor(
                                    context, ArcadeColors.muted),
                                fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveShift(
    AppController app,
    String id,
    int weekday,
    int shiftIndex,
  ) async {
    final occupied = app.workShifts.any((shift) =>
        shift.id != id &&
        shift.weekday == weekday &&
        shift.shiftIndex == shiftIndex);
    if (occupied) {
      _message(
          context, 'Esse turno já tem um bloco. Escolha uma célula vazia.');
      return;
    }
    try {
      await app.moveWorkShift(id, weekday, shiftIndex);
    } on Object catch (error) {
      if (mounted) _message(context, error);
    }
  }

  Future<void> _assignShift(
      AppController app, int weekday, int shiftIndex) async {
    if (!app.role.canManage) return;
    final activePeople = app.team.where((member) => member.active).toList();
    if (activePeople.isEmpty) {
      _message(
          context, 'Cadastre ou ative um colaborador antes de criar escalas.');
      return;
    }
    final employeeId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: arcadeSurfaceColor(context),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeading(
                'Adicionar à escala',
                subtitle: 'Selecione um colaborador ativo.',
              ),
              const SizedBox(height: 12),
              ...activePeople.map((person) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          arcadeSemanticColor(context, ArcadeColors.cyan)
                              .withValues(alpha: .14),
                      child: Text(person.avatar,
                          style: TextStyle(
                              color: arcadeSemanticColor(
                                  context, ArcadeColors.cyan))),
                    ),
                    title: Text(person.name),
                    subtitle: Text(person.position,
                        style: TextStyle(
                            color: arcadeSemanticColor(
                                context, ArcadeColors.muted),
                            fontSize: 11)),
                    onTap: () => Navigator.of(sheetContext).pop(person.id),
                  )),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
    if (employeeId == null) return;
    try {
      await app.assignWorkShift(employeeId, weekday, shiftIndex);
    } on Object catch (error) {
      if (mounted) _message(context, error);
    }
  }

  Widget _timeClock(AppController app) {
    final records = List<TimeRecord>.of(app.timeHistory)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final hours = List<double>.generate(
      7,
      (index) => index < app.weeklyHours.length ? app.weeklyHours[index] : 0,
    );
    final totalHours = hours.fold<double>(0, (sum, value) => sum + value);
    final maximum = math.max(8.0, hours.fold<double>(0, math.max));
    final membersById = {for (final member in app.team) member.id: member};
    final clockedIn = app.clockedInAt != null;

    return SingleChildScrollView(
      child: Column(
        children: [
          GlassCard(
            glow: clockedIn ? ArcadeColors.lime : ArcadeColors.cyan,
            child: Column(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: arcadeSemanticColor(context,
                            clockedIn ? ArcadeColors.lime : ArcadeColors.cyan)
                        .withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    clockedIn
                        ? Icons.more_time_rounded
                        : Icons.play_arrow_rounded,
                    color: arcadeSemanticColor(context,
                        clockedIn ? ArcadeColors.lime : ArcadeColors.cyan),
                    size: 33,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  clockedIn ? 'TURNO EM ANDAMENTO' : 'PRONTO PARA COMEÇAR?',
                  style:
                      const TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
                const SizedBox(height: 8),
                Text(
                  clockedIn
                      ? 'Início registrado às ${shortTime(app.clockedInAt!.toLocal())}'
                      : 'Registre o início ou o encerramento do seu turno.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: arcadeSemanticColor(context, ArcadeColors.muted),
                      fontSize: 11),
                ),
                const SizedBox(height: 17),
                NeonButton(
                  label: clockedIn ? 'ENCERRAR TURNO' : 'INICIAR TURNO',
                  icon:
                      clockedIn ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  danger: clockedIn,
                  onPressed: () async {
                    final actionContext = context;
                    try {
                      await app.toggleTimeClock();
                      if (actionContext.mounted) {
                        ScaffoldMessenger.of(actionContext).showSnackBar(
                          SnackBar(
                            content: Text(clockedIn
                                ? 'Turno encerrado.'
                                : 'Turno iniciado.'),
                          ),
                        );
                      }
                    } on Object catch (error) {
                      if (actionContext.mounted) {
                        _message(actionContext, error);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PanelHeading(
                  'Horas trabalhadas',
                  subtitle:
                      'Resumo semanal · ${totalHours.toStringAsFixed(1).replaceAll('.', ',')} h no total',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 126,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final value = hours[index].isFinite && hours[index] > 0
                          ? hours[index]
                          : 0.0;
                      final barHeight = value <= 0
                          ? 0.0
                          : (82 * value / maximum).clamp(4.0, 82.0).toDouble();
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              value == 0
                                  ? '0 h'
                                  : '${value.toStringAsFixed(1).replaceAll('.', ',')} h',
                              style: TextStyle(
                                  color: arcadeSemanticColor(
                                      context, ArcadeColors.muted),
                                  fontSize: 10),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: barHeight,
                              width: 15,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    ArcadeColors.purple,
                                    ArcadeColors.cyan
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][index],
                              style: TextStyle(
                                  color: arcadeSemanticColor(
                                      context, ArcadeColors.muted),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Horas calculadas a partir dos registros reais de ponto.',
                  style: TextStyle(
                      color: arcadeSemanticColor(context, ArcadeColors.muted),
                      fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PanelHeading(
                  'Histórico de ponto',
                  subtitle: 'Registros de início e encerramento disponíveis.',
                ),
                const SizedBox(height: 12),
                if (records.isEmpty)
                  const EmptyState(
                    message: 'Nenhum registro de ponto disponível.',
                    icon: Icons.schedule_rounded,
                  )
                else
                  ...records.map((record) {
                    final member = membersById[record.employeeId];
                    final started = record.startedAt.toLocal();
                    final ended = record.endedAt?.toLocal();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ArcadeColors.cyan.withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                color: ArcadeColors.cyan, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member?.name ?? 'Colaborador',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  '${shortDate(started)} · ${shortTime(started)} – ${ended == null ? 'em andamento' : shortTime(ended)}',
                                  style: TextStyle(
                                      color: arcadeSemanticColor(
                                          context, ArcadeColors.muted),
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(record.hours),
                            style: const TextStyle(
                              color: ArcadeColors.lime,
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editEmployee(AppController app, TeamMember? person) async {
    final canManage = app.role.canManage;
    if (person == null && !canManage) return;
    if (person != null && person.id != app.user?.id && !canManage) return;

    final draft = await showModalBottomSheet<_TeamMemberDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: arcadeSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TeamMemberForm(
        initial: person,
        canManage: canManage,
        isDemo: app.isDemo,
      ),
    );
    if (draft == null) return;
    try {
      await app.saveTeamMember(
        userId: person?.id,
        name: draft.name,
        cpf: draft.cpf,
        position: draft.position,
        phone: draft.phone,
        email: draft.email,
        salary: draft.salary,
        role: draft.role,
        admittedAt: draft.admittedAt,
        active: draft.active,
      );
      if (mounted) {
        _message(
          context,
          person == null
              ? 'Colaborador cadastrado.'
              : 'Dados do colaborador atualizados.',
        );
      }
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

String _formatDuration(double hours) {
  if (!hours.isFinite || hours <= 0) return '0 h';
  final minutes = (hours * 60).round();
  final wholeHours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '${wholeHours}h' : '${wholeHours}h ${remainder}min';
}

class _ScheduleCell extends StatelessWidget {
  const _ScheduleCell({
    required this.shifts,
    required this.employees,
    required this.weekday,
    required this.shiftIndex,
    required this.color,
    required this.canManage,
    required this.onMove,
    required this.onAdd,
    required this.onDropAllowed,
  });

  final List<WorkShift> shifts;
  final List<TeamMember> employees;
  final int weekday;
  final int shiftIndex;
  final Color color;
  final bool canManage;
  final ValueChanged<String> onMove;
  final VoidCallback onAdd;
  final bool Function(String id) onDropAllowed;

  @override
  Widget build(BuildContext context) => DragTarget<String>(
        onWillAcceptWithDetails: (details) =>
            canManage && onDropAllowed(details.data),
        onAcceptWithDetails: (details) {
          if (canManage && onDropAllowed(details.data)) {
            onMove(details.data);
          }
        },
        builder: (context, candidates, rejected) {
          final hovering = candidates.isNotEmpty;
          return Container(
            margin: const EdgeInsets.all(5),
            height: double.infinity,
            decoration: BoxDecoration(
              color: hovering
                  ? arcadeSemanticColor(context, ArcadeColors.cyan)
                      .withValues(alpha: .12)
                  : arcadeSoftSurfaceColor(context),
              border: Border.all(
                color: hovering
                    ? arcadeSemanticColor(context, ArcadeColors.cyan)
                        .withValues(alpha: .55)
                    : arcadeBorderColor(context),
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: shifts.isEmpty
                ? canManage
                    ? Center(
                        child: IconButton(
                          tooltip: 'Adicionar colaborador à escala',
                          onPressed: onAdd,
                          icon: Icon(Icons.add_rounded,
                              color: arcadeSemanticColor(
                                  context, ArcadeColors.muted),
                              size: 19),
                        ),
                      )
                    : const SizedBox.shrink()
                : SingleChildScrollView(
                    child: Column(
                      children: shifts.map((shift) {
                        final match = employees
                            .where((member) => member.id == shift.employeeId)
                            .toList();
                        final name =
                            match.isEmpty ? shift.name : match.first.name;
                        final pill = _ShiftPill(name: name, color: color);
                        if (!canManage) return pill;
                        return Draggable<String>(
                          data: shift.id,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 112,
                              child: _ShiftPill(name: name, color: color),
                            ),
                          ),
                          childWhenDragging: Opacity(opacity: .28, child: pill),
                          child: pill,
                        );
                      }).toList(),
                    ),
                  ),
          );
        },
      );
}

class _TeamMemberDraft {
  const _TeamMemberDraft({
    required this.name,
    required this.cpf,
    required this.position,
    required this.phone,
    required this.email,
    required this.salary,
    required this.role,
    required this.admittedAt,
    required this.active,
  });

  final String name;
  final String cpf;
  final String position;
  final String phone;
  final String email;
  final double salary;
  final AppRole role;
  final DateTime admittedAt;
  final bool active;
}

class _TeamMemberForm extends StatefulWidget {
  const _TeamMemberForm({
    required this.initial,
    required this.canManage,
    required this.isDemo,
  });

  final TeamMember? initial;
  final bool canManage;
  final bool isDemo;

  @override
  State<_TeamMemberForm> createState() => _TeamMemberFormState();
}

class _TeamMemberFormState extends State<_TeamMemberForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _cpf;
  late final TextEditingController _position;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _salary;
  late AppRole _role;
  late bool _active;
  late DateTime _admittedAt;

  @override
  void initState() {
    super.initState();
    final person = widget.initial;
    _name = TextEditingController(text: person?.name ?? '');
    _cpf = TextEditingController(text: person?.cpf ?? '');
    _position = TextEditingController(text: person?.position ?? '');
    _phone = TextEditingController(text: person?.phone ?? '');
    _email = TextEditingController(text: person?.email ?? '');
    _salary = TextEditingController(
        text: person == null ? '' : person.baseSalary.toStringAsFixed(2));
    _role = person?.role ?? AppRole.cashier;
    _active = person?.active ?? true;
    _admittedAt = person?.admittedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _name.dispose();
    _cpf.dispose();
    _position.dispose();
    _phone.dispose();
    _email.dispose();
    _salary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight =
        (screenHeight - keyboard - 20).clamp(280.0, screenHeight);
    final initial = widget.initial;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SizedBox(
        height: availableHeight * .94,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Material(
              color: arcadeSurfaceColor(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 16, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: PanelHeading(
                            initial == null
                                ? 'Novo colaborador'
                                : 'Editar colaborador',
                            subtitle: widget.isDemo
                                ? 'Dados de equipe do modo demonstração.'
                                : initial == null
                                    ? 'O e-mail deve pertencer a um usuário já convidado no Supabase Auth; este formulário não cria acesso.'
                                    : 'Atualize o perfil vinculado ao usuário convidado.',
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
                  Divider(height: 1, color: arcadeBorderColor(context)),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                        children: [
                          _textField(
                            _name,
                            label: 'Nome completo',
                            icon: Icons.person_outline_rounded,
                            validator: (value) =>
                                (value ?? '').trim().length < 3
                                    ? 'Informe o nome completo.'
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cpf = widget.canManage
                                  ? _textField(
                                      _cpf,
                                      label: 'CPF',
                                      icon: Icons.badge_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        final digits = (value ?? '')
                                            .replaceAll(RegExp(r'\D'), '');
                                        return digits.length == 11
                                            ? null
                                            : 'Informe um CPF com 11 dígitos.';
                                      },
                                    )
                                  : const SizedBox.shrink();
                              final position = _textField(
                                _position,
                                label: 'Cargo',
                                icon: Icons.work_outline_rounded,
                                validator: (value) =>
                                    (value ?? '').trim().isEmpty
                                        ? 'Informe o cargo.'
                                        : null,
                              );
                              if (!widget.canManage ||
                                  constraints.maxWidth < 500) {
                                return Column(
                                  children: [
                                    if (widget.canManage) cpf,
                                    if (widget.canManage)
                                      const SizedBox(height: 10),
                                    position,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: cpf),
                                  const SizedBox(width: 10),
                                  Expanded(child: position),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final phone = _textField(
                                _phone,
                                label: 'Telefone',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                    (value ?? '').trim().isEmpty
                                        ? 'Informe o telefone.'
                                        : null,
                              );
                              final email = _textField(
                                _email,
                                label: 'E-mail',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final text = (value ?? '').trim();
                                  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                          .hasMatch(text)
                                      ? null
                                      : 'Informe um e-mail válido.';
                                },
                              );
                              if (constraints.maxWidth < 500) {
                                return Column(
                                  children: [
                                    phone,
                                    const SizedBox(height: 10),
                                    email,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: phone),
                                  const SizedBox(width: 10),
                                  Expanded(child: email),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _selectAdmissionDate,
                            icon: const Icon(Icons.event_outlined, size: 17),
                            label: Text(
                                'Data de admissão: ${shortDate(_admittedAt)}'),
                          ),
                          if (widget.canManage) ...[
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final salary = _textField(
                                  _salary,
                                  label: 'Salário base',
                                  icon: Icons.payments_outlined,
                                  prefixText: 'R\$ ',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: false),
                                  validator: (value) {
                                    final parsed = parseMoney(value ?? '');
                                    if (parsed == null ||
                                        !parsed.isFinite ||
                                        parsed < 0) {
                                      return 'Informe salário válido (zero ou maior).';
                                    }
                                    return null;
                                  },
                                );
                                final role = DropdownButtonFormField<AppRole>(
                                  initialValue: _role,
                                  decoration: const InputDecoration(
                                      labelText: 'Perfil'),
                                  items: AppRole.values
                                      .map((item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item.label,
                                                style: const TextStyle(
                                                    fontSize: 10)),
                                          ))
                                      .toList(),
                                  onChanged: (item) {
                                    if (item != null) {
                                      setState(() => _role = item);
                                    }
                                  },
                                );
                                if (constraints.maxWidth < 500) {
                                  return Column(
                                    children: [
                                      salary,
                                      const SizedBox(height: 10),
                                      role,
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: salary),
                                    const SizedBox(width: 10),
                                    Expanded(child: role),
                                  ],
                                );
                              },
                            ),
                            if (initial != null) ...[
                              const SizedBox(height: 8),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                value: _active,
                                activeThumbColor: arcadeSemanticColor(
                                    context, ArcadeColors.lime),
                                title: const Text('Colaborador ativo',
                                    style: TextStyle(fontSize: 11)),
                                subtitle: Text(
                                    'Preserva os dados sem conceder acesso a um perfil inativo.',
                                    style: TextStyle(
                                        color: arcadeSemanticColor(
                                            context, ArcadeColors.muted),
                                        fontSize: 10)),
                                onChanged: (value) =>
                                    setState(() => _active = value),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: arcadeBorderColor(context)),
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
                          label: initial == null
                              ? 'CADASTRAR'
                              : 'SALVAR ALTERAÇÕES',
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

  Widget _textField(
    TextEditingController controller, {
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        readOnly: identical(controller, _email) &&
            !widget.isDemo &&
            widget.initial != null,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 17),
          prefixText: prefixText,
        ),
      );

  Future<void> _selectAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _admittedAt,
      firstDate: DateTime(1950),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Data de admissão',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
    );
    if (picked != null && mounted) {
      setState(() => _admittedAt = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final initial = widget.initial;
    Navigator.of(context).pop(
      _TeamMemberDraft(
        name: _name.text.trim(),
        cpf: widget.canManage ? _cpf.text.trim() : initial?.cpf ?? '',
        position: _position.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        salary: widget.canManage
            ? parseMoney(_salary.text)!
            : initial?.baseSalary ?? 0,
        role: widget.canManage ? _role : initial?.role ?? AppRole.cashier,
        admittedAt: _admittedAt,
        active: widget.canManage ? _active : initial?.active ?? true,
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.person,
    required this.canSeePrivate,
    required this.onTap,
  });

  final TeamMember person;
  final bool canSeePrivate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 49,
              height: 49,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ArcadeColors.cyan.withValues(alpha: .28),
                    ArcadeColors.purple.withValues(alpha: .3),
                  ],
                ),
                border:
                    Border.all(color: ArcadeColors.cyan.withValues(alpha: .22)),
              ),
              child: Text(person.avatar,
                  style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(person.position,
                      style: TextStyle(
                          color:
                              arcadeSemanticColor(context, ArcadeColors.muted),
                          fontSize: 11)),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    children: [
                      StatusChip(
                          label: person.role.label,
                          color: _roleColor(person.role),
                          dot: false),
                      StatusChip(
                        label: person.active ? 'Ativo' : 'Inativo',
                        color: person.active
                            ? ArcadeColors.lime
                            : ArcadeColors.muted,
                        dot: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canSeePrivate)
              Icon(Icons.chevron_right_rounded,
                  color: arcadeSemanticColor(context, ArcadeColors.muted),
                  size: 19),
          ],
        ),
      );

  Color _roleColor(AppRole role) => switch (role) {
        AppRole.admin => ArcadeColors.magenta,
        AppRole.manager => ArcadeColors.cyan,
        AppRole.cashier => ArcadeColors.lime,
        AppRole.technician => ArcadeColors.yellow,
      };
}

class _ShiftPill extends StatelessWidget {
  const _ShiftPill({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final displayColor = arcadeSemanticColor(context, color);
    final foreground = displayColor.computeLuminance() > .55
        ? ArcadeColors.lightInk
        : Colors.white;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: displayColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: displayColor.withValues(alpha: .18),
              blurRadius: 7,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        name.split(' ').first,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: foreground, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
