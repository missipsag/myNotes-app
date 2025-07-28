import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      //initialize
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    on<AuthEventLogIn>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        log("Before logging in");
        final user = await provider.login(email: email, password: password);
        log("After logging in");
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });

    // Logout
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        emit(AuthStateLogOutFailure(e));
      }
    });
  }
}
