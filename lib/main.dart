import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/logger_service.dart';
import 'data/models/clothing_item_model.dart';
import 'data/models/outfit_model.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ClothingItemModelAdapter());
  Hive.registerAdapter(OutfitModelAdapter());
  
  // Initialize dependency injection with error handling
  try {
    await DependencyInjection.setup();
    LoggerService.info('Dependency injection setup completed successfully');
  } catch (e) {
    LoggerService.warning('Dependency injection setup failed: $e');
    LoggerService.warning('App will continue but some features may not work');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
