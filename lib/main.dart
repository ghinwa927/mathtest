import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'practice.dart'; 
import 'test.dart';     
import 'setting.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeName = prefs.getString('theme') ?? 'Light';
  final appBarColorIndex = prefs.getInt('appBarColorIndex') ?? 0;

  runApp(MyApp(
    themeName: themeName,
    appBarColorIndex: appBarColorIndex,
  ));
}

class MyApp extends StatefulWidget {
  final String themeName;
  final int appBarColorIndex;

  const MyApp({required this.themeName, required this.appBarColorIndex, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _themeName;
  late int _appBarColorIndex;

  @override
  void initState() {
    super.initState();
    _themeName = widget.themeName;
    _appBarColorIndex = widget.appBarColorIndex;
  }

  void _changeTheme(String themeName) async {
    setState(() {
      _themeName = themeName;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
  }

  void _changeAppBarColor(int appBarColorIndex) async {
    setState(() {
      _appBarColorIndex = appBarColorIndex;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('appBarColorIndex', appBarColorIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Practice',
      debugShowCheckedModeBanner: false,
      theme: themes[_themeName] != null
          ? ThemeData(
        scaffoldBackgroundColor: themes[_themeName]!['background'],
        appBarTheme: AppBarTheme(
          backgroundColor: appBarColors[_appBarColorIndex],
          foregroundColor: themes[_themeName]!['text'],
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: themes[_themeName]!['text']),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themes[_themeName]!['button'],
            foregroundColor: themes[_themeName]!['text'],
          ),
        ),
      )
          : ThemeData.light(),
      home: HomePage(
        themeName: _themeName,
        appBarColorIndex: _appBarColorIndex,
        changeTheme: _changeTheme,
        changeAppBarColor: _changeAppBarColor,
      ),
      routes: {
        '/practice': (context) => const PracticePage(),
        '/test': (context) => const TestPage(),
        '/settings': (context) => SettingsPage( // Removed const
          themeName: _themeName,
          appBarColorIndex: _appBarColorIndex,
          changeTheme: _changeTheme,
          changeAppBarColor: _changeAppBarColor,
        ),
      },
    );
  }
}

Map<String, Map<String, Color>> themes = {
  'Dark': {
    'background': Colors.grey[900]!,
    'button': Colors.grey[800]!,
    'text': Colors.white,
  },
  'Light': {
    'background': Colors.white,
    'button': Colors.grey[300]!,
    'text': Colors.black,
  },
};

List<Color> appBarColors = [
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.blueGrey,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.deepPurple,
  Colors.pinkAccent,

];
