import 'package:facilitatorpro/authentication/otpverify.dart';
import 'package:facilitatorpro/authentication/signin.dart';
import 'package:facilitatorpro/authentication/signup.dart';
import 'package:facilitatorpro/profile/profile.dart';
import 'package:facilitatorpro/routes/routenames.dart';

import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case signUpRoute:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
        );
      case signInRoute:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
        );
      case otpVerificationRoute:
        return MaterialPageRoute(
          builder: (_) => const OTPVerificationPage(),
        );
      case profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );

      // case '/list':
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => ListPage(
      //         listNumber: args,
      //       ),
      //     );
      //   }
      //   return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error Loading Page'),
        ),
        body: Center(
          child: Container(
            color: Colors.white,
            child: const Text('Error Loading Page'),
          ),
        ),
      );
    });
  }
}
