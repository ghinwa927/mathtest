// settings_page.dart
import 'package:flutter/material.dart';
import 'main.dart';

class SettingsPage extends StatelessWidget {
  final String themeName;
  final int appBarColorIndex;
  final Function(String) changeTheme;
  final Function(int) changeAppBarColor;

  SettingsPage({
    Key? key,
    required this.themeName,
    required this.appBarColorIndex,
    required this.changeTheme,
    required this.changeAppBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),

      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // --- Theme Selection Section ---
          Text(
            'Theme',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
              child: DropdownButtonFormField<String>(
                value: themeName,
                decoration: InputDecoration(
                  labelText: 'Select Theme', 
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero, 
                  isDense: true, 
                ),
                items: themes.keys
                    .map((themeKey) => DropdownMenuItem<String>(
                  value: themeKey,
                  child: Text(
                    themeKey,
                    style: textTheme.bodyMedium, 
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    changeTheme(value);
                  }
                },
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant), 
                dropdownColor: colorScheme.surfaceContainerLowest, 
              ),
            ),
          ),

          const SizedBox(height: 30), 
          Divider(color: colorScheme.outlineVariant), 

          const SizedBox(height: 30), 

          Text(
            'App Bar Color',
            style: textTheme.titleLarge?.copyWith( 
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card( 
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
              child: DropdownButtonFormField<int>(
                value: appBarColorIndex,
                decoration: InputDecoration(
                  labelText: 'Select App Bar Color', 
                  border: InputBorder.none, 
                  contentPadding: EdgeInsets.zero, 
                  isDense: true,
                ),
                items: appBarColors
                    .asMap()
                    .entries
                    .map((entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 24, 
                        height: 24,
                        margin: const EdgeInsets.only(right: 12), 
                        decoration: BoxDecoration( 
                          color: entry.value, 
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Color ${entry.key + 1}',
                        style: textTheme.bodyMedium, 
                      ),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    changeAppBarColor(value);
                  }
                },
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant), 
                dropdownColor: colorScheme.surfaceContainerLowest, 
              ),
            ),
          ),

        ],
      ),
    );
  }
}
