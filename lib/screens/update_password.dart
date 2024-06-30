import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
//start for email
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  bool _isLoading = false;

//end for email

  TextEditingController usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _tokenController = TextEditingController();

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

  Future<void> _updatePassword() async {
    if (_formKey2.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final username = usernameController.text;
      final response = await http.post(
        Uri.parse('${ResepKita.newPassword}/$username'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'new_password': _newPasswordController.text,
          'token': _tokenController.text,
        }),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar(); // Menghilangkan Snackbar sebelumnya jika ada

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil Update Password'),
            duration: Duration(seconds: 2),
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, "/intro-screen");
      } else {
        final responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Gagal Update Password'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
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
                "Silahkan Update Password Anda !",
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
                key: _formKey1,
                child: Column(
                  children: [
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                          ),
                          prefixIcon: Icon(Icons.person, size: 25),
                          hintText: "Masukkan Email",
                          hintStyle:
                              TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendVerificationCode();
                      },
                      child: const Text('Send Verification Code'),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Form(
                key: _formKey2,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                            labelStyle: const TextStyle(color: Colors.black87)),
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
                        controller: _newPasswordController,
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
                            labelStyle: const TextStyle(color: Colors.black87)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
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
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87),
                          ),
                          prefixIcon: Icon(Icons.person, size: 25),
                          hintText: "Masukkan Kode",
                          hintStyle:
                              TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                          labelText: "Kode Verifikasi",
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the token';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      child: const Text('Update Password'),
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

  Future<void> _sendVerificationCode() async {
    if (_formKey1.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        // ignore: unnecessary_string_interpolations
        Uri.parse('${ResepKita.verificationCode}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text}),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Verifikasi Kode Sudah Terkirim Ke Gmail ${_emailController.text}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal Mengirim Verifikasi Kode'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
