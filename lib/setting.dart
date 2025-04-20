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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Inner padding
              child: DropdownButtonFormField<String>(
                value: themeName,
                decoration: InputDecoration(
                  labelText: 'Select Theme', // Add a label
                  border: InputBorder.none, // Remove default border for cleaner look inside Card
                  contentPadding: EdgeInsets.zero, // Remove inner padding of input field
                  isDense: true, // Make the input field slightly more compact
                ),
                items: themes.keys
                    .map((themeKey) => DropdownMenuItem<String>( // Renamed variable to themeKey
                  value: themeKey,
                  child: Text(
                    themeKey,
                    style: textTheme.bodyMedium, // Use theme text style
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    changeTheme(value);
                  }
                },
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant), // Styled icon
                dropdownColor: colorScheme.surfaceContainerLowest, // Match dropdown background to theme
              ),
            ),
          ),

          const SizedBox(height: 30), // Space between sections
          Divider(color: colorScheme.outlineVariant), // Visual divider

          const SizedBox(height: 30), // Space after divider

          // --- App Bar Color Selection Section ---
          Text(
            'App Bar Color',
            style: textTheme.titleLarge?.copyWith( // Use titleLarge from theme
              fontWeight: FontWeight.bold,
              color: colorScheme.primary, // Use primary color for section titles
            ),
          ),
          const SizedBox(height: 12), // More vertical space
          Card( // Wrap dropdown in Card
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Inner padding
              child: DropdownButtonFormField<int>(
                value: appBarColorIndex,
                decoration: InputDecoration(
                  labelText: 'Select App Bar Color', // Add a label
                  border: InputBorder.none, // Remove default border
                  contentPadding: EdgeInsets.zero, // Remove inner padding
                  isDense: true, // Make the input field slightly more compact
                ),
                items: appBarColors
                    .asMap()
                    .entries
                    .map((entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 24, // Slightly larger color swatch
                        height: 24,
                        margin: const EdgeInsets.only(right: 12), // More space
                        decoration: BoxDecoration( // Add subtle border to swatch
                          color: entry.value, // <--- CORRECTED: Color is now inside BoxDecoration
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Color ${entry.key + 1}',
                        style: textTheme.bodyMedium, // Use theme text style
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
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant), // Styled icon
                dropdownColor: colorScheme.surfaceContainerLowest, // Match dropdown background
              ),
            ),
          ),

        ],
      ),
    );
  }
}