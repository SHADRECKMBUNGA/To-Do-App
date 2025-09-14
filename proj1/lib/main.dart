import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'pages/homePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xaozqclsmjnacmzbecmf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhhb3pxY2xzbWpuYWNtemJlY21mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4MzE3MTMsImV4cCI6MjA3MzQwNzcxM30.4IA8YfX-vpPH4BBwUzysC1c37J5hAO3WpfwosktbrEU', // 👈 replace with your Supabase anon key
  );

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
      ),
      home: const TodoHomePage(),
    );
  }
}
