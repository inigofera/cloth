import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/core/di/dependency_injection.dart';
import 'src/core/services/logger_service.dart';
import 'src/data/models/clothing_item_model.dart';
import 'src/data/models/outfit_model.dart';
import 'src/domain/repositories/clothing_item_repository.dart';
import 'src/presentation/screens/splash_screen.dart';

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

    // Run category normalization migration
    try {
      final repository = getIt<ClothingItemRepository>();
      await repository.normalizeCategories();
      LoggerService.info('Category normalization completed');
    } catch (e) {
      LoggerService.warning('Category normalization failed: $e');
    }
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
      home: const SplashScreen(),
    );
  }
}
