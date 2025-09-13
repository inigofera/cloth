import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Appearance settings category
class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingsGroup(
            context: context,
            title: 'Theme',
            children: [
              _buildListTile(
                context: context,
                title: 'Theme mode',
                subtitle: 'System default',
                onTap: () {
                  _showThemeModeDialog(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Accent color',
                subtitle: 'Deep Purple',
                onTap: () {
                  _showAccentColorDialog(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Display',
            children: [
              _buildSwitchTile(
                context: context,
                title: 'Compact view',
                subtitle: 'Show more items in less space',
                value: false, // TODO: Connect to actual settings
                onChanged: (value) {
                  // TODO: Implement settings update
                },
              ),
              _buildListTile(
                context: context,
                title: 'Grid size',
                subtitle: 'Medium',
                onTap: () {
                  _showGridSizeDialog(context);
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

  void _showThemeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: StatefulBuilder(
          builder: (context, setState) {
            String selectedValue = 'system'; // TODO: Connect to actual settings
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
                    title: const Text('System default'),
                    leading: Radio<String>(value: 'system'),
                  ),
                  ListTile(
                    title: const Text('Light'),
                    leading: Radio<String>(value: 'light'),
                  ),
                  ListTile(
                    title: const Text('Dark'),
                    leading: Radio<String>(value: 'dark'),
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

  void _showAccentColorDialog(BuildContext context) {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accent Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  // TODO: Implement color change
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
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

  void _showGridSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grid Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            String selectedValue = 'medium'; // TODO: Connect to actual settings
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
                    title: const Text('Small'),
                    leading: Radio<String>(value: 'small'),
                  ),
                  ListTile(
                    title: const Text('Medium'),
                    leading: Radio<String>(value: 'medium'),
                  ),
                  ListTile(
                    title: const Text('Large'),
                    leading: Radio<String>(value: 'large'),
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
