import 'package:collectors_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth_check.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen_wrapper.dart';
import 'screens/profile_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/new_chat_screen.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'providers/collection_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/collection_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CrashlyticsService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => CollectionRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              CollectionProvider(context.read<CollectionRepository>()),
        ),
      ],
      child: const CollectorsApp(),
    );
  }
}

class CollectorsApp extends StatelessWidget {
  const CollectorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Collectors App',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      navigatorObservers: [AnalyticsService.observer],
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreenWrapper(),
        '/profile': (context) => const ProfileScreen(),
        '/add-item': (context) => const AddItemScreen(),
        '/chats': (context) => ChatsScreen(),
        '/chat-detail': (context) => ChatDetailScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/new-chat': (context) => NewChatScreen(),
      },
    );
  }
}
