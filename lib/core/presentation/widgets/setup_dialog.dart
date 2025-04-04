import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragon_center_linux/core/presentation/viewmodels/setup_viewmodel.dart';

class SetupDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const SetupDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: const Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: content,
    );
  }
}

class SetupLogo extends StatelessWidget {
  const SetupLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/dragon.png',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.computer,
        size: 80,
        color: Color(0xFFD32F2F),
      ),
    );
  }
}

class SetupButton extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final VoidCallback onPressed;
  final bool isLoading;

  const SetupButton({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}

class InitialSetupDialog extends StatelessWidget {
  const InitialSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupViewModel>(
      builder: (context, viewModel, child) {
        return SetupDialog(
          title: 'Initial Setup',
          icon: Icons.settings,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SetupLogo(),
              const SizedBox(height: 20),
              const Text('Welcome to Dragon Centre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              const Text(
                  'Would you like to use the universal auto fan profile?',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SetupButton(
                    text: 'No',
                    color: const Color(0xFF2A2A2A),
                    textColor: Colors.white,
                    onPressed: () => _handleProfileSelection(context, true),
                    isLoading: viewModel.state == SetupState.loading,
                  ),
                  SetupButton(
                    text: 'Yes',
                    onPressed: () => _handleProfileSelection(context, false),
                    isLoading: viewModel.state == SetupState.loading,
                  ),
                ],
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleProfileSelection(
      BuildContext context, bool universal) async {
    final viewModel = context.read<SetupViewModel>();
    Navigator.pop(context);
    await viewModel.handleProfileSelection(universal);
    if (context.mounted && viewModel.state == SetupState.ready) {
      await showDialog(
        context: context,
        builder: (context) => const CpuGenerationDialog(),
      );
    }
  }
}

class CpuGenerationDialog extends StatelessWidget {
  const CpuGenerationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupViewModel>(
      builder: (context, viewModel, child) {
        return SetupDialog(
          title: 'CPU Generation',
          icon: Icons.memory,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Is your CPU Intel 10th Gen or newer?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SetupButton(
                    text: 'No',
                    color: const Color(0xFF2A2A2A),
                    textColor: Colors.white,
                    onPressed: () => _handleCpuGeneration(context, false),
                    isLoading: viewModel.state == SetupState.loading,
                  ),
                  SetupButton(
                    text: 'Yes',
                    onPressed: () => _handleCpuGeneration(context, true),
                    isLoading: viewModel.state == SetupState.loading,
                  ),
                ],
              ),
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCpuGeneration(BuildContext context, bool isNewGen) async {
    final viewModel = context.read<SetupViewModel>();
    Navigator.pop(context);
    await viewModel.handleCpuGeneration(isNewGen);
    if (context.mounted && viewModel.state == SetupState.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setup complete! Ready to optimize your system.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
