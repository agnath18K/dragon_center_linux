import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dragon_center_linux/features/fan_control/presentation/viewmodels/fan_control_viewmodel.dart';
import 'package:dragon_center_linux/features/fan_control/presentation/pages/dragon_control_page.dart';
import 'package:dragon_center_linux/core/presentation/viewmodels/setup_viewmodel.dart';
import 'package:dragon_center_linux/core/presentation/widgets/setup_dialog.dart';
import 'package:dragon_center_linux/core/presentation/widgets/model_selection_dialog.dart';

class SetupWrapper extends StatefulWidget {
  const SetupWrapper({super.key});

  @override
  State<SetupWrapper> createState() => _SetupWrapperState();
}

class _SetupWrapperState extends State<SetupWrapper>
    with SingleTickerProviderStateMixin {
  late DragonControlProvider _provider;
  late SetupViewModel _setupViewModel;
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _provider = DragonControlProvider();
    _setupViewModel = SetupViewModel();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeSetup();
  }

  Future<void> _initializeSetup() async {
    await _setupViewModel.initialize();
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getBool('firstRun') ?? true) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const InitialSetupDialog(),
          );
          if (mounted && (prefs.getString('selected_model') == null)) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const ModelSelectionDialog(),
            );
          }
        }
      } else {
        if (mounted && (prefs.getString('selected_model') == null)) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const ModelSelectionDialog(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    _setupViewModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 3)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !_setupViewModel.isInitialized) {
          return Scaffold(
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _logoAnimation,
                        child: Hero(
                          tag: 'dragon-logo',
                          child: Image.asset(
                            'assets/images/dragon.png',
                            width: 150,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.computer,
                              size: 150,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'MSI Dragon Centre',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Initializing...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 250,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD32F2F),
                                          Color(0xFFFF5722),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                child: Text(
                                  'Loading',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(
                        'assets/images/05.png',
                        width: 120,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return ChangeNotifierProvider<DragonControlProvider>.value(
          value: _provider,
          child: const DragonControlPage(),
        );
      },
    );
  }
}
