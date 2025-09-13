import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/clothing_item_repository.dart';
import '../../domain/repositories/outfit_repository.dart';
import 'logger_service.dart';

/// Service responsible for ensuring data persistence
/// Handles app lifecycle events and ensures data is saved
class DataPersistenceService {
  final ClothingItemRepository _clothingItemRepository;
  final OutfitRepository _outfitRepository;

  DataPersistenceService(this._clothingItemRepository, this._outfitRepository);

  /// Initializes the service
  Future<void> initialize() async {
    // Set up lifecycle listeners for data persistence
    setupLifecycleListeners();
    LoggerService.info('Data persistence service initialized successfully');
  }

  /// Sets up app lifecycle listeners to ensure data persistence
  void setupLifecycleListeners() {
    // Listen for app lifecycle changes
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.paused.toString()) {
        await _ensureDataPersistence();
      } else if (msg == AppLifecycleState.detached.toString()) {
        await _ensureDataPersistence();
      }
      return null;
    });
  }

  /// Ensures all data is persisted to disk
  Future<void> _ensureDataPersistence() async {
    try {
      // Use public flush methods from repositories
      await _clothingItemRepository.flush();
      await _outfitRepository.flush();
      LoggerService.info('Data persistence ensured successfully');
    } catch (e) {
      LoggerService.error('Failed to ensure data persistence: $e');
    }
  }

  /// Manually trigger data persistence (useful for testing)
  Future<void> forcePersist() async {
    await _ensureDataPersistence();
  }

  /// Cleanup method to be called when the service is disposed
  void dispose() {
    // Cleanup any listeners if needed
  }
}
