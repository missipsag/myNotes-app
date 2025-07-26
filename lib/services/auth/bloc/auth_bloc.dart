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
        emit(AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    on<AuthEventLogIn>((event, emit) async {
      emit(AuthStateLoading());
      final email = event.email; 
      final password = event.password;
      try {
        final user = await provider.login(email: email, password: password);
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    // Logout
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.logout();
        emit(AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogOutFailure(e));
      }
    });
  }
}
