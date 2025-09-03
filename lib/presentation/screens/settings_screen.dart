import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings/general_settings.dart';
import '../widgets/settings/appearance_settings.dart';
import '../widgets/settings/data_settings.dart';
import '../widgets/settings/about_settings.dart';

/// Main settings screen with categorized settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            context: context,
            title: 'General',
            icon: Icons.settings,
            onTap: () => _navigateToSettings(context, const GeneralSettings()),
          ),
          _buildSettingsSection(
            context: context,
            title: 'Appearance',
            icon: Icons.palette,
            onTap: () => _navigateToSettings(context, const AppearanceSettings()),
          ),
          _buildSettingsSection(
            context: context,
            title: 'Data & Storage',
            icon: Icons.storage,
            onTap: () => _navigateToSettings(context, const DataSettings()),
          ),
          _buildSettingsSection(
            context: context,
            title: 'About',
            icon: Icons.info,
            onTap: () => _navigateToSettings(context, const AboutSettings()),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _navigateToSettings(BuildContext context, Widget settingsWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => settingsWidget,
      ),
    );
  }
}
