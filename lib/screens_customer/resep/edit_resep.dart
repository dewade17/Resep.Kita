import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/dto/resep.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/utils/constants.dart';

class EditResep extends StatefulWidget {
  const EditResep({super.key, required this.resep});
  final Resep resep;

  @override
  // ignore: library_private_types_in_public_api
  _EditResepState createState() => _EditResepState();
}

class _EditResepState extends State<EditResep> {
  final _formKey = GlobalKey<FormState>();
  late Future<Resep?> futureResep;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers =
      List.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _stepControllers =
      List.generate(10, (_) => TextEditingController());
  final picker = ImagePicker();
  File? galleryFile;
  bool isValidationDone = false;

  late int _userId;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    futureResep = Future.value(null); // Initialize with an empty Future
    _getUserId().then((userId) {
      setState(() {
        _userId = userId;
        futureResep =
            fetchResep(widget.resep.idResep, userId); // Fetch the recipe
      });
    }).catchError((error) {
      debugPrint('Error getting user ID: $error');
    });
  }

  Future<int> _getUserId() async {
    String? userIdString =
        await SecureStorageUtil.storage.read(key: userIdStoreName);
    if (userIdString != null) {
      return int.parse(userIdString);
    } else {
      throw Exception('User ID not found in secure storage');
    }
  }

  Future<Resep?> fetchResep(int idResep, int idUser) async {
    final response =
        await http.get(Uri.parse('${ResepKita.resep}/$idUser/reseps/$idResep'));

    if (response.statusCode == 200) {
      final resep = Resep.fromJson(jsonDecode(response.body));
      _titleController.text = resep.title;
      _descriptionController.text = resep.description;
      _selectedCategory = resep.kategori;
      for (int i = 0; i < 10; i++) {
        _ingredientControllers[i].text =
            resep.toJson()['nama_bahan_${i + 1}'] ?? '';
        _stepControllers[i].text = resep.toJson()['instruksi_${i + 1}'] ?? '';
      }
      return resep;
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    }
  }

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

  Future<void> _updateRecipe(int idResep) async {
    if (!_validateData()) {
      return;
    }

    final Uri url = Uri.parse('${ResepKita.resep}/$_userId/reseps/$idResep');

    final request = http.MultipartRequest('POST', url)
      ..fields['_method'] = 'POST'
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

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep Makanan Berhasil updated')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal Update Resep Makanan: ${response.reasonPhrase}')),
        );
        debugPrint('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      debugPrint('Error: $e');
    }
  }

  bool _validateData() {
    if (_titleController.text.isEmpty || _titleController.text.length > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Title is required and should be at most 255 characters'),
        ),
      );
      return false;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required')),
      );
      return false;
    }

    if (galleryFile != null && galleryFile!.lengthSync() > 2048 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image must be at most 2MB')),
      );
      return false;
    }

    if (_ingredientControllers.every((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one ingredient must be filled')),
      );
      return false;
    }

    if (_stepControllers.every((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one step must be filled')),
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
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: FutureBuilder<Resep?>(
        future: futureResep,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final resep = snapshot.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text('Upload Gambar Resep Anda!'),
                    if (galleryFile != null)
                      Image.file(
                        galleryFile!,
                        height: 200,
                      )
                    else if (resep?.imageResep != null &&
                        resep!.imageResep.isNotEmpty)
                      Image.network(
                        '${ResepKita.baseUrl}/${resep.imageResep}',
                        height: 200,
                      ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () => _showPicker(context),
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87)),
                            hintText: 'Masukkan Nama Resep Anda',
                            hintStyle:
                                TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
                            labelText: 'Nama Resep',
                            labelStyle: TextStyle(color: Colors.black87)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Resep tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text('Deskripsi Resep'),
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
                          decoration: InputDecoration(
                            labelText: 'Bahan ${index + 1}',
                          ),
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
                    const Text('Langah-Langkah'),
                    ...List.generate(10, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _stepControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Langkah ${index + 1}',
                          ),
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
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (snapshot.hasData) {
                              _updateRecipe(snapshot.data!.idResep);
                            }
                          }
                        },
                        child: const Text('Update Recipe'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('Recipe not found'));
          }
        },
      ),
    );
  }
}
