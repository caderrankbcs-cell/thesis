import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StudentPredictorApp());
}

class StudentPredictorApp extends StatelessWidget {
  const StudentPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Academic Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
