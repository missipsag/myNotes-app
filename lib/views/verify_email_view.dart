import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email verification"),
        backgroundColor: const Color.fromARGB(255, 73, 152, 255),
      ),
      body: Column(
        children: [
          Text(
            "We have sent a verification email. Please open it to verify your account.",
          ),
          Text(
            "If you haven't received a verification email yet, press the button below",
          ),
          TextButton(
            onPressed: () async {
              final user = await AuthService.firebase().currentUser;
              if (user != null) {
                await AuthService.firebase().sendEmailVerification();
              }
            },
            child: Text('Send email verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (_) => false);
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
