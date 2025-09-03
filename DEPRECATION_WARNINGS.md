# Deprecation Warnings Documentation

This document describes the deprecation warnings that are currently being ignored in the codebase and the reasoning behind these decisions.

## Radio Widget Deprecation Warnings

### Issue
Flutter has deprecated the `groupValue` and `onChanged` parameters on `Radio` widgets in favor of using `RadioGroup` ancestor widgets. This deprecation was introduced after Flutter v3.32.0-0.0.pre.

### Affected Files
- `lib/presentation/widgets/settings/appearance_settings.dart` ✅ **RESOLVED**
- `lib/presentation/widgets/settings/general_settings.dart` ✅ **RESOLVED**

### Migration Completed
We have successfully migrated from the deprecated `Radio` widget pattern to the new `RadioGroup` pattern as documented in the [Flutter Radio documentation](https://api.flutter.dev/flutter/material/Radio-class.html).

### New Implementation
We now use `RadioGroup` with individual `Radio` widgets as children:

```dart
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) {
    setState(() {
      selectedValue = value!;
    });
    // Handle selection logic
  },
  child: Column(
    children: [
      ListTile(
        title: const Text('Option 1'),
        leading: Radio<String>(value: 'option1'),
      ),
      ListTile(
        title: const Text('Option 2'),
        leading: Radio<String>(value: 'option2'),
      ),
    ],
  ),
)
```

### Benefits of Migration
1. **Future-proof**: Uses the current Flutter API without deprecation warnings
2. **Cleaner code**: Removes the need for `// ignore:` comments
3. **Better maintainability**: Follows Flutter's recommended patterns
4. **Same functionality**: Maintains identical user experience

## Other Resolved Warnings

### Print Statements
- **Fixed**: Replaced `print()` calls with `debugPrint()` in `lib/core/services/image_processor.dart`
- **Reason**: `debugPrint()` is the recommended way to log debug information in Flutter

### withOpacity() Deprecation
- **Fixed**: Replaced `withOpacity()` calls with `withValues(alpha:)` in `lib/presentation/widgets/outfit_calendar_view.dart`
- **Reason**: `withOpacity()` is deprecated in favor of `withValues()` to avoid precision loss

## Maintenance Notes

- This file should be updated whenever new deprecation warnings are encountered
- Review ignored warnings periodically to see if migration is now feasible
- Consider creating GitHub issues to track migration tasks
- Test any migration thoroughly before removing ignore comments

## Last Updated
Created: $(date)
Last Reviewed: $(date)
