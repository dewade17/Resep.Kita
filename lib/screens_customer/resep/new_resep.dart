// ignore: unused_import
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:my_projek/endpoints/resep_kita.dart';

class NewResep extends StatefulWidget {
  const NewResep({super.key, required this.idUser});
  final int idUser;

  @override
  // ignore: library_private_types_in_public_api
  _NewResepState createState() => _NewResepState();
}

class _NewResepState extends State<NewResep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers =
      List.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _stepControllers =
      List.generate(10, (_) => TextEditingController());
  final picker = ImagePicker();
  bool isValidationDone = false;

  File? galleryFile;
  String? _selectedCategory;

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
    if (!_validateData()) {
      return;
    }

    final Uri url = Uri.parse(
        '${ResepKita.resep}/$idUser/reseps'); // Replace with your actual API endpoint

    final request = http.MultipartRequest('POST', url)
      ..fields['title'] = _titleController.text
      ..fields['description'] = _descriptionController.text
      ..fields['kategori'] = _selectedCategory!;

    for (int i = 0; i < _ingredientControllers.length; i++) {
      if (_ingredientControllers[i].text.isNotEmpty) {
        request.fields['nama_bahan_${i + 1}'] = _ingredientControllers[i].text;
      }
    }

    for (int i = 0; i < _stepControllers.length; i++) {
      if (_stepControllers[i].text.isNotEmpty) {
        request.fields['step_number_${i + 1}'] = (i + 1).toString();
        request.fields['instruksi_${i + 1}'] = _stepControllers[i].text;
      }
    }

    if (galleryFile != null) {
      final imageFile =
          await http.MultipartFile.fromPath('image_resep', galleryFile!.path);
      request.files.add(imageFile);
    }

    try {
      final response = await request.send();
      // ignore: unused_local_variable
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil diposting'),
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // Indicate that refresh is needed
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan resep: ${response.reasonPhrase}')),
        );
        debugPrint('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
      debugPrint('Error: $e');
    }
  }

  bool _validateData() {
    if (_titleController.text.isEmpty ||
        _titleController.text.length > 255 ||
        _descriptionController.text.isEmpty ||
        galleryFile != null && galleryFile!.lengthSync() > 2048 * 1024 ||
        _ingredientControllers.every((controller) => controller.text.isEmpty) ||
        _stepControllers.every((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field yang wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate title
    if (_titleController.text.isEmpty || _titleController.text.length > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul Resep Masakan Harus Terisi !'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate description
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description Harus Terisi'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate image size
    if (galleryFile != null && galleryFile!.lengthSync() > 2048 * 1024) {
      // 2MB = 2048 * 1024 bytes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal Ukuran Gambar 2MB'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Ensure at least one ingredient and one step are filled
    if (_ingredientControllers.every((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setidaknya 1 Bahan Harus Terisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_stepControllers.every((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setidaknya 1 Step Harus Terisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Resep')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Upload Gambar Resep Anda!"),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: galleryFile != null
                          ? Image.file(galleryFile!)
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _showPicker(context),
                child: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 350,
                child: (TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                    hintText: 'Masukkan Nama Resep Anda',
                    hintStyle: TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                    labelText: 'Nama Resep',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Resep tidak boleh kosong';
                    }
                    return null;
                  },
                )),
              ),
              const SizedBox(height: 20.0),
              const Text('Deskripsi Masakan'),
              TextFormField(
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                items: <String>['Vegetarian', 'Non-Vegetarian']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              const Text('Bahan-Bahan'),
              ...List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _ingredientControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Bahan ${index + 1}'),
                    validator: (value) {
                      // Mengecek apakah validasi sudah dilakukan atau belum
                      if (!isValidationDone) {
                        // Melakukan validasi hanya untuk indeks pertama
                        if (index == 0) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi bahan ${index + 1}';
                          }
                        }
                      }
                      return null; // Return null jika tidak ada error
                    },
                  ),
                );
              }),
              const SizedBox(height: 20.0),
              const Text('Langkah-langkah'),
              ...List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    controller: _stepControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Langkah ${index + 1}'),
                    validator: (value) {
                      // Mengecek apakah validasi sudah dilakukan atau belum
                      if (!isValidationDone) {
                        // Melakukan validasi hanya untuk indeks pertama
                        if (index == 0) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi Langkah ${index + 1}';
                          }
                        }
                      }
                      return null; // Return null jika tidak ada error
                    },
                  ),
                );
              }),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _postData(widget.idUser);
                  }
                },
                child: const Text('Upload Resep Masakan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
