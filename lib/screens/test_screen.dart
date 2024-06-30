import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_projek/components/asset_image_widget.dart';
import 'package:my_projek/screens/input_ip.dart';
import 'package:my_projek/screens/login_screen.dart';
import 'package:my_projek/screens/register_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: AssetImageWidget(
              imagePath: "assets/image/Logo.png",
              width: 250,
              height: 250,
            ),
          ),
          Text(
            'Hello !',
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontSize: 30,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              "Tempat terbaik untuk mencari resep makanan sesuai keinginan Anda.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontStyle: FontStyle.normal,
              ),
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
                  // Tambahkan navigasi ke halaman pendaftaran di sini
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Center(
                  child: Text(
                    "LOGIN",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 50,
            width: 250,
            child: Card(
              elevation: 5,
              color: Colors.white,
              child: InkWell(
                splashColor: Colors.blue,
                onTap: () {
                  // Tambahkan navigasi ke halaman pendaftaran di sini
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                },
                child: Center(
                  child: Text(
                    "REGISTER",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to InputIp page when the FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputIp()),
          );
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
