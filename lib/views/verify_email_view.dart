import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "We have sent a verification email. Please open it to verify your account.",
            ),
            Text(
              "If you haven't received a verification email yet, press the button below",
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(AuthEventSendEmailVerification());
              },
              child: Text('Send email verification'),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(AuthEventLogOut());
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
