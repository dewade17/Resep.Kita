import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  Future<void> registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(ResepKita.register);
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': emailController.text,
          'username': usernameController.text,
          'password': passwordController.text,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        // Registration successful
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registrasi Akun Berhasil, Silahkan Login')),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, "/intro-screen");
      } else if (response.statusCode == 422) {
        // Validation failed
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Validation failed: ${jsonDecode(response.body)['errors']}')),
        );
      } else {
        // Registration failed
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Registrasi Gagal: ${jsonDecode(response.body)['error']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Hi!",
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
                "Create a new account",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(
              height: 110,
            ),
            Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: usernameController,
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
                      height: 10,
                    ),
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(221, 73, 11, 11))),
                          prefixIcon: Icon(
                            Icons.contact_emergency_outlined,
                            size: 25,
                          ),
                          hintText: "Masukkan Email Anda",
                          hintStyle: TextStyle(color: Colors.black87),
                          labelText: "email",
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Add a regex for email validation if needed
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: passwordController,
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
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
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
                          onTap: () => registerUser(context),
                          child: const Center(
                            child: Text(
                              'SIGN UP',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
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
                    const Text("Social Media Sign Up"),
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
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Tambahkan navigasi ke halaman pendaftaran di sini
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/intro-screen');
                    },
                    child: Text(
                      " Sign in",
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
    );
  }
}
