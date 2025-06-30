import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Units'),
            subtitle: Text(settings.units == Units.metric ? 'Metric (kg, cm)' : 'Imperial (lb, in)'),
            trailing: DropdownButton<Units>(
              value: settings.units,
              items: const [
                DropdownMenuItem(value: Units.metric, child: Text('Metric')),
                DropdownMenuItem(value: Units.imperial, child: Text('Imperial')),
              ],
              onChanged: (val) {
                if (val != null) settings.setUnits(val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: AppThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (val) {
                if (val != null) settings.setThemeMode(val);
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('App version, developer info'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Fait Fitness',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Fait Fitness',
              );
            },
          ),
        ],
      ),
    );
  }

  static String _themeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}
