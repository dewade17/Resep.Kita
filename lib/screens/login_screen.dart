import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/cubit/auth/auth_cubit.dart';
import 'package:my_projek/dto/login.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'dart:convert';
import 'package:my_projek/screens/register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/screens/update_password.dart';
import 'package:my_projek/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscureUser = true; // Keadaan awal teks sandi tersembunyi
  void _toggleObscureUser() {
    setState(() {
      _isObscureUser = !_isObscureUser;
    });
  }

  bool _isObscurePassword = true;
  void _toggleObscureUserPassword() {
    setState(() {
      _isObscurePassword = !_isObscurePassword;
    });
  }

  //Service
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> sendLogin(BuildContext context, AuthCubit authCubit) async {
    if (!_formKey.currentState!.validate()) {
      // If the form is invalid, display a message and return
      return;
    }

    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await sendLoginData(username, password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loggedIn = Login.fromJson(data);

        // Save access token
        await SecureStorageUtil.storage
            .write(key: tokenStoreName, value: loggedIn.accessToken);

        // Extract user ID
        final idUser = loggedIn.idUser.toString();

        // Save user ID to secure storage
        await SecureStorageUtil.storage
            .write(key: userIdStoreName, value: idUser);

        authCubit.login(loggedIn.accessToken);

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selamat Datang'),
              content:
                  const Text('Temukan resep makanan sebanyak-banyaknya!!!.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, "/home-screen");
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        debugPrint("Login successful");
        debugPrint(loggedIn.accessToken);
        debugPrint(idUser); // Debug print user ID
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content:
                  const Text('Invalid username or password. Please try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        debugPrint("Login failed with status code: ${response.statusCode}");
      }
    } catch (error) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'An error occurred while processing the login request.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      debugPrint("Error occurred during login: $error");
    }
  }

  static Future<http.Response> sendLoginData(
      String username, String password) async {
    final url = Uri.parse(ResepKita.login); // Replace with your endpoint
    final data = {'username': username, 'password': password};

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: null,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Welcome!",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 3.0,
                    color: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Sign in to Continue ",
                  style: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: _usernameController,
                        obscureText: _isObscureUser,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87)),
                          prefixIcon: const Icon(
                            Icons.person,
                            size: 25,
                          ),
                          suffixIcon: InkWell(
                            onTap: _toggleObscureUser,
                            child: Icon(
                              _isObscureUser
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black87,
                            ),
                          ),
                          hintText: "Masukkan Username",
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(221, 0, 0, 0)),
                          labelText: "Username",
                          labelStyle: const TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscurePassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(221, 73, 11, 11))),
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 25,
                          ),
                          suffixIcon: InkWell(
                            onTap: _toggleObscureUserPassword,
                            child: Icon(
                              _isObscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black87,
                            ),
                          ),
                          hintText: "Masukkan Password",
                          hintStyle: const TextStyle(color: Colors.black87),
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 250,
                      child: Card(
                        elevation: 5,
                        color: Colors.blue,
                        child: InkWell(
                          splashColor: Colors.white,
                          onTap: () {
                            sendLogin(context, authCubit);
                          },
                          child: const Center(
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Tambahkan navigasi ke halaman pendaftaran di sini
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UpdatePassword()));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 2,
                            indent: 50,
                            endIndent:
                                10, // Anda bisa menyesuaikan nilai indent dan endIndent sesuai kebutuhan
                          ),
                        ),
                        Text("Or"),
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 2,
                            indent: 10,
                            endIndent:
                                50, // Anda bisa menyesuaikan nilai indent dan endIndent sesuai kebutuhan
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text("Social Media Login"),
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.google, size: 35),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(FontAwesomeIcons.facebook, size: 35),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(FontAwesomeIcons.twitter, size: 35)
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.poppins(),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Tambahkan navigasi ke halaman pendaftaran di sini
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                      child: Text(
                        " Sign Up",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
