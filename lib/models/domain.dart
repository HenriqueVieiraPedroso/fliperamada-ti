import 'package:material_ui/material_ui.dart';

enum AppRole { admin, manager, cashier, technician }

enum AppSection {
  dashboard,
  pos,
  inventory,
  machines,
  cash,
  finance,
  team,
  reports
}

enum PaymentMethod { cash, pix, debit, credit }

enum MachineStatus { active, maintenance, inactive }

extension AppRoleLabel on AppRole {
  String get label => switch (this) {
        AppRole.admin => 'Administrador',
        AppRole.manager => 'Gerente',
        AppRole.cashier => 'Operador de Caixa',
        AppRole.technician => 'Técnico',
      };

  String get databaseValue => switch (this) {
        AppRole.admin => 'admin',
        AppRole.manager => 'manager',
        AppRole.cashier => 'cashier',
        AppRole.technician => 'technician',
      };

  bool get canManage => this == AppRole.admin || this == AppRole.manager;
  bool get canGiveDiscount => canManage;
  bool get canWithdraw => canManage;
}

extension AppSectionLabel on AppSection {
  String get label => switch (this) {
        AppSection.dashboard => 'Dashboard',
        AppSection.pos => 'PDV',
        AppSection.inventory => 'Estoque',
        AppSection.machines => 'Máquinas',
        AppSection.cash => 'Caixa',
        AppSection.finance => 'Financeiro',
        AppSection.team => 'Equipe',
        AppSection.reports => 'Relatórios',
      };

  IconData get icon => switch (this) {
        AppSection.dashboard => Icons.grid_view_rounded,
        AppSection.pos => Icons.point_of_sale_rounded,
        AppSection.inventory => Icons.inventory_2_outlined,
        AppSection.machines => Icons.videogame_asset_outlined,
        AppSection.cash => Icons.account_balance_wallet_outlined,
        AppSection.finance => Icons.payments_outlined,
        AppSection.team => Icons.groups_2_outlined,
        AppSection.reports => Icons.insert_chart_outlined_rounded,
      };
}

class AppUser {
  const AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.role});
  final String id;
  final String name;
  final String email;
  final AppRole role;
}

class AppProduct {
  const AppProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.minimum,
    required this.icon,
    this.unitCost = 0,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int minimum;
  final IconData icon;
  final double unitCost;

  bool get isLow => stock <= minimum;
  AppProduct copyWith({int? stock, double? price, double? unitCost}) =>
      AppProduct(
        id: id,
        name: name,
        category: category,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        minimum: minimum,
        icon: icon,
        unitCost: unitCost ?? this.unitCost,
      );

  factory AppProduct.fromMap(Map<String, dynamic> map) => AppProduct(
        id: map['id'].toString(),
        name: (map['name'] ?? '').toString(),
        category: (map['category'] ?? 'Snacks').toString(),
        price: (map['price'] as num? ?? 0).toDouble(),
        stock: (map['stock_qty'] as num? ?? 0).toInt(),
        minimum: (map['stock_min'] as num? ?? 0).toInt(),
        icon: productIcon((map['icon_key'] ?? '').toString()),
        unitCost: (map['unit_cost'] as num? ?? 0).toDouble(),
      );
}

IconData productIcon(String key) => switch (key) {
      'token' => Icons.toll_rounded,
      'drink' => Icons.local_drink_outlined,
      'snack' => Icons.fastfood_outlined,
      'coffee' => Icons.coffee_outlined,
      'game' => Icons.sports_esports_outlined,
      _ => Icons.inventory_2_outlined,
    };

class ArcadeMachine {
  const ArcadeMachine({
    required this.id,
    required this.game,
    required this.asset,
    required this.status,
    required this.acquired,
    required this.maintenanceCount,
  });

  final String id;
  final String game;
  final String asset;
  final MachineStatus status;
  final DateTime? acquired;
  final int maintenanceCount;

  String get statusLabel => switch (status) {
        MachineStatus.active => 'Ativa',
        MachineStatus.maintenance => 'Em Manutenção',
        MachineStatus.inactive => 'Inativa',
      };

  ArcadeMachine copyWith({MachineStatus? status, int? maintenanceCount}) =>
      ArcadeMachine(
        id: id,
        game: game,
        asset: asset,
        status: status ?? this.status,
        acquired: acquired,
        maintenanceCount: maintenanceCount ?? this.maintenanceCount,
      );

  Color get statusColor => switch (status) {
        MachineStatus.active => const Color(0xFF15803D),
        MachineStatus.maintenance => const Color(0xFFFFD60A),
        MachineStatus.inactive => const Color(0xFF72748A),
      };

  factory ArcadeMachine.fromMap(Map<String, dynamic> map) => ArcadeMachine(
        id: map['id'].toString(),
        game: (map['game_name'] ?? '').toString(),
        asset: (map['asset_number'] ?? '').toString(),
        status: switch (map['status']) {
          'maintenance' => MachineStatus.maintenance,
          'inactive' => MachineStatus.inactive,
          _ => MachineStatus.active,
        },
        acquired: DateTime.tryParse((map['acquired_at'] ?? '').toString()),
        maintenanceCount: (map['maintenance_count'] as num? ?? 0).toInt(),
      );
}

class Supplier {
  const Supplier(
      {required this.id,
      required this.name,
      required this.taxId,
      required this.contact,
      this.active = true});
  final String id;
  final String name;
  final String taxId;
  final String contact;
  final bool active;
  Supplier copyWith({bool? active}) => Supplier(
      id: id,
      name: name,
      taxId: taxId,
      contact: contact,
      active: active ?? this.active);
}

class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.position,
    required this.role,
    required this.active,
    required this.email,
    this.phone = '',
    this.cpf = '',
    this.baseSalary = 0,
    this.admittedAt,
    this.avatar = 'F',
  });
  final String id;
  final String name;
  final String position;
  final AppRole role;
  final bool active;
  final String email;
  final String phone;
  final String cpf;
  final double baseSalary;
  final DateTime? admittedAt;
  final String avatar;
}

class CartLine {
  const CartLine({required this.product, required this.quantity});
  final AppProduct product;
  final int quantity;
  double get total => product.price * quantity;
  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

class PaymentPart {
  const PaymentPart(
      {required this.method, required this.amount, this.amountReceived = 0});
  final PaymentMethod method;
  final double amount;
  final double amountReceived;

  String get label => switch (method) {
        PaymentMethod.cash => 'Dinheiro',
        PaymentMethod.pix => 'PIX',
        PaymentMethod.debit => 'Débito',
        PaymentMethod.credit => 'Crédito',
      };

  String get databaseValue => switch (method) {
        PaymentMethod.cash => 'cash',
        PaymentMethod.pix => 'pix',
        PaymentMethod.debit => 'debit',
        PaymentMethod.credit => 'credit',
      };
}

class SaleRecord {
  const SaleRecord(
      {required this.id,
      required this.total,
      required this.createdAt,
      required this.items,
      required this.method,
      this.paymentAmounts,
      this.lines = const [],
      this.cashSessionId});
  final String id;
  final double total;
  final DateTime createdAt;
  final int items;
  final PaymentMethod method;
  final List<SaleLine> lines;
  final String? cashSessionId;
  final Map<PaymentMethod, double>? paymentAmounts;
  double paidBy(PaymentMethod value) => paymentAmounts == null
      ? (method == value ? total : 0)
      : paymentAmounts![value] ?? 0;
}

class CashEntry {
  const CashEntry({
    required this.type,
    required this.amount,
    required this.createdAt,
    this.note = '',
    this.method = PaymentMethod.cash,
  });
  final String type;
  final double amount;
  final DateTime createdAt;
  final String note;
  final PaymentMethod method;
}

class SaleLine {
  const SaleLine(
      {required this.productId,
      required this.name,
      required this.category,
      required this.quantity,
      required this.unitPrice,
      required this.unitCost});
  final String productId;
  final String name;
  final String category;
  final int quantity;
  final double unitPrice;
  final double unitCost;
  double get total => quantity * unitPrice;
}

class WorkShift {
  const WorkShift(
      {required this.id,
      required this.employeeId,
      required this.name,
      required this.weekday,
      required this.shiftIndex});
  final String id;
  final String employeeId;
  final String name;
  final int weekday;
  final int shiftIndex;
}

class TimeRecord {
  const TimeRecord(
      {required this.id,
      required this.employeeId,
      required this.startedAt,
      this.endedAt});
  final String id;
  final String employeeId;
  final DateTime startedAt;
  final DateTime? endedAt;
  double get hours =>
      (endedAt ?? DateTime.now()).difference(startedAt).inMinutes / 60;
}
