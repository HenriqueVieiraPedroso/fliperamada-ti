import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/domain.dart';
import 'demo_data.dart';

class AppController extends ChangeNotifier {
  AppController({required this.client, this.startupError});
  final SupabaseClient? client;
  final String? startupError;
  bool get supabaseConfigured => client != null;
  bool get isDemo => _isDemo;
  bool get loggedIn => _user != null;
  AppUser? get user => _user;
  AppRole get role => _user?.role ?? AppRole.cashier;
  AppSection get section => _section;
  String get selectedPeriod => _selectedPeriod;
  bool get cashOpen => _cashOpen;
  DateTime? get cashOpenedAt => _cashOpenedAt;
  double get openingFloat => _openingFloat;
  String? get activeCashId => _activeCashId;
  DateTime? get clockedInAt => _clockedInAt;
  List<AppProduct> get products => List.unmodifiable(_products);
  List<ArcadeMachine> get machines => List.unmodifiable(_machines);
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<TeamMember> get team => List.unmodifiable(_team);
  List<CashEntry> get cashEntries => List.unmodifiable(_cashEntries);
  List<CartLine> get cart => List.unmodifiable(_cart);
  List<Map<String, dynamic>> get inventoryMovements =>
      List.unmodifiable(_inventoryMovements);
  List<Map<String, dynamic>> get maintenanceRecords =>
      List.unmodifiable(_maintenanceRecords);
  List<WorkShift> get workShifts => List.unmodifiable(_workShifts);
  List<TimeRecord> get timeHistory => List.unmodifiable(
      _timeHistory.where((entry) => entry.employeeId == _user?.id));
  List<SaleRecord> get sales => List.unmodifiable(_sales.where((sale) =>
      !sale.createdAt.isBefore(periodStart) &&
      sale.createdAt.isBefore(periodEnd)));
  List<SaleRecord> get sessionSales => List.unmodifiable(
      _sales.where((sale) => sale.cashSessionId == _activeCashId));
  DateTime get periodStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_selectedPeriod) {
      '7 dias' => today.subtract(const Duration(days: 6)),
      'Mês' => DateTime(now.year, now.month),
      _ => today
    };
  }

  DateTime get periodEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  List<SaleRecord> get previousSales {
    final start = periodStart.subtract(periodEnd.difference(periodStart));
    return _sales
        .where((sale) =>
            !sale.createdAt.isBefore(start) &&
            sale.createdAt.isBefore(periodStart))
        .toList();
  }

  double get cartSubtotal => _cart.fold(0, (sum, line) => sum + line.total);
  double get cartDiscount => _cartDiscount;
  double get cartTotal =>
      _round((cartSubtotal - cartDiscount).clamp(0, double.infinity));
  int get lowStockCount => _products.where((product) => product.isLow).length;
  int get activeMachines => _machines
      .where((machine) => machine.status == MachineStatus.active)
      .length;
  int get machinesInMaintenance => _machines
      .where((machine) => machine.status == MachineStatus.maintenance)
      .length;
  int get inactiveMachines => _machines
      .where((machine) => machine.status == MachineStatus.inactive)
      .length;
  double get revenue => sales.fold(0, (sum, sale) => sum + sale.total);
  double get ticketAverage => sales.isEmpty ? 0 : revenue / sales.length;
  int get tokensSold => sales.fold(
      0,
      (sum, sale) =>
          sum +
          sale.lines
              .where((line) => line.category == 'Fichas')
              .fold<int>(0, (count, line) => count + line.quantity));
  double get costOfSales => sales.fold(
      0,
      (sum, sale) =>
          sum +
          sale.lines.fold<double>(
              0, (cost, line) => cost + line.quantity * line.unitCost));
  String _change(double value, double previous) => previous == 0
      ? (value == 0 ? 'SEM VARIAÇÃO' : 'SEM BASE')
      : '${value >= previous ? '+' : ''}${((value / previous - 1) * 100).toStringAsFixed(1).replaceAll('.', ',')}%';
  String get revenueChange =>
      _change(revenue, previousSales.fold(0, (sum, sale) => sum + sale.total));
  String get itemChange => _change(
      tokensSold.toDouble(),
      previousSales.fold<double>(
          0,
          (sum, sale) =>
              sum +
              sale.lines
                  .where((line) => line.category == 'Fichas')
                  .fold<int>(0, (count, line) => count + line.quantity)));
  String get ticketChange => _change(
      ticketAverage,
      previousSales.isEmpty
          ? 0
          : previousSales.fold<double>(0, (sum, sale) => sum + sale.total) /
              previousSales.length);
  Map<PaymentMethod, double> get paymentTotals => {
        for (final method in PaymentMethod.values)
          method:
              sales.fold<double>(0, (sum, sale) => sum + sale.paidBy(method))
      };
  Map<PaymentMethod, double> get sessionPaymentTotals => {
        for (final method in PaymentMethod.values)
          method: sessionSales.fold<double>(
              0, (sum, sale) => sum + sale.paidBy(method))
      };
  Map<String, double> get expectedCash => {
        'Dinheiro': cashBalance,
        'PIX': sessionPaymentTotals[PaymentMethod.pix]!,
        'Débito': sessionPaymentTotals[PaymentMethod.debit]!,
        'Crédito': sessionPaymentTotals[PaymentMethod.credit]!
      };
  Map<String, double> get categoryTotals {
    final totals = <String, double>{'Fichas': 0, 'Bebidas': 0, 'Snacks': 0};
    for (final sale in sales) {
      final subtotal =
          sale.lines.fold<double>(0, (sum, line) => sum + line.total);
      for (final line in sale.lines) {
        totals[line.category] = (totals[line.category] ?? 0) +
            line.total * (subtotal == 0 ? 0 : sale.total / subtotal);
      }
    }
    return totals;
  }

  List<MapEntry<String, double>> get topProducts {
    final totals = <String, double>{};
    for (final sale in sales) {
      for (final line in sale.lines) {
        totals[line.name] = (totals[line.name] ?? 0) + line.quantity;
      }
    }
    return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  List<double> _series(List<SaleRecord> records, DateTime start) {
    final hourly = _selectedPeriod == 'Hoje';
    final count = hourly ? 12 : periodEnd.difference(periodStart).inDays;
    final result = List<double>.filled(count, 0);
    for (final sale in records) {
      final index = hourly
          ? sale.createdAt.hour ~/ 2
          : DateTime(
                  sale.createdAt.year, sale.createdAt.month, sale.createdAt.day)
              .difference(start)
              .inDays;
      if (index >= 0 && index < count) result[index] += sale.total;
    }
    return result;
  }

  List<double> _metricSeries(double Function(SaleRecord) metric,
      {bool average = false}) {
    final result = List<double>.filled(periodSeries.length, 0);
    final counts = List<int>.filled(result.length, 0);
    for (final sale in sales) {
      final index = _selectedPeriod == 'Hoje'
          ? sale.createdAt.hour ~/ 2
          : DateTime(
                  sale.createdAt.year, sale.createdAt.month, sale.createdAt.day)
              .difference(periodStart)
              .inDays;
      if (index >= 0 && index < result.length) {
        result[index] += metric(sale);
        counts[index]++;
      }
    }
    if (average) {
      for (var i = 0; i < result.length; i++) {
        if (counts[i] > 0) result[i] /= counts[i];
      }
    }
    return result;
  }

  List<double> get tokenSeries => _metricSeries((sale) => sale.lines
      .where((line) => line.category == 'Fichas')
      .fold<double>(0, (sum, line) => sum + line.quantity));
  List<double> get ticketSeries =>
      _metricSeries((sale) => sale.total, average: true);
  List<double> get countSeries => _metricSeries((sale) => 1);
  List<double> get costSeries => _metricSeries((sale) => sale.lines
      .fold<double>(0, (sum, line) => sum + line.unitCost * line.quantity));
  List<double> get marginSeries => _metricSeries((sale) =>
      sale.total -
      sale.lines
          .fold<double>(0, (sum, line) => sum + line.unitCost * line.quantity));
  List<double> get cashSeries {
    if (!cashOpen || _cashOpenedAt == null) return List.filled(12, 0);
    final start = _cashOpenedAt!;
    final duration = DateTime.now().difference(start).inMilliseconds + 1;
    return List.generate(12, (index) {
      final until = start
          .add(Duration(milliseconds: (duration * (index + 1) / 12).round()));
      var balance = _openingFloat;
      for (final sale in sessionSales) {
        if (!sale.createdAt.isAfter(until)) {
          balance += sale.paidBy(PaymentMethod.cash);
        }
      }
      for (final entry in _cashEntries) {
        if (!entry.createdAt.isAfter(until)) {
          if (entry.type == 'Suprimento') balance += entry.amount;
          if (entry.type == 'Sangria') balance -= entry.amount;
        }
      }
      return balance;
    });
  }

  List<double> get periodSeries => _series(sales, periodStart);
  List<double> get previousPeriodSeries => _series(
      previousSales, periodStart.subtract(periodEnd.difference(periodStart)));
  List<List<double>> get heatmap {
    final result = List.generate(7, (_) => List<double>.filled(7, 0));
    for (final sale in sales) {
      final bin = (sale.createdAt.hour - 10) ~/ 2;
      if (sale.createdAt.hour >= 10 && bin < 7) {
        result[sale.createdAt.weekday - 1][bin] += sale.total;
      }
    }
    return result;
  }

  List<double> get weeklyHours {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (day) {
      final from = start.add(Duration(days: day));
      final to = from.add(const Duration(days: 1));
      return timeHistory.fold<double>(0, (sum, record) {
        final begin = record.startedAt.isAfter(from) ? record.startedAt : from;
        final finish =
            (record.endedAt ?? now).isBefore(to) ? (record.endedAt ?? now) : to;
        return sum +
            (finish.isAfter(begin)
                ? finish.difference(begin).inMinutes / 60
                : 0);
      });
    });
  }

  double get cashBalance {
    if (!_cashOpen) return 0;
    var balance = _openingFloat + sessionPaymentTotals[PaymentMethod.cash]!;
    for (final entry in _cashEntries) {
      if (entry.type == 'Suprimento') balance += entry.amount;
      if (entry.type == 'Sangria') balance -= entry.amount;
    }
    return _round(balance);
  }

  bool _isDemo = false;
  AppUser? _user;
  AppSection _section = AppSection.dashboard;
  String _selectedPeriod = 'Hoje';
  bool _cashOpen = false;
  DateTime? _cashOpenedAt;
  double _openingFloat = 0;
  DateTime? _clockedInAt;
  String? _activeTimeEntryId;
  String? _activeCashId;
  double _cartDiscount = 0;
  List<AppProduct> _products = [];
  List<ArcadeMachine> _machines = [];
  List<Supplier> _suppliers = [];
  List<TeamMember> _team = [];
  List<SaleRecord> _sales = [];
  List<CashEntry> _cashEntries = [];
  List<CartLine> _cart = [];
  List<Map<String, dynamic>> _inventoryMovements = [];
  List<Map<String, dynamic>> _maintenanceRecords = [];
  List<WorkShift> _workShifts = [];
  List<TimeRecord> _timeHistory = [];
  double _round(double value) => (value * 100).roundToDouble() / 100;
  void _money(double amount, {bool positive = false}) {
    if (!amount.isFinite || amount < 0 || (positive && amount <= 0)) {
      throw StateError(
          'Informe um valor monetário válido${positive ? ', maior que zero' : ''}.');
    }
  }

  void _manage() {
    if (!role.canManage) {
      throw StateError('A operação exige perfil Gerente ou Administrador.');
    }
  }

  void _cashPermission() {
    if (role == AppRole.technician) {
      throw StateError('O perfil Técnico não pode operar vendas e caixa.');
    }
  }

  bool canAccess(AppSection value) => switch (value) {
        AppSection.finance || AppSection.reports => role.canManage,
        AppSection.pos || AppSection.cash => role != AppRole.technician,
        _ => true
      };

  Future<String?> signIn(String email, String password) async {
    if (client == null) {
      _enterDemo();
      return null;
    }
    try {
      final response = await client!.auth
          .signInWithPassword(email: email.trim(), password: password);
      final authUser = response.user;
      if (authUser == null) {
        return 'Não foi possível autenticar. Tente novamente.';
      }
      final profile = await client!
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      if (profile == null || profile['is_active'] != true) {
        await client!.auth.signOut();
        return 'Usuário inativo ou sem perfil de acesso. Fale com um Administrador.';
      }
      _user = AppUser(
          id: authUser.id,
          email: (profile['email'] ?? authUser.email ?? email).toString(),
          name: (profile['full_name'] ?? 'Operador').toString(),
          role: _roleFromDatabase((profile['role'] ?? 'cashier').toString()));
      _isDemo = false;
      _section = AppSection.dashboard;
      _selectedPeriod = 'Hoje';
      await _loadSupabaseData();
      notifyListeners();
      return null;
    } on AuthException catch (error) {
      _user = null;
      return error.message.toLowerCase().contains('invalid login')
          ? 'E-mail ou senha incorretos.'
          : 'Falha no acesso: ${error.message}';
    } on PostgrestException catch (error) {
      _user = null;
      await client?.auth.signOut();
      return 'Não foi possível carregar os dados. Confirme a migração do Supabase. (${error.message})';
    } catch (_) {
      _user = null;
      await client?.auth.signOut();
      return 'Não foi possível conectar ao Supabase. Verifique a conexão e tente novamente.';
    }
  }

  void _enterDemo() {
    _isDemo = true;
    _user = const AppUser(
        id: 'u1',
        name: 'Henrique Vieira',
        email: 'demo@fliperamada.ti',
        role: AppRole.admin);
    _section = AppSection.dashboard;
    _selectedPeriod = 'Hoje';
    _products = List.of(demoProducts);
    _machines = List.of(demoMachines);
    _suppliers = List.of(demoSuppliers);
    _team = List.of(demoTeam);
    _cashOpen = true;
    _cashOpenedAt =
        DateTime.now().subtract(const Duration(hours: 5, minutes: 24));
    _openingFloat = 150;
    _activeCashId = 'demo-cash-01';
    _sales = List.of(demoSales);
    _cashEntries = [
      CashEntry(
          type: 'Sangria',
          amount: 120,
          createdAt:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
          note: 'Retirada parcial'),
      CashEntry(
          type: 'Suprimento',
          amount: 80,
          createdAt:
              DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
          note: 'Reforço para troco'),
      ..._sales.where((sale) => sale.cashSessionId == _activeCashId).map(
          (sale) => CashEntry(
              type: 'Venda',
              amount: sale.total,
              createdAt: sale.createdAt,
              note: '${sale.items} item(ns)',
              method: sale.method)),
      CashEntry(
          type: 'Fundo de troco',
          amount: 150,
          createdAt: _cashOpenedAt!,
          note: 'Abertura do turno')
    ];
    _cashEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _inventoryMovements = [
      {
        'product_id': 'p3',
        'product_name': 'Coca-Cola 350ml',
        'type': 'purchase',
        'quantity': 24,
        'operator': 'Lívia Martins',
        'created_at': DateTime.now().subtract(const Duration(days: 1))
      },
      {
        'product_id': 'p1',
        'product_name': 'Ficha Arcade',
        'type': 'sale',
        'quantity': -35,
        'operator': 'Caio Nunes',
        'created_at': DateTime.now().subtract(const Duration(hours: 2))
      }
    ];
    _maintenanceRecords = [
      {
        'machine_id': 'm3',
        'description': 'Revisão preventiva demonstrativa',
        'occurred_at': DateTime.now().subtract(const Duration(days: 41)),
        'parts': <Map<String, dynamic>>[]
      }
    ];
    _workShifts = [
      const WorkShift(
          id: 'ws1',
          employeeId: 'u3',
          name: 'Caio Nunes',
          weekday: 0,
          shiftIndex: 0),
      const WorkShift(
          id: 'ws2',
          employeeId: 'u2',
          name: 'Lívia Martins',
          weekday: 1,
          shiftIndex: 1),
      const WorkShift(
          id: 'ws3',
          employeeId: 'u4',
          name: 'Rafaela Costa',
          weekday: 4,
          shiftIndex: 2)
    ];
    _timeHistory = [
      TimeRecord(
          id: 't1',
          employeeId: 'u1',
          startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          endedAt: DateTime.now().subtract(const Duration(days: 1)))
    ];
    _clockedInAt = null;
    _activeTimeEntryId = null;
    _cart = [];
    _cartDiscount = 0;
    notifyListeners();
  }

  Future<void> _loadSupabaseData() async {
    final userId = _user!.id;
    final productRows = await client!
        .from('products')
        .select()
        .eq('is_active', true)
        .order('name');
    final machineRows =
        await client!.from('machines').select().order('asset_number');
    _products = (productRows as List)
        .map((row) => AppProduct.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    _machines = (machineRows as List)
        .map((row) => ArcadeMachine.fromMap(Map<String, dynamic>.from(row)))
        .toList();
    _suppliers = [];
    _team = [];
    final profiles = await client!.from('profiles').select().order('full_name');
    final details = role.canManage
        ? await client!.from('employee_details').select()
        : <dynamic>[];
    _team = (profiles as List).map((row) {
      final map = Map<String, dynamic>.from(row);
      final detail = details
          .cast<Map>()
          .where((entry) => entry['user_id'] == map['id'])
          .firstOrNull;
      final name = (map['full_name'] ?? 'Sem nome').toString();
      return TeamMember(
          id: map['id'].toString(),
          name: name,
          position: (detail?['position'] ??
                  _roleFromDatabase(map['role'].toString()).label)
              .toString(),
          role: _roleFromDatabase(map['role'].toString()),
          active: map['is_active'] == true,
          email: (map['email'] ?? '').toString(),
          avatar: name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
          cpf: (detail?['cpf'] ?? '').toString(),
          phone: (detail?['phone'] ?? '').toString(),
          baseSalary: (detail?['base_salary'] as num? ?? 0).toDouble(),
          admittedAt:
              DateTime.tryParse((detail?['admitted_at'] ?? '').toString()));
    }).toList();
    if (role.canManage) {
      final rows = await client!.from('suppliers').select().order('legal_name');
      _suppliers = (rows as List)
          .map((row) => Supplier(
              id: row['id'].toString(),
              name: row['legal_name'].toString(),
              taxId: (row['tax_id'] ?? '').toString(),
              contact: (row['contact'] ?? '').toString(),
              active: row['is_active'] == true))
          .toList();
    }
    final cash = await client!
        .from('cash_sessions')
        .select()
        .eq('operator_id', userId)
        .isFilter('closed_at', null)
        .maybeSingle();
    _cashOpen = cash != null;
    _activeCashId = cash?['id']?.toString();
    _cashOpenedAt =
        DateTime.tryParse((cash?['opened_at'] ?? '').toString())?.toLocal();
    _openingFloat = (cash?['opening_float'] as num? ?? 0).toDouble();
    _cashEntries = [];
    if (cash != null) {
      final movements = await client!
          .from('cash_movements')
          .select()
          .eq('cash_session_id', cash['id'])
          .order('created_at', ascending: false);
      _cashEntries = (movements as List)
          .map((row) => CashEntry(
              type: switch (row['movement_type']) {
                'opening_float' => 'Fundo de troco',
                'supply' => 'Suprimento',
                'withdrawal' => 'Sangria',
                _ => 'Venda'
              },
              amount: (row['amount'] as num).toDouble(),
              createdAt: DateTime.parse(row['created_at'].toString()).toLocal(),
              note: (row['justification'] ?? '').toString(),
              method: _paymentMethodFromDatabase(row['method'].toString())))
          .toList();
    }
    _sales = [];
    final since = DateTime.now()
        .subtract(const Duration(days: 65))
        .toUtc()
        .toIso8601String();
    var offset = 0;
    while (true) {
      final rows = await client!
          .from('sales')
          .select(
              '*,sale_payments(method,amount),sale_items(product_id,product_name,category,quantity,unit_price,unit_cost)')
          .eq('status', 'completed')
          .gte('created_at', since)
          .order('created_at', ascending: false)
          .range(offset, offset + 999);
      _sales.addAll((rows as List)
          .map((row) => _saleFromMap(Map<String, dynamic>.from(row))));
      if (rows.length < 1000) break;
      offset += 1000;
    }
    if (_activeCashId != null) {
      final rows = await client!
          .from('sales')
          .select(
              '*,sale_payments(method,amount),sale_items(product_id,product_name,category,quantity,unit_price,unit_cost)')
          .eq('status', 'completed')
          .eq('cash_session_id', _activeCashId!);
      for (final row in rows) {
        final sale = _saleFromMap(Map<String, dynamic>.from(row));
        if (!_sales.any((entry) => entry.id == sale.id)) _sales.add(sale);
      }
    }
    final inventory = await client!
        .from('inventory_movements')
        .select(
            '*,products(name),profiles!inventory_movements_operator_id_fkey(full_name)')
        .order('created_at', ascending: false)
        .limit(1000);
    _inventoryMovements = (inventory as List).map((row) {
      final map = Map<String, dynamic>.from(row);
      return {
        ...map,
        'type': map['movement_type'],
        'product_name': map['products']?['name'] ?? 'Produto',
        'operator': map['profiles']?['full_name'] ?? 'Equipe'
      };
    }).toList();
    final maintenance = await client!
        .from('maintenance_records')
        .select()
        .order('occurred_at', ascending: false)
        .limit(1000);
    _maintenanceRecords = (maintenance as List)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final shifts = await client!
        .from('work_shifts')
        .select('*,profiles(full_name)')
        .order('weekday');
    _workShifts = (shifts as List)
        .map((row) => WorkShift(
            id: row['id'].toString(),
            employeeId: row['employee_id'].toString(),
            name: (row['profiles']?['full_name'] ?? 'Equipe').toString(),
            weekday: (row['weekday'] as num).toInt(),
            shiftIndex: const ['Manhã', 'Tarde', 'Noite/Fim de Semana']
                .indexOf(row['shift_name'].toString())))
        .toList();
    final entries = await client!
        .from('time_entries')
        .select()
        .eq('employee_id', userId)
        .order('started_at', ascending: false)
        .limit(1000);
    _timeHistory = (entries as List)
        .map((row) => TimeRecord(
            id: row['id'].toString(),
            employeeId: row['employee_id'].toString(),
            startedAt: DateTime.parse(row['started_at'].toString()).toLocal(),
            endedAt: DateTime.tryParse((row['ended_at'] ?? '').toString())
                ?.toLocal()))
        .toList();
    final active =
        _timeHistory.where((entry) => entry.endedAt == null).firstOrNull;
    _activeTimeEntryId = active?.id;
    _clockedInAt = active?.startedAt;
  }

  SaleRecord _saleFromMap(Map<String, dynamic> map) {
    final amounts = <PaymentMethod, double>{};
    for (final payment in (map['sale_payments'] as List? ?? [])) {
      final method = _paymentMethodFromDatabase(payment['method'].toString());
      amounts[method] =
          (amounts[method] ?? 0) + (payment['amount'] as num).toDouble();
    }
    final lines = (map['sale_items'] as List? ?? [])
        .map((line) => SaleLine(
            productId: line['product_id'].toString(),
            name: line['product_name'].toString(),
            category: line['category'].toString(),
            quantity: (line['quantity'] as num).toInt(),
            unitPrice: (line['unit_price'] as num).toDouble(),
            unitCost: (line['unit_cost'] as num).toDouble()))
        .toList();
    return SaleRecord(
        id: map['id'].toString(),
        total: (map['total'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'].toString()).toLocal(),
        items: lines.fold(0, (sum, line) => sum + line.quantity),
        method: amounts.keys.firstOrNull ?? PaymentMethod.pix,
        paymentAmounts: amounts,
        lines: lines,
        cashSessionId: map['cash_session_id']?.toString());
  }

  AppRole _roleFromDatabase(String value) => switch (value) {
        'admin' => AppRole.admin,
        'manager' => AppRole.manager,
        'technician' => AppRole.technician,
        _ => AppRole.cashier
      };
  PaymentMethod _paymentMethodFromDatabase(String value) => switch (value) {
        'cash' => PaymentMethod.cash,
        'debit' => PaymentMethod.debit,
        'credit' => PaymentMethod.credit,
        _ => PaymentMethod.pix
      };
  void navigate(AppSection value) {
    if (!canAccess(value)) return;
    _section = value;
    notifyListeners();
  }

  void setPeriod(String value) {
    if (!const ['Hoje', '7 dias', 'Mês'].contains(value)) return;
    _selectedPeriod = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!_isDemo && loggedIn) await _loadSupabaseData();
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!_isDemo) await client?.auth.signOut();
    _user = null;
    _section = AppSection.dashboard;
    _cart = [];
    _cartDiscount = 0;
    _cashOpen = false;
    _activeCashId = null;
    _clockedInAt = null;
    _activeTimeEntryId = null;
    notifyListeners();
  }

  void addToCart(AppProduct product) {
    _cashPermission();
    if (!_cashOpen) {
      throw StateError('Abra o caixa antes de iniciar uma venda.');
    }
    final current =
        _products.where((entry) => entry.id == product.id).firstOrNull;
    if (current == null) throw StateError('Produto indisponível.');
    final index = _cart.indexWhere((line) => line.product.id == product.id);
    final already = index < 0 ? 0 : _cart[index].quantity;
    if (already >= current.stock) {
      throw StateError('Estoque insuficiente para ${product.name}.');
    }
    if (index < 0) {
      _cart.add(CartLine(product: current, quantity: 1));
    } else {
      _cart[index] = _cart[index].copyWith(quantity: already + 1);
    }
    notifyListeners();
  }

  void changeCartQuantity(String productId, int delta) {
    final index = _cart.indexWhere((line) => line.product.id == productId);
    if (index < 0) return;
    final next = _cart[index].quantity + delta;
    if (next <= 0) {
      _cart.removeAt(index);
    } else if (next > _cart[index].product.stock) {
      throw StateError('Não há estoque suficiente para essa quantidade.');
    } else {
      _cart[index] = _cart[index].copyWith(quantity: next);
    }
    if (_cartDiscount > cartSubtotal) _cartDiscount = cartSubtotal;
    notifyListeners();
  }

  void clearCart() {
    _cart = [];
    _cartDiscount = 0;
    notifyListeners();
  }

  void setDiscount(double amount) {
    _money(amount);
    if (!role.canGiveDiscount && amount > 0) {
      throw StateError('Desconto exige perfil Gerente ou Administrador.');
    }
    if (amount >= cartSubtotal && amount > 0) {
      throw StateError('O desconto deve ser menor que o subtotal.');
    }
    _cartDiscount = _round(amount);
    notifyListeners();
  }

  Future<void> openCash(double initialFloat) async {
    _cashPermission();
    _money(initialFloat);
    if (_cashOpen) throw StateError('Você já tem um caixa aberto.');
    if (_isDemo) {
      _openingFloat = _round(initialFloat);
      _cashOpenedAt = DateTime.now();
      _activeCashId = 'demo-${DateTime.now().microsecondsSinceEpoch}';
      _cashEntries = [
        CashEntry(
            type: 'Fundo de troco',
            amount: _openingFloat,
            createdAt: _cashOpenedAt!,
            note: 'Abertura do turno')
      ];
      _cashOpen = true;
    } else {
      await client!.rpc('open_cash', params: {'p_opening_float': initialFloat});
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> recordCashAdjustment(
      {required bool withdrawal,
      required double amount,
      required String justification}) async {
    _cashPermission();
    if (!_cashOpen) {
      throw StateError('Abra o caixa antes de registrar movimentações.');
    }
    if (withdrawal && !role.canWithdraw) {
      throw StateError('Sangria exige perfil Gerente ou Administrador.');
    }
    _money(amount, positive: true);
    if (justification.trim().length < 3) {
      throw StateError('A justificativa é obrigatória.');
    }
    if (withdrawal && amount > cashBalance) {
      throw StateError('A sangria não pode exceder o saldo em dinheiro.');
    }
    if (_isDemo) {
      _cashEntries.insert(
          0,
          CashEntry(
              type: withdrawal ? 'Sangria' : 'Suprimento',
              amount: _round(amount),
              createdAt: DateTime.now(),
              note: justification.trim()));
    } else {
      await client!.rpc('record_cash_adjustment', params: {
        'p_movement_type': withdrawal ? 'withdrawal' : 'supply',
        'p_amount': amount,
        'p_justification': justification.trim()
      });
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> completeSale(List<PaymentPart> payments) async {
    _cashPermission();
    if (!_cashOpen) {
      throw StateError('Abra o caixa antes de iniciar uma venda.');
    }
    if (_cart.isEmpty) throw StateError('Adicione um produto ao carrinho.');
    if (payments.isEmpty) throw StateError('Informe uma forma de pagamento.');
    for (final part in payments) {
      _money(part.amount, positive: true);
      if (part.method == PaymentMethod.cash) {
        _money(part.amountReceived);
        if (part.amountReceived < part.amount) {
          throw StateError('O valor recebido é menor que o pagamento.');
        }
      }
    }
    if ((_round(payments.fold<double>(0, (sum, part) => sum + part.amount)) -
                cartTotal)
            .abs() >
        .001) {
      throw StateError('A soma dos pagamentos deve ser igual ao total.');
    }
    for (final line in _cart) {
      final product =
          _products.where((entry) => entry.id == line.product.id).firstOrNull;
      if (product == null || product.stock < line.quantity) {
        throw StateError('Estoque insuficiente para ${line.product.name}.');
      }
    }
    if (_isDemo) {
      final now = DateTime.now();
      final lines = _cart
          .map((line) => SaleLine(
              productId: line.product.id,
              name: line.product.name,
              category: line.product.category,
              quantity: line.quantity,
              unitPrice: line.product.price,
              unitCost: line.product.unitCost))
          .toList();
      final amounts = <PaymentMethod, double>{};
      for (final part in payments) {
        amounts[part.method] =
            _round((amounts[part.method] ?? 0) + part.amount);
      }
      final sale = SaleRecord(
          id: 'v${now.microsecondsSinceEpoch}',
          total: cartTotal,
          createdAt: now,
          items: lines.fold(0, (sum, line) => sum + line.quantity),
          method: payments.first.method,
          paymentAmounts: amounts,
          lines: lines,
          cashSessionId: _activeCashId);
      for (final line in _cart) {
        final index =
            _products.indexWhere((product) => product.id == line.product.id);
        _products[index] = _products[index]
            .copyWith(stock: _products[index].stock - line.quantity);
        _inventoryMovements.insert(0, {
          'product_id': line.product.id,
          'product_name': line.product.name,
          'type': 'sale',
          'quantity': -line.quantity,
          'operator': _user!.name,
          'created_at': now
        });
      }
      _sales.insert(0, sale);
      _cashEntries.insert(
          0,
          CashEntry(
              type: 'Venda',
              amount: sale.total,
              createdAt: now,
              note:
                  '${sale.items} item(ns) · ${amounts.length > 1 ? 'Pagamento combinado' : payments.first.label}',
              method: sale.method));
      clearCart();
    } else {
      await client!.rpc('create_sale', params: {
        'p_items': _cart
            .map((line) =>
                {'product_id': line.product.id, 'quantity': line.quantity})
            .toList(),
        'p_payments': payments
            .map((part) => {
                  'method': part.databaseValue,
                  'amount': part.amount,
                  'amount_received': part.method == PaymentMethod.cash
                      ? part.amountReceived
                      : part.amount
                })
            .toList(),
        'p_discount': _cartDiscount
      });
      _cart = [];
      _cartDiscount = 0;
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> closeCash(
      {required Map<String, double> counted, required String note}) async {
    _cashPermission();
    if (!_cashOpen) throw StateError('Não há caixa aberto para fechar.');
    for (final key in expectedCash.keys) {
      if (!counted.containsKey(key)) {
        throw StateError('Informe o valor contado de $key.');
      }
      _money(counted[key]!);
    }
    final expected = expectedCash;
    final divergent = expected.entries.any(
        (entry) => (_round(counted[entry.key]!) - entry.value).abs() > .001);
    if (divergent && note.trim().length < 3) {
      throw StateError('Descreva a diferença antes de concluir.');
    }
    if (_isDemo) {
      final difference = expected.entries.fold<double>(
          0, (sum, entry) => sum + _round(counted[entry.key]!) - entry.value);
      _cashEntries.insert(
          0,
          CashEntry(
              type: 'Fechamento',
              amount: _round(difference),
              createdAt: DateTime.now(),
              note: note));
      _cashOpen = false;
      _activeCashId = null;
    } else {
      const keys = {
        'Dinheiro': 'cash',
        'PIX': 'pix',
        'Débito': 'debit',
        'Crédito': 'credit'
      };
      await client!.rpc('close_cash', params: {
        'p_counted': {
          for (final entry in keys.entries) entry.value: counted[entry.key]
        },
        'p_note': note.trim()
      });
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> registerStockReceipt(
      {required String? supplierId,
      required List<Map<String, dynamic>> lines,
      required String note,
      DateTime? occurredAt}) async {
    _manage();
    if (lines.isEmpty) {
      throw StateError('Adicione ao menos um produto à entrada.');
    }
    if (lines.map((line) => line['product_id']).toSet().length !=
        lines.length) {
      throw StateError(
          'Não repita o mesmo produto na entrada; ajuste a quantidade.');
    }
    if (supplierId != null &&
        !_suppliers
            .any((supplier) => supplier.id == supplierId && supplier.active)) {
      throw StateError('Fornecedor inativo ou inexistente.');
    }
    for (final line in lines) {
      final qty = (line['quantity'] as num?)?.toInt() ?? 0;
      final cost = (line['unit_cost'] as num?)?.toDouble() ?? double.nan;
      if (qty <= 0 ||
          !_products.any((product) => product.id == line['product_id'])) {
        throw StateError('Confira os produtos e quantidades.');
      }
      _money(cost);
    }
    final time = occurredAt ?? DateTime.now();
    if (time.isAfter(DateTime.now())) {
      throw StateError('A data da entrada não pode estar no futuro.');
    }
    if (_isDemo) {
      for (final line in lines) {
        final index =
            _products.indexWhere((product) => product.id == line['product_id']);
        final qty = (line['quantity'] as num).toInt();
        final cost = (line['unit_cost'] as num).toDouble();
        _products[index] = _products[index]
            .copyWith(stock: _products[index].stock + qty, unitCost: cost);
        _inventoryMovements.insert(0, {
          'product_id': _products[index].id,
          'product_name': _products[index].name,
          'type': 'purchase',
          'quantity': qty,
          'operator': _user!.name,
          'created_at': time,
          'note': note,
          'unit_cost': cost
        });
      }
    } else {
      await client!.rpc('register_stock_receipt', params: {
        'p_supplier_id': supplierId,
        'p_lines': lines,
        'p_note': note.trim(),
        'p_occurred_at': time.toUtc().toIso8601String()
      });
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> registerPartExit(
      {required String machineId,
      required String productId,
      required int quantity,
      required String note}) async {
    if (!role.canManage && role != AppRole.technician) {
      throw StateError(
          'Saída de peça exige perfil Técnico, Gerente ou Administrador.');
    }
    if (quantity <= 0) {
      throw StateError('Informe uma quantidade maior que zero.');
    }
    final index = _products.indexWhere((product) => product.id == productId);
    final machineIndex =
        _machines.indexWhere((machine) => machine.id == machineId);
    if (index < 0 || machineIndex < 0) {
      throw StateError('Produto ou máquina não encontrado.');
    }
    if (_products[index].stock < quantity) {
      throw StateError('Estoque insuficiente para essa peça.');
    }
    if (_isDemo) {
      final now = DateTime.now();
      final product = _products[index];
      _products[index] = product.copyWith(stock: product.stock - quantity);
      final machine = _machines[machineIndex];
      _machines[machineIndex] = machine.copyWith(
          status: machine.status == MachineStatus.active
              ? MachineStatus.maintenance
              : machine.status,
          maintenanceCount: machine.maintenanceCount + 1);
      _inventoryMovements.insert(0, {
        'product_id': product.id,
        'product_name': product.name,
        'type': 'maintenance',
        'quantity': -quantity,
        'operator': _user!.name,
        'created_at': now,
        'machine_id': machineId,
        'note': note
      });
      _maintenanceRecords.insert(0, {
        'machine_id': machineId,
        'description': note.trim().isEmpty
            ? 'Saída de peça: ${product.name}'
            : note.trim(),
        'occurred_at': now,
        'parts': [
          {'product_name': product.name, 'quantity': quantity}
        ]
      });
    } else {
      await client!.rpc('register_part_exit', params: {
        'p_machine_id': machineId,
        'p_product_id': productId,
        'p_quantity': quantity,
        'p_note': note.trim()
      });
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> deactivateSupplier(String supplierId) async {
    _manage();
    if (_isDemo) {
      _suppliers = _suppliers
          .map((supplier) => supplier.id == supplierId
              ? supplier.copyWith(active: false)
              : supplier)
          .toList();
    } else {
      await client!
          .from('suppliers')
          .update({'is_active': false}).eq('id', supplierId);
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> saveTeamMember(
      {String? userId,
      required String name,
      required String cpf,
      required String position,
      required String phone,
      required String email,
      required double salary,
      required AppRole role,
      required DateTime admittedAt,
      bool active = true}) async {
    _manage();
    _money(salary);
    if (name.trim().length < 3 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      throw StateError('Informe nome e e-mail válidos.');
    }
    if (this.role != AppRole.admin &&
        (role == AppRole.admin || role == AppRole.manager)) {
      throw StateError(
          'Somente o Administrador pode atribuir perfis de gestão.');
    }
    if (_isDemo) {
      final id = userId ?? 'demo-${DateTime.now().microsecondsSinceEpoch}';
      final member = TeamMember(
          id: id,
          name: name.trim(),
          cpf: cpf,
          position: position,
          phone: phone,
          email: email,
          baseSalary: salary,
          role: role,
          active: active,
          admittedAt: admittedAt,
          avatar: name.trim().substring(0, 1).toUpperCase());
      final index = _team.indexWhere((person) => person.id == id);
      if (index < 0) {
        _team.add(member);
      } else {
        _team[index] = member;
      }
    } else {
      await client!.rpc('save_employee_profile', params: {
        'p_user_id': userId,
        'p_email': email.trim(),
        'p_full_name': name.trim(),
        'p_role': role.databaseValue,
        'p_active': active,
        'p_cpf': cpf.trim(),
        'p_position': position.trim(),
        'p_phone': phone.trim(),
        'p_salary': salary,
        'p_admitted_at': admittedAt.toIso8601String().substring(0, 10)
      });
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> assignWorkShift(
      String employeeId, int weekday, int shiftIndex) async {
    _manage();
    if (weekday < 0 || weekday > 6 || shiftIndex < 0 || shiftIndex > 2) {
      throw StateError('Turno inválido.');
    }
    final employee = _team
        .where((person) => person.id == employeeId && person.active)
        .firstOrNull;
    if (employee == null) {
      throw StateError('Colaborador inativo ou inexistente.');
    }
    if (_workShifts.any((shift) =>
        shift.weekday == weekday && shift.shiftIndex == shiftIndex)) {
      throw StateError(
          'Esse bloco já tem um colaborador. Escolha outro turno.');
    }
    if (_isDemo) {
      _workShifts.add(WorkShift(
          id: 'ws${DateTime.now().microsecondsSinceEpoch}',
          employeeId: employeeId,
          name: employee.name,
          weekday: weekday,
          shiftIndex: shiftIndex));
    } else {
      await client!
          .from('work_shifts')
          .insert(_shiftPayload(employeeId, weekday, shiftIndex));
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Map<String, dynamic> _shiftPayload(
          String employeeId, int weekday, int shiftIndex) =>
      {
        'employee_id': employeeId,
        'weekday': weekday,
        'shift_name': const [
          'Manhã',
          'Tarde',
          'Noite/Fim de Semana'
        ][shiftIndex],
        'start_time': const ['09:00', '15:00', '21:00'][shiftIndex],
        'end_time': const ['15:00', '21:00', '02:00'][shiftIndex]
      };
  Future<void> moveWorkShift(String id, int weekday, int shiftIndex) async {
    _manage();
    if (weekday < 0 || weekday > 6 || shiftIndex < 0 || shiftIndex > 2) {
      throw StateError('Turno inválido.');
    }
    final index = _workShifts.indexWhere((shift) => shift.id == id);
    if (index < 0) throw StateError('Escala não encontrada.');
    if (_workShifts.any((shift) =>
        shift.id != id &&
        shift.weekday == weekday &&
        shift.shiftIndex == shiftIndex)) {
      throw StateError(
          'O destino já tem um colaborador; nenhum bloco foi removido.');
    }
    final shift = _workShifts[index];
    if (_isDemo) {
      _workShifts[index] = WorkShift(
          id: id,
          employeeId: shift.employeeId,
          name: shift.name,
          weekday: weekday,
          shiftIndex: shiftIndex);
    } else {
      await client!
          .from('work_shifts')
          .update(_shiftPayload(shift.employeeId, weekday, shiftIndex))
          .eq('id', id);
      await _loadSupabaseData();
    }
    notifyListeners();
  }

  Future<void> toggleTimeClock() async {
    if (_isDemo) {
      final now = DateTime.now();
      if (_activeTimeEntryId == null) {
        _activeTimeEntryId = 't${now.microsecondsSinceEpoch}';
        _clockedInAt = now;
        _timeHistory.insert(
            0,
            TimeRecord(
                id: _activeTimeEntryId!,
                employeeId: _user!.id,
                startedAt: now));
      } else {
        final index =
            _timeHistory.indexWhere((entry) => entry.id == _activeTimeEntryId);
        final entry = _timeHistory[index];
        _timeHistory[index] = TimeRecord(
            id: entry.id,
            employeeId: entry.employeeId,
            startedAt: entry.startedAt,
            endedAt: now);
        _activeTimeEntryId = null;
        _clockedInAt = null;
      }
    } else if (_activeTimeEntryId == null) {
      await client!.from('time_entries').insert({'employee_id': _user!.id});
      await _loadSupabaseData();
    } else {
      await client!
          .rpc('end_time_entry', params: {'p_entry_id': _activeTimeEntryId});
      await _loadSupabaseData();
    }
    notifyListeners();
  }
}
