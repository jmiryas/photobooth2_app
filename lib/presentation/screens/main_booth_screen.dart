// lib/presentation/screens/main_booth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/booth_state.dart';
import '../providers/booth_provider.dart';
import 'booth_screens.dart';

class MainBoothScreen extends StatelessWidget {
  const MainBoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentState = context.watch<BoothProvider>().currentState;

    Widget screenToShow;

    switch (currentState) {
      case BoothState.idle:
        screenToShow = const IdleScreen();
        break;
      case BoothState.selectTemplate:
        screenToShow = const SelectTemplateScreen();
        break;
      case BoothState.capture:
        screenToShow = const CaptureScreen();
        break;
      case BoothState.preview:
        screenToShow = const PreviewScreen();
        break;
      case BoothState.payment:
        screenToShow = const PaymentScreen();
        break;
      case BoothState.done:
        screenToShow = const DoneScreen();
        break;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey(currentState), child: screenToShow),
      ),
    );
  }
}
