// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitialstate());
  void login(String accesToken) {
    emit(AuthState(isLoggedIn: true, accesToken: accesToken));
  }

  void logout() {
    emit(const AuthState(isLoggedIn: false, accesToken: ""));
  }
}
