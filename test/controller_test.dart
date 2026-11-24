import 'package:flutter_test/flutter_test.dart';
import 'package:fliperamada_ti/core/money.dart';
import 'package:fliperamada_ti/data/app_controller.dart';
import 'package:fliperamada_ti/models/domain.dart';

void main() {
  group('Valores monetários pt-BR', () {
    test('preserva pontos decimais e aceita agrupamento brasileiro', () {
      expect(parseMoney('22.00'), 22);
      expect(parseMoney('22,00'), 22);
      expect(parseMoney('R\$ 1.234,56'), 1234.56);
      expect(parseMoney('1.23.4'), isNull);
      expect(parseMoney('NaN'), isNull);
      expect(parseMoney(''), isNull);
    });
  });
  late AppController app;
  setUp(() async {
    app = AppController(client: null);
    await app.signIn('demo@example.com', 'demo');
  });
  tearDown(() => app.dispose());
  test('pagamento dividido atualiza métodos, caixa e estoque sem duplicação',
      () async {
    final product = app.products.first;
    final oldStock = product.stock;
    final cash = app.cashBalance;
    final pix = app.sessionPaymentTotals[PaymentMethod.pix]!;
    app.addToCart(product);
    await app.completeSale([
      const PaymentPart(method: PaymentMethod.pix, amount: 2),
      const PaymentPart(
          method: PaymentMethod.cash, amount: 3, amountReceived: 10)
    ]);
    expect(app.cashBalance, closeTo(cash + 3, .001));
    expect(app.sessionPaymentTotals[PaymentMethod.pix], closeTo(pix + 2, .001));
    expect(app.products.first.stock, oldStock - 1);
    expect(app.sales.first.paidBy(PaymentMethod.debit), 0);
    expect(app.cart, isEmpty);
  });
  test('reabrir caixa não herda vendas e ajustes do turno anterior', () async {
    await app.closeCash(counted: app.expectedCash, note: '');
    expect(app.cashOpen, false);
    expect(() => app.addToCart(app.products.first), throwsStateError);
    await app.openCash(50);
    expect(app.cashBalance, 50);
    expect(app.sessionSales, isEmpty);
    expect(app.cashEntries.length, 1);
    expect(app.expectedCash['PIX'], 0);
    await expectLater(app.openCash(20), throwsStateError);
  });
  test('diferenças por método não se anulam para dispensar observação',
      () async {
    final counts = Map<String, double>.from(app.expectedCash);
    counts['Dinheiro'] = counts['Dinheiro']! + 10;
    counts['PIX'] = counts['PIX']! - 10;
    await expectLater(
        app.closeCash(counted: counts, note: ''), throwsStateError);
    expect(app.cashOpen, true);
    await app.closeCash(counted: counts, note: 'Conferência entre formas');
    expect(app.cashOpen, false);
  });
  test('valores inválidos e estoque insuficiente não alteram os dados',
      () async {
    await expectLater(app.openCash(double.nan), throwsStateError);
    final product = app.products.first;
    app.addToCart(product);
    await expectLater(
        app.completeSale([
          const PaymentPart(
              method: PaymentMethod.cash, amount: 5, amountReceived: 4)
        ]),
        throwsStateError);
    expect(app.products.first.stock, product.stock);
    await expectLater(
        app.registerStockReceipt(
            supplierId: null,
            lines: [
              {'product_id': product.id, 'quantity': -2, 'unit_cost': 1}
            ],
            note: ''),
        throwsStateError);
    expect(app.products.first.stock, product.stock);
  });
  test('fornecedor inativado é preservado e não recebe novas entradas',
      () async {
    final supplier = app.suppliers.first;
    await app.deactivateSupplier(supplier.id);
    expect(app.suppliers.first.active, false);
    await expectLater(
        app.registerStockReceipt(
            supplierId: supplier.id,
            lines: [
              {
                'product_id': app.products.first.id,
                'quantity': 2,
                'unit_cost': 1
              }
            ],
            note: ''),
        throwsStateError);
    expect(app.suppliers.length, 4);
  });
  test('baixa de peça é vinculada à máquina e atualiza histórico', () async {
    final machine = app.machines.first;
    final product = app.products.first;
    await app.registerPartExit(
        machineId: machine.id,
        productId: product.id,
        quantity: 1,
        note: 'Teste de manutenção');
    expect(app.machines.first.status, MachineStatus.maintenance);
    expect(app.machines.first.maintenanceCount, machine.maintenanceCount + 1);
    expect(app.maintenanceRecords.first['machine_id'], machine.id);
    expect(app.products.first.stock, product.stock - 1);
  });
  test('ponto grava início e encerramento no histórico', () async {
    await app.toggleTimeClock();
    expect(app.clockedInAt, isNotNull);
    await app.toggleTimeClock();
    expect(app.clockedInAt, isNull);
    expect(app.timeHistory.first.endedAt, isNotNull);
  });
  test('arrastar para escala ocupada mantém ambos os blocos', () async {
    final first = app.workShifts.first;
    final second = app.workShifts[1];
    await expectLater(
        app.moveWorkShift(first.id, second.weekday, second.shiftIndex),
        throwsStateError);
    expect(app.workShifts.length, 3);
    expect(app.workShifts.first.weekday, first.weekday);
  });
}
