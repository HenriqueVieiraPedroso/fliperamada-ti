import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:fliperamada_ti/main.dart';
import 'package:fliperamada_ti/data/app_controller.dart';
import 'package:fliperamada_ti/models/domain.dart';

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1440, 900)
  ]) {
    testWidgets('Telas sem overflow em ${size.width.toInt()} px',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          FlutterError.dumpErrorToConsole(details, forceReport: true);
        }
        previousErrorHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousErrorHandler);
      final app = AppController(client: null);
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: app, child: const FliperamadaApp()));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'Login ${size.width}');
      await tester.tap(find.text('EXPLORAR DEMONSTRAÇÃO'));
      await tester.pump();
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: app, child: const FliperamadaApp()));
      for (final section in AppSection.values) {
        app.navigate(section);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull,
            reason: 'Layout ${section.label} ${size.width}');
      }
      await tester.pumpWidget(const SizedBox.shrink());
      app.dispose();
    });
  }
}
