import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart';
import 'utils/colors.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const PhonePeApp(),
    ),
  );
}

class PhonePeApp extends StatelessWidget {
  const PhonePeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'PhonePe Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final widgetChild = child ?? const SizedBox.shrink();
        if (auth.isLoggedIn && auth.userId != null) {
          return ChangeNotifierProvider(
            create: (_) => UserProvider(auth.userId!),
            child: widgetChild,
          );
        }
        return widgetChild;
      },
      home: !auth.isInitialized
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : auth.isLoggedIn
              ? const MainScreen()
              : const LoginScreen(),
    );
  }
}
