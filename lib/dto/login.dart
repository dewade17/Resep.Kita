class Login {
  final int idUser;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  Login({
    required this.idUser,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        idUser: json["id_user"],
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
      );
}
