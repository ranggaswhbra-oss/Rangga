import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/main_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Game bola dimainkan landscape, seperti eFootball / PES
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full screen, sembunyikan status bar & nav bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const GaaftbllApp());
}

class GaaftbllApp extends StatelessWidget {
  const GaaftbllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAAFTBLL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1FA24A),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const MainMenu(),
    );
  }
}
