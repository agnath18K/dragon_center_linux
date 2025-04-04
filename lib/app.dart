import 'package:dragon_center_linux/core/presentation/pages/setup_wrapper.dart';
import 'package:flutter/material.dart';

class DragonCentreApp extends StatelessWidget {
  const DragonCentreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSI - Dragon Centre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          brightness: Brightness.dark,
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFFF5252),
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFFD32F2F),
          inactiveTrackColor: Color(0xFF424242),
          thumbColor: Colors.white,
          overlayColor: Color(0x29D32F2F),
          trackHeight: 4,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor:
              WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.grey.shade400;
          }),
          trackColor:
              WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFD32F2F);
            }
            return Colors.grey.shade700;
          }),
        ),
      ),
      home: const SetupWrapper(),
    );
  }
}
