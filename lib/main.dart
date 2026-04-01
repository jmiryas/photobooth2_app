// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'presentation/providers/booth_provider.dart';
import 'presentation/providers/print_provider.dart';
import 'presentation/screens/main_booth_screen.dart';
import 'services/print_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhotoboothApp());
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoothProvider()),
        ChangeNotifierProvider(
          create: (_) => PrintProvider(PrintService()).initialize(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bgStart,
        ),
        home: const MainBoothScreen(),
      ),
    );
  }
}
