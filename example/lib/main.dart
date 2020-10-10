import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => BackgroundLocation(),
      child: MaterialApp(
        title: 'Background Location',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LandingPage(),
      ),
    );
  }
}
