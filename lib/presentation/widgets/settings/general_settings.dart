import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// General settings category
class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingsGroup(
            context: context,
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context: context,
                title: 'Daily outfit reminders',
                subtitle: 'Get reminded to log your daily outfit',
                value: true, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
                },
              ),
              _buildSwitchTile(
                context: context,
                title: 'Weekly insights',
                subtitle: 'Receive weekly clothing usage insights',
                value: false, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Behavior',
            children: [
              _buildListTile(
                context: context,
                title: 'Default view',
                subtitle: 'Clothing items',
                onTap: () {
                  _showDefaultViewDialog(context);
                },
              ),
              _buildSwitchTile(
                context: context,
                title: 'Auto-save drafts',
                subtitle: 'Automatically save outfit drafts',
                value: true, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
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

  void _showDefaultViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default View'),
        content: StatefulBuilder(
          builder: (context, setState) {
            String selectedValue = 'clothing'; // TODO: Connect to actual settings
            return RadioGroup<String>(
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value!;
                });
                // TODO: Implement settings update
                Navigator.of(context).pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Clothing items'),
                    leading: Radio<String>(value: 'clothing'),
                  ),
                  ListTile(
                    title: const Text('Outfits'),
                    leading: Radio<String>(value: 'outfits'),
                  ),
                  ListTile(
                    title: const Text('Insights'),
                    leading: Radio<String>(value: 'insights'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
