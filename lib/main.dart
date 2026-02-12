// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definisikan warna utama agar bisa dipakai berulang
    const Color myCustomBlue = Color(0xFF55829E);

    return MaterialApp(
      title: 'TookShot',
      theme: ThemeData(
        useMaterial3: true, // Mengaktifkan Material 3
        
        // Menentukan skema warna berdasarkan warna biru pilihanmu
        colorScheme: ColorScheme.fromSeed(
          seedColor: myCustomBlue,
          primary: myCustomBlue,
        ),

        // Mengatur tema AppBar agar seragam
        appBarTheme: const AppBarTheme(
          backgroundColor: myCustomBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // Mengatur warna indikator loading secara global
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: myCustomBlue,
        ),

        // Mengatur gaya tombol agar tidak kembali ke ungu
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: myCustomBlue,
            foregroundColor: Colors.white,
          ),
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}