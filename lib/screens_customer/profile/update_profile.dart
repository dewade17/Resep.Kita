import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_projek/dto/profile.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    required this.profile,
    required this.idUser,
    super.key,
  });

  final Profile profile;
  final int idUser;

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _profilePictureController = TextEditingController();
  final _noHandphoneController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _namaController =
      TextEditingController(); // Controller for 'nama' field
  final _formKey = GlobalKey<FormState>();

  File? _galleryFile;
  final _picker = ImagePicker();
  final format = DateFormat("yyyy-MM-dd");

  @override
  void dispose() {
    _profilePictureController.dispose();
    _noHandphoneController.dispose();
    _alamatController.dispose();
    _tanggalLahirController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  _showPicker({required BuildContext context}) {
    // Image picker modal
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            // ignore: avoid_unnecessary_containers
            child: Container(
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource img) async {
    // Image picker function
    final pickedFile = await _picker.pickImage(source: img);
    setState(() {
      _galleryFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set initial values from Profile object
    _profilePictureController.text = widget.profile.profile_picture ?? '';
    _noHandphoneController.text = widget.profile.noHandphone ?? '';
    _alamatController.text = widget.profile.alamat ?? '';
    _tanggalLahirController.text = widget.profile.tanggalLahir != null
        ? DateFormat('yyyy-MM-dd').format(widget.profile.tanggalLahir!)
        : '';
    _namaController.text = widget.profile.nama ?? '';
    // Initialize nama field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan gambar profil dari URL
                GestureDetector(
                  onTap: () {
                    _showPicker(context: context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    width: double.infinity,
                    height: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Display the selected image if available
                        if (_galleryFile != null)
                          Image.file(
                            _galleryFile!,
                            width: 100,
                          ),
                        // Display the image from the network if available
                        if (_profilePictureController.text.isNotEmpty &&
                            _galleryFile == null)
                          Image.network(
                            Uri.parse(
                              '${ResepKita.baseUrl}/${_profilePictureController.text}',
                            ).toString(),
                            width: 100,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        // Display the placeholder text if no image is selected
                        if (_galleryFile == null &&
                            _profilePictureController.text.isEmpty)
                          Center(
                            child: Text(
                              'Pick your Image here',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 124, 122, 122),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller:
                        _namaController, // Add controller for 'nama' field
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
                    }, // Label for 'nama' field
                  ),
                ),
                const SizedBox(height: 20),
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
                        return 'Nomer Handphone tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // ignore: avoid_unnecessary_containers
                Container(
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
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: DateTimeField(
                    format: format,
                    controller: _tanggalLahirController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87),
                      ),
                      hintText: 'Tanggal Lahir Anda',
                      hintStyle: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                      labelText: 'Tanggal Lahir',
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      return date;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile(widget.idUser);
                      }
                    },
                    child: const Text('Update Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile(int idUser) async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST', // You can adjust the method as needed
      Uri.parse(
          '${ResepKita.profile}/$idUser/${widget.profile.idProfile}'), // Replace with your API endpoint
    );

    // Add fields to the request (including files if needed)
    request.fields['no_handphone'] = _noHandphoneController.text;
    request.fields['alamat'] = _alamatController.text;
    request.fields['tanggal_lahir'] = _tanggalLahirController.text;
    request.fields['nama'] = _namaController.text; // Add nama field to request

    // Add image file to the request if it's selected
    if (_galleryFile != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'profile_picture', // Name of the field that will be received on server
        _galleryFile!.path,
      );
      request.files.add(multipartFile);
    }

    // Send the request
    var response = await request.send();

    // Handle response (success or error)
    if (response.statusCode == 200) {
      // Profile updated successfully
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update Profil Berhasil'),
        ),
      );
      // Navigate back to previous screen
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/home-screen');
    } else {
      // Failed to update profile
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal Update Profile'),
        ),
      );
    }
  }
}
