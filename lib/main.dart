import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/roulette_page.dart';
import 'theme/app_palette.dart';

void main() {
  runApp(const RouletteApp());
}

class RouletteApp extends StatelessWidget {
  const RouletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weighted Roulette',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppPalette.background,
        colorScheme: const ColorScheme.dark(
          surface: AppPalette.surface,
          primary: AppPalette.cyan,
          secondary: AppPalette.blue,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const RoulettePage(),
    );
  }
}
