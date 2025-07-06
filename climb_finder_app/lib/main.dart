import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClimbFinderApp());
}

class ClimbFinderApp extends StatelessWidget {
  const ClimbFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ひとつの「種」となる色を定義します。
    // ここでは、標準的でモダンな印象の deepPurple を選びました。
    const seedColor = Colors.deepPurple;

    return MaterialApp(
      title: 'ClimbFinder',
      
      // テーマモード（ライト/ダーク/システム設定）
      // themeMode: ThemeMode.system, // デフォルトでシステム設定に従います

      // ライトモードのテーマ
      theme: ThemeData(
        // ★Material 3 を有効にするための重要な設定
        useMaterial3: true,
        // ★seedColor から調和の取れたカラーパレットを自動生成
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ダークモードのテーマ
      darkTheme: ThemeData(
        useMaterial3: true,
        // ★同じ seedColor からダークモード用のパレットを生成
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark, // ダークモードであることを指定
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      home: const HomeScreen(),
    );
  }
}