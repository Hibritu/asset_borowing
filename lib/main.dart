import 'package:asset/providers/rental_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asset/providers/auth_provider.dart';
import 'package:asset/screens/auth/login_screen.dart';
//import 'package:asset/home.dart'; // HomeScreen
//import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload SharedPreferences data
  final authProvider = AuthProvider();
  await authProvider.loadAuthData();

  runApp(
    MultiProvider(
      providers: [
        
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
           ChangeNotifierProvider(create: (_) => RentalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeMode = authProvider.themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material Rental System',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      home: const LoginScreen(),
     
    );
  }
}
