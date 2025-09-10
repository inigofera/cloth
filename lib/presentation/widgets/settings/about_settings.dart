import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

/// About settings category
class AboutSettings extends ConsumerStatefulWidget {
  const AboutSettings({super.key});

  @override
  ConsumerState<AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends ConsumerState<AboutSettings> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildAppInfo(context),
          _buildSettingsGroup(
            context: context,
            title: 'Support',
            children: [
              _buildListTile(
                context: context,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () {
                  _showHelp(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Contact Support',
                subtitle: 'Report issues or get assistance',
                onTap: () {
                  _contactSupport(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Follow Development',
                subtitle: 'View source code and contribute',
                onTap: () {
                  _followDevelopment(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Rate the App',
                subtitle: 'Share your feedback',
                onTap: () {
                  _rateApp(context);
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            context: context,
            title: 'Legal',
            children: [
              _buildListTile(
                context: context,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  _showPrivacyPolicy(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Terms of Service',
                subtitle: 'Terms and conditions',
                onTap: () {
                  _showTermsOfService(context);
                },
              ),
              _buildListTile(
                context: context,
                title: 'Open Source Licenses',
                subtitle: 'Third-party libraries',
                onTap: () {
                  _showLicenses(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'cloth',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _packageInfo?.version ?? 'Version ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Track your clothing items, create outfits, and discover your style patterns.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
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

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Q: How do I add a new clothing item?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'A: Tap the + button on the Clothing tab and fill in the details.',
              ),
              SizedBox(height: 12),
              Text(
                'Q: How do I create an outfit?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'A: Go to the Outfits tab and tap the + button to create a new outfit.',
              ),
              SizedBox(height: 12),
              Text(
                'Q: Can I export my data?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('A: Yes, go to Settings > Data & Storage > Export data.'),
            ],
          ),
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

  Future<void> _contactSupport(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/inigofera/cloth/issues');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open GitHub issues page')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening GitHub issues: $e')),
        );
      }
    }
  }

  Future<void> _followDevelopment(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/inigofera/cloth');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open GitHub repository page'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening GitHub repository: $e')),
        );
      }
    }
  }

  void _rateApp(BuildContext context) {
    // TODO: Implement app rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App rating feature coming soon')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app stores all your data locally on your device. We do not collect, store, or transmit any personal information to external servers.\n\n'
            'The app may use analytics to improve the user experience, but this can be disabled in the Data & Storage settings.\n\n'
            'For the complete privacy policy, please visit our GitHub repository.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final Uri url = Uri.parse(
                'https://github.com/inigofera/cloth/blob/main/PRIVACY_POLICY.md',
              );
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open privacy policy page'),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error opening privacy policy: $e')),
                  );
                }
              }
            },
            child: const Text('View Full Policy'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to the following terms:\n\n'
            '1. The app is provided "as is" without warranties.\n'
            '2. You are responsible for backing up your data.\n'
            '3. We reserve the right to update these terms.\n\n'
            'For the complete terms of service, please contact support.',
          ),
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

  void _showLicenses(BuildContext context) {
    showLicensePage(context: context);
  }
}
