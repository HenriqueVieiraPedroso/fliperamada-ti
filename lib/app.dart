import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data/app_controller.dart';
import 'features/login.dart';
import 'features/shell.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AppController>(
        builder: (context, app, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: app.loggedIn
              ? const AppShell(key: ValueKey('shell'))
              : const LoginScreen(key: ValueKey('login')),
        ),
      );
}
