import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Pages/MainPage/HomePage/camerapage.dart';
import 'package:nutrivision/Pages/MainPage/HomePage/home_page.dart';
import 'package:nutrivision/Pages/Login/sign_in.dart';
import 'package:nutrivision/Pages/Login/sign_up.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrivision/Pages/MainPage/mainpage.dart';
import 'package:nutrivision/Pages/onboarding_screens/onbording.dart';
import 'package:nutrivision/Pages/user_info_page/userinfo.dart';
import 'package:nutrivision/Pages/MainPage/userprofile/user_profile.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {


  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 145, 199, 137),
        textTheme: GoogleFonts.baloo2TextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 145, 199, 137),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        "/loginpage": (_) => const LoginPage(),
        "/signuppage": (_) => const SignupPage(),
        "/onboarding": (_) => const OnboardingScreen(),
        "/userform": (_) => const UserInfoForm(),
        "/homepage": (_) => const HomePage(),
        "/userprofile": (_) => const UserProfilePage(),
        "/camerapage": (_) => const CameraPage(),
        "/mainpage": (_) => const MainPage(),
      },
    );
  }
}
