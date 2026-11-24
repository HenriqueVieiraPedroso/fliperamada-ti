import 'package:material_ui/material_ui.dart';

import '../models/domain.dart';

final demoProducts = <AppProduct>[
  const AppProduct(
      id: 'p1',
      name: 'Ficha Arcade',
      category: 'Fichas',
      price: 5,
      stock: 480,
      minimum: 100,
      icon: Icons.toll_rounded,
      unitCost: 2),
  const AppProduct(
      id: 'p2',
      name: 'Combo 5 Fichas',
      category: 'Fichas',
      price: 22,
      stock: 160,
      minimum: 40,
      icon: Icons.token_rounded,
      unitCost: 9),
  const AppProduct(
      id: 'p3',
      name: 'Coca-Cola 350ml',
      category: 'Bebidas',
      price: 7,
      stock: 14,
      minimum: 18,
      icon: Icons.local_drink_outlined,
      unitCost: 3.8),
  const AppProduct(
      id: 'p4',
      name: 'Água Mineral',
      category: 'Bebidas',
      price: 4,
      stock: 32,
      minimum: 12,
      icon: Icons.water_drop_outlined,
      unitCost: 1.2),
  const AppProduct(
      id: 'p5',
      name: 'Energético Pixel',
      category: 'Bebidas',
      price: 12,
      stock: 9,
      minimum: 12,
      icon: Icons.bolt_rounded,
      unitCost: 6.5),
  const AppProduct(
      id: 'p6',
      name: 'Batata Chips',
      category: 'Snacks',
      price: 8,
      stock: 21,
      minimum: 10,
      icon: Icons.fastfood_outlined,
      unitCost: 3.9),
  const AppProduct(
      id: 'p7',
      name: 'Chocolate 8-bit',
      category: 'Snacks',
      price: 6,
      stock: 6,
      minimum: 10,
      icon: Icons.cookie_outlined,
      unitCost: 2.7),
  const AppProduct(
      id: 'p8',
      name: 'Combo Gamer',
      category: 'Snacks',
      price: 18,
      stock: 17,
      minimum: 8,
      icon: Icons.sports_esports_outlined,
      unitCost: 8),
];

final demoMachines = <ArcadeMachine>[
  ArcadeMachine(
      id: 'm1',
      game: 'Pac-Man',
      asset: 'FLT-001',
      status: MachineStatus.active,
      acquired: DateTime(2023, 3, 17),
      maintenanceCount: 2),
  ArcadeMachine(
      id: 'm2',
      game: 'Street Fighter II',
      asset: 'FLT-002',
      status: MachineStatus.active,
      acquired: DateTime(2022, 9, 4),
      maintenanceCount: 5),
  ArcadeMachine(
      id: 'm3',
      game: 'Metal Slug',
      asset: 'FLT-003',
      status: MachineStatus.maintenance,
      acquired: DateTime(2024, 1, 26),
      maintenanceCount: 3),
  ArcadeMachine(
      id: 'm4',
      game: 'Galaga',
      asset: 'FLT-004',
      status: MachineStatus.active,
      acquired: DateTime(2021, 12, 2),
      maintenanceCount: 1),
  ArcadeMachine(
      id: 'm5',
      game: 'Donkey Kong',
      asset: 'FLT-005',
      status: MachineStatus.inactive,
      acquired: DateTime(2023, 7, 11),
      maintenanceCount: 4),
  ArcadeMachine(
      id: 'm6',
      game: 'Mortal Kombat',
      asset: 'FLT-006',
      status: MachineStatus.active,
      acquired: DateTime(2024, 6, 8),
      maintenanceCount: 2),
];

final demoSuppliers = <Supplier>[
  const Supplier(
      id: 's1',
      name: 'Distribuidora Neon',
      taxId: '12.345.678/0001-90',
      contact: '(11) 98812-3040'),
  const Supplier(
      id: 's2',
      name: 'Bebidas Pixel Ltda.',
      taxId: '45.612.098/0001-21',
      contact: 'vendas@pixel.example'),
  const Supplier(
      id: 's3',
      name: 'Snack Station',
      taxId: '31.602.451/0001-45',
      contact: '(11) 3124-6650'),
  const Supplier(
      id: 's4',
      name: 'Arcade Parts BR',
      taxId: '08.234.567/0001-03',
      contact: 'pecas@arcade.example'),
];

final demoTeam = <TeamMember>[
  TeamMember(
      id: 'u1',
      name: 'Henrique Vieira',
      position: 'Administrador',
      role: AppRole.admin,
      active: true,
      email: 'henrique@fliperamada.com',
      phone: '(11) 99920-1820',
      cpf: '***.***.***-**',
      baseSalary: 0,
      admittedAt: DateTime(2022, 5, 9),
      avatar: 'H'),
  TeamMember(
      id: 'u2',
      name: 'Lívia Martins',
      position: 'Gerente de Operações',
      role: AppRole.manager,
      active: true,
      email: 'livia@fliperamada.com',
      phone: '(11) 98845-1200',
      cpf: '***.***.***-**',
      baseSalary: 4200,
      admittedAt: DateTime(2023, 2, 13),
      avatar: 'L'),
  TeamMember(
      id: 'u3',
      name: 'Caio Nunes',
      position: 'Operador de Caixa',
      role: AppRole.cashier,
      active: true,
      email: 'caio@fliperamada.com',
      phone: '(11) 99130-6822',
      cpf: '***.***.***-**',
      baseSalary: 2380,
      admittedAt: DateTime(2024, 4, 2),
      avatar: 'C'),
  TeamMember(
      id: 'u4',
      name: 'Rafaela Costa',
      position: 'Técnica de Arcade',
      role: AppRole.technician,
      active: true,
      email: 'rafaela@fliperamada.com',
      phone: '(11) 99941-8855',
      cpf: '***.***.***-**',
      baseSalary: 3100,
      admittedAt: DateTime(2024, 9, 21),
      avatar: 'R'),
];

final demoSales = <SaleRecord>[
  for (var day = 0; day < 38; day++)
    for (var i = 0; i < 6; i++) _demoSale(day, i),
];

SaleRecord _demoSale(int day, int i) {
  final now = DateTime.now();
  final token = demoProducts[i % 2];
  final convenience = demoProducts[2 + i % 6];
  final quantity = 2 + (i + day) % 4;
  final lines = [
    SaleLine(
        productId: token.id,
        name: token.name,
        category: token.category,
        quantity: quantity,
        unitPrice: token.price,
        unitCost: token.unitCost),
    SaleLine(
        productId: convenience.id,
        name: convenience.name,
        category: convenience.category,
        quantity: 1,
        unitPrice: convenience.price,
        unitCost: convenience.unitCost),
  ];
  final method = PaymentMethod.values[i % 4];
  return SaleRecord(
      id: 'demo-$day-$i',
      total: lines.fold<double>(0, (sum, line) => sum + line.total),
      createdAt: (day == 0
          ? now.subtract(Duration(minutes: 15 + i * 45))
          : DateTime(now.year, now.month, now.day - day, 10 + i * 2, 15)),
      items: quantity + 1,
      method: method,
      lines: lines,
      cashSessionId: day == 0 ? 'demo-cash-01' : 'demo-old-$day');
}
