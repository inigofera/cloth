# Data Persistence in Cloth App

## Overview

The Cloth app now has robust data persistence that ensures your clothing items and outfits are saved locally and persist between app sessions. This document explains how data persistence works and what improvements have been made.

## How It Works

### 1. Hive Database
- **Local Storage**: All data is stored locally on your device using Hive, a lightweight NoSQL database
- **Automatic Persistence**: Data is automatically saved to disk whenever you add, update, or delete items
- **No Internet Required**: Your data stays on your device and doesn't require an internet connection

### 2. Data Models
The app uses two main data models:

#### ClothingItem
- Basic information (name, category, color, brand, etc.)
- Metadata (purchase date, price, materials, etc.)
- Usage tracking (wear count, last worn, etc.)
- Soft deletion support (items are marked inactive rather than permanently deleted)

#### Outfit
- Date worn
- List of clothing item IDs
- Notes and metadata
- Soft deletion support

### 3. Repository Pattern
- **HiveClothingItemRepository**: Handles all clothing item operations
- **HiveOutfitRepository**: Handles all outfit operations
- **Automatic Flushing**: Data is automatically flushed to disk after each operation

### 4. Data Persistence Service
- **Lifecycle Management**: Automatically saves data when the app is paused or closed
- **Error Handling**: Gracefully handles any storage errors
- **Logging**: Provides detailed logging for debugging

## Key Improvements Made

### 1. Enhanced Error Handling
- All database operations now have proper error handling
- Failed operations are logged with detailed error messages
- The app continues to function even if some operations fail

### 2. Automatic Data Flushing
- Data is automatically flushed to disk after each operation
- Ensures data is saved immediately rather than waiting for system flush
- Prevents data loss during unexpected app closures

### 3. App Lifecycle Management
- Data is automatically saved when the app is paused or closed
- Prevents data loss when the app is terminated unexpectedly
- Ensures data persistence across app restarts

### 4. Robust Initialization
- Hive database is properly initialized before the app starts
- Repository initialization is handled gracefully with error reporting
- Fallback mechanisms ensure the app can still run even if storage fails

## Data Storage Location

### Android
- Data is stored in the app's private directory
- Location: `/data/data/[package_name]/app_flutter/`

### iOS
- Data is stored in the app's Documents directory
- Location: `~/Documents/`

### Windows/macOS/Linux
- Data is stored in the app's data directory
- Location varies by platform and installation method

## Testing Data Persistence

The app includes comprehensive tests to verify data persistence:

```bash
# Run all tests
flutter test

# Run only data persistence tests
flutter test test/data_persistence_test.dart
```

## Troubleshooting

### Data Not Persisting
1. Check that the app has proper permissions to write to storage
2. Verify that Hive initialization completed successfully
3. Check the console logs for any error messages

### Performance Issues
1. Large datasets may cause slower startup times
2. Consider implementing pagination for very large collections
3. Monitor memory usage with large numbers of items

### Data Corruption
1. Hive automatically handles most corruption scenarios
2. If corruption occurs, the app will attempt to recover
3. In extreme cases, data may need to be reset

## Future Enhancements

### 1. Cloud Sync
- Future versions will support cloud synchronization
- Data will be backed up to cloud storage
- Multi-device synchronization

### 2. Data Export/Import
- Export data to common formats (JSON, CSV)
- Import data from other clothing apps
- Backup and restore functionality

### 3. Advanced Queries
- Full-text search across all fields
- Complex filtering and sorting
- Statistical analysis and reporting

## Best Practices

### 1. Regular Backups
- While data is automatically persisted, consider regular backups
- Export data periodically for safekeeping
- Test data restoration procedures

### 2. Data Management
- Regularly review and clean up old data
- Use soft deletion features rather than hard deletion
- Monitor storage usage on your device

### 3. App Updates
- Data persistence is maintained across app updates
- Always backup data before major version updates
- Test data integrity after updates

## Technical Details

### Hive Configuration
- Type IDs: 0 for ClothingItem, 1 for Outfit
- Automatic schema evolution support
- Efficient binary storage format

### Repository Methods
- All CRUD operations are supported
- Batch operations for better performance
- Transaction support for complex operations

### Error Recovery
- Automatic retry mechanisms for failed operations
- Graceful degradation when storage is unavailable
- Comprehensive error logging and reporting

## Support

If you experience any issues with data persistence:

1. Check the console logs for error messages
2. Verify that the app has proper storage permissions
3. Try restarting the app
4. Contact support with detailed error information

Your data is important to us, and we're committed to ensuring it's always safe and accessible.
