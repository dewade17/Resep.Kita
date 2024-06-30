part of 'auth_cubit.dart';

@immutable
class AuthState {
  final bool isLoggedIn;
  final String? accesToken;
  const AuthState({required this.isLoggedIn, this.accesToken});
}

final class AuthInitialstate extends AuthState {
  const AuthInitialstate() : super(isLoggedIn: true, accesToken: "");
}
