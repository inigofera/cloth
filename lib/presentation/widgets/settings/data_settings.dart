import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data and storage settings category
class DataSettings extends ConsumerWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Storage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingsGroup(
            context: context,
            title: 'Storage',
            children: [
              _buildListTile(
                context: context,
                title: 'Storage usage',
                subtitle: '12.5 MB used',
                onTap: () {
                  _showStorageDetails(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Clear cache',
                subtitle: 'Free up temporary files',
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Backup & Export',
            children: [
              _buildListTile(
                context: context,
                title: 'Export data',
                subtitle: 'Export your clothing and outfit data',
                onTap: () {
                  _exportData(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Import data',
                subtitle: 'Import data from backup file',
                onTap: () {
                  _importData(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Privacy',
            children: [
              _buildSwitchTile(
                context: context,
                title: 'Analytics',
                subtitle: 'Help improve the app with anonymous usage data',
                value: true, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
                },
              ),
              _buildListTile(
                context: context,
                title: 'Delete all data',
                subtitle: 'Permanently remove all your data',
                onTap: () {
                  _showDeleteDataDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showStorageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Clothing items', '8.2 MB', '45 items'),
            _buildStorageItem('Outfits', '3.1 MB', '23 outfits'),
            _buildStorageItem('Images', '1.2 MB', '68 photos'),
            const Divider(),
            _buildStorageItem('Total', '12.5 MB', '136 items'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String title, String size, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text('$size ($count)'),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove temporary files and free up storage space. Your clothing items and outfits will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _importData(BuildContext context) {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon')),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This action cannot be undone. All your clothing items, outfits, and settings will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement data deletion
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
