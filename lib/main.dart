import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_colors.dart';
import 'features/notes/data/note_model.dart';
import 'features/notes/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  /// Initialize Hive
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());

  await Hive.openBox<Note>('notesBox');

  runApp(
    const ProviderScope(
      child: SmartNotesApp(),
    ),
  );
}

class SmartNotesApp extends StatelessWidget {
  const SmartNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Smart Notes',

      debugShowCheckedModeBanner: false,

      /// Global Theme
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryAction,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          navActionTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryAction,
          ),
        ),
      ),

      /// Smooth page animation
      builder: (context, child) {
        return CupertinoTheme(
          data: CupertinoTheme.of(context).copyWith(
            scaffoldBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },

      home: const HomeScreen(),
    );
  }
}
