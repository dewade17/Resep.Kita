// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_projek/endpoints/resep_kita.dart';

class NewProfile extends StatefulWidget {
  const NewProfile({
    super.key,
    required this.idUser,
  });

  final int idUser;

  @override
  // ignore: library_private_types_in_public_api
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHandphoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tanggalLahirController =
      TextEditingController(); // Tambah controller untuk tanggal lahir
  final picker = ImagePicker();

  File? galleryFile;
  DateTime? _selectedDate;

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _postData(int idUser) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Uri url = Uri.parse(('${ResepKita.profile}/$idUser'));

    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    request.fields['no_handphone'] = _noHandphoneController.text;
    request.fields['alamat'] = _alamatController.text;
    request.fields['tanggal_lahir'] = _tanggalLahirController.text;
    request.fields['nama'] = _namaController.text;

    if (galleryFile != null) {
      final http.MultipartFile imageFile = await http.MultipartFile.fromPath(
          'profile_picture', galleryFile!.path);
      request.files.add(imageFile);
    }

    try {
      final http.StreamedResponse response = await request.send();
      // ignore: unused_local_variable
      final String responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan')));
        Navigator.pop(context);
        Navigator.pushNamed(context, '/home-screen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan profil')));
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
      debugPrint('Error: $e');
    }
  }

  // ignore: unused_element
  bool _validateData() {
    if (_namaController.text.isEmpty ||
        _noHandphoneController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi semua data')));
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHandphoneController.dispose();
    _alamatController.dispose();
    _tanggalLahirController.dispose(); // Dispose controller tanggal lahir
    super.dispose();
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _selectedDate = selectedDate;
          _tanggalLahirController.text =
              DateFormat('yyyy-MM-dd').format(_selectedDate!); // Format tanggal
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text(
                    "Lengkapi Profil Anda !",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text(
                    "Hanya Anda yang dapat melihat data pribadi Anda.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: const Color.fromARGB(112, 0, 0, 0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: galleryFile != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(galleryFile!),
                        )
                      : const CircleAvatar(
                          radius: 50,
                          child: Icon(
                            Icons.person,
                            size: 80,
                          ),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () => _showPicker(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 115, 217, 235),
                      ), // Background color
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black87), // Text color
                    ),
                    child: const Text('Pilih Foto Profil Anda'),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
                      hintText: 'Masukkan Nama Anda',
                      hintStyle: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                      labelText: 'Nama',
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _noHandphoneController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
                      hintText: 'Masukkan No Handphone',
                      hintStyle: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                      labelText: 'Nomer Handphone',
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor Handphone tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
                      hintText: 'Masukkan Alamat Anda',
                      hintStyle: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                      labelText: 'Alamat',
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tanggalLahirController,
                        enabled:
                            false, // Jangan izinkan pengguna untuk mengedit tanggal secara manual
                        onTap: () => _showDatePicker(context),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87)),
                          hintText: 'Tanggal Lahir Anda',
                          hintStyle:
                              TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                          labelText: 'Tanggal Lahir',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Tanggal lahir tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: () => _showDatePicker(context),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 115, 217, 235),
                            ), // Background color
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black87), // Text color
                          ),
                          child: const Text('Pilih Tanggal Lahir'),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
               SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () => _postData(widget.idUser),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 115, 217, 235),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black87),
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
