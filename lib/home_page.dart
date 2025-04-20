import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  // These parameters are for theme/color changes, handled by the main MaterialApp usually
  final String themeName;
  final int appBarColorIndex;
  final Function(String) changeTheme;
  final Function(int) changeAppBarColor;

  HomePage({
    Key? key,
    required this.themeName,
    required this.appBarColorIndex,
    required this.changeTheme,
    required this.changeAppBarColor,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _allGrades = [];

  @override
  void initState() {
    super.initState();
    _loadRecentGrades();

  }

  // Method to reload grades, perhaps after returning from a test
  Future<void> _loadRecentGrades() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Retrieve all grades
      List<String> grades = prefs.getStringList('testGrades') ?? [];

      grades.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.split(':')[2]);
          final dateB = DateTime.parse(b.split(':')[2]);
          return dateB.compareTo(dateA);
        } catch (e) {
          print("Error parsing date for sorting: $e");
          return 0;
        }
      });

      setState(() {
        _allGrades = grades;
      });
    } catch (e) {
      print("Error loading grades: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load recent scores.")),
        );
      }
    }
  }

  Widget _buildGradeTile(String gradeString) {
    final parts = gradeString.split(':');
    String testIdText = 'Unknown Test';
    String scoreText = '-';
    String dateText = '';
    IconData scoreIcon = Icons.help_outline;
    Color iconColor = Colors.grey;

    try {
      if (parts.length >= 2) {
        testIdText = parts[0].replaceAllMapped(
            RegExp(r'test(\d+)'), (match) => 'Test ${match.group(1)}');
        // Format score
        int score = int.parse(parts[1]);
        scoreText = '$score / 100';
        // Assign icon and color based on score
        if (score >= 90) {
          scoreIcon = Icons.emoji_events; // Gold medal for high score
          iconColor = Colors.amber;
        } else if (score >= 70) {
          scoreIcon = Icons.check_circle; // Green check for good score
          iconColor = Colors.green;
        } else if (score >= 50) {
          scoreIcon = Icons.warning_amber_outlined;
          iconColor = Colors.orange;
        }
        else {
          scoreIcon = Icons.cancel;
          iconColor = Colors.red;
        }
      }
      if (parts.length >= 3) {
        try {
          final date = DateTime.parse(parts[2]);
          dateText = DateFormat('MMM dd, BBBB').format(date);
        } catch (e) {
          print("Error formatting date '${parts[2]}': $e");
          dateText = 'Invalid Date';
        }
      }
    } catch (e) {
      print("Error parsing grade string '$gradeString': $e");
      testIdText = "Parsing Error";
      scoreIcon = Icons.error_outline;
      iconColor = Colors.red;
    }


    return ListTile(
      leading: Icon(scoreIcon, color: iconColor, size: 28),
      title: Text(
        testIdText,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: dateText.isNotEmpty ? Text(dateText) : null,
      trailing: Text(
        scoreText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      dense: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings').then((_) {

              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recent Test Scores',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_allGrades.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No test scores found yet.\nTake a test to see your progress!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      LimitedBox(
                        maxHeight: 250,
                        child: SingleChildScrollView(
                          child: Column(
                            children: _allGrades.map((grade) => _buildGradeTile(grade)).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Practice Button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Practice'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/practice');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text('Test'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/test').then((_) {
                          _loadRecentGrades(); // Reload ALL grades
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}