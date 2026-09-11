import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/state.dart';
import 'data/api.dart';
import 'data/mock.dart';
import 'core/theme.dart';
import 'screens/birthday.dart';
import 'screens/home.dart';
import 'screens/glow.dart';
import 'screens/onboarding.dart';
import 'screens/profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(prefs)),
        ChangeNotifierProvider(create: (_) => ShellIndex()),
        ChangeNotifierProvider(create: (_) => DataRepo(prefs)..load()),
      ],
      child: const YoziApp(),
    ),
  );
}

class YoziApp extends StatelessWidget {
  const YoziApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MaterialApp(
      title: 'YAZI',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.15,
        child: child!,
      ),
      theme: Yozi.theme(app.isArabic),
      locale: Locale(app.lang),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Gate(),
    );
  }
}

/// Blocks the UI until live data is available (cache or network).
class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final repo = context.watch<DataRepo>();
    final hasData = kCats.isNotEmpty;
    if (!hasData) {
      if (repo.status == RepoStatus.error) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/logo.png', width: 84, height: 84),
                const SizedBox(height: 18),
                Text(app.isArabic ? 'تعذّر الاتصال بالخادم' : 'Could not reach the server',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(app.isArabic ? 'تأكدي من الإنترنت وحاولي مرة أخرى' : 'Check your internet and try again',
                    style: const TextStyle(color: Yozi.muted, fontSize: 13.5)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 220,
                  child: FilledButton(
                      onPressed: () => context.read<DataRepo>().load(),
                      child: Text(app.isArabic ? 'إعادة المحاولة' : 'Retry')),
                ),
              ]),
            ),
          ),
        );
      }
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('assets/logo.png', width: 96, height: 96),
            const SizedBox(height: 20),
            const SizedBox(
                width: 26, height: 26,
                child: CircularProgressIndicator(strokeWidth: 3, color: Yozi.violet)),
          ]),
        ),
      );
    }
    return app.onboarded ? const ShellScreen() : const OnboardingScreen();
  }
}

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final shell = context.watch<ShellIndex>();
    return PopScope(
      // Back on a non-home tab returns to Home instead of closing the app.
      canPop: shell.value == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && shell.value != 0) shell.set(0);
      },
      child: _shellScaffold(context, app, shell),
    );
  }

  Widget _shellScaffold(BuildContext context, AppState app, ShellIndex shell) {
    return Scaffold(
      body: IndexedStack(
        index: shell.value,
        children: const [
          HomeScreen(),
          GlowScreen(),
          BirthdayPlannerScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.value,
        onDestinationSelected: shell.set,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: app.t('home')),
          NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome_rounded),
              label: app.t('mamaSpace')),
          NavigationDestination(
              icon: const Icon(Icons.cake_outlined),
              selectedIcon: const Icon(Icons.cake_rounded),
              label: app.t('birthdayTab')),
          NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: app.t('profile')),
        ],
      ),
    );
  }
}
