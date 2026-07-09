import 'package:app_machin/layout/MainLayout.dart';
import 'package:app_machin/pages/LoginPage.dart';
import 'package:app_machin/providers/AnalysisProvider.dart';
import 'package:app_machin/providers/ImageProvider.dart';
import 'package:app_machin/providers/RouteProvider.dart';
import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/providers/SettingsProvider.dart';
import 'package:app_machin/providers/ChatProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageSearchProvider()),
        ChangeNotifierProvider(create: (_) => Routeprovider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return Mainlayout();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
