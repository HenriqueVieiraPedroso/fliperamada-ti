import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/theme.dart';
import 'data/app_controller.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseClient? client;
  String? startupError;
  if (_supabaseUrl.isNotEmpty && _supabasePublishableKey.isNotEmpty) {
    try {
      await Supabase.initialize(
          url: _supabaseUrl, publishableKey: _supabasePublishableKey);
      client = Supabase.instance.client;
    } catch (error) {
      startupError =
          'Não foi possível inicializar o Supabase. Verifique a URL e a chave publishable.';
      debugPrint('Falha de inicialização Supabase: $error');
    }
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(
          create: (_) =>
              AppController(client: client, startupError: startupError)),
    ],
    child: const FliperamadaApp(),
  ));
}

class FliperamadaApp extends StatelessWidget {
  const FliperamadaApp({super.key});
  @override
  Widget build(BuildContext context) => Consumer<ThemeController>(
      builder: (context, theme, _) => MaterialApp(
            title: 'Fliperamada TI',
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [Locale('pt', 'BR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: ArcadeTheme.light,
            darkTheme: ArcadeTheme.dark,
            themeMode: theme.mode,
            home: const AppRoot(),
          ));
}
