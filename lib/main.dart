import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/workflow_provider.dart';
import 'screens/auth/auth_gate_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://antkusroysbehyliqvti.supabase.co',
    anonKey: 'sb_publishable_RZWNYqYb0-TL6vYSTBZozg_Qk465M4b',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => WorkflowProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkyLuxe AeroQuote',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE2BD79),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF3F6F8),
          useMaterial3: true,
          fontFamily: 'Roboto',
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF3F6F8),
            foregroundColor: Color(0xFF0E2238),
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: Builder(
          builder: (context) {
            return const AuthGateScreen();
          },
        ),
      ),
    );
  }
}
