
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/cubit/cubit/profile_cubit.dart';
import 'package:my_projek/dto/resep.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/screens_customer/profile_screen.dart';
import 'package:my_projek/screens_customer/resep/edit_resep.dart';
import 'package:my_projek/screens_customer/resep/new_resep.dart';
import 'package:my_projek/utils/constants.dart';

class ResepScreen extends StatefulWidget {
  const ResepScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResepScreenState createState() => _ResepScreenState();
}

class _ResepScreenState extends State<ResepScreen> {
  late Future<int> _userIdFuture;
  late Future<List<Resep>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = _getUserId();
    _recipesFuture = _userIdFuture.then((id) => _fetchRecipes(id));
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

  Future<List<Resep>> _fetchRecipes(int idUser) async {
    final response =
        await http.get(Uri.parse('${ResepKita.resep}/$idUser/reseps'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((resep) => Resep.fromJson(resep)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<void> _refreshRecipes() async {
    int idUser = await _userIdFuture;
    setState(() {
      _recipesFuture = _fetchRecipes(idUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          if (state.isProfileComplete) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  // Retrieve the idUser
                  int idUser = await _userIdFuture;
                  // Navigate to the NewResep screen
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewResep(
                        idUser: idUser,
                      ),
                    ),
                  ).then((shouldRefresh) {
                    if (shouldRefresh == true) {
                      _refreshRecipes();
                    }
                  });
                },
                child: const Icon(Icons.add),
              ),
              body: FutureBuilder<int>(
                future: _userIdFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return FutureBuilder<List<Resep>>(
                      future: _recipesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<Resep> reseps = snapshot.data!;
                          if (reseps.isEmpty) {
                            return const Center(child: Text('No recipes found.'));
                          }
                          return ListView.builder(
                            itemCount: reseps.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade300),
                                  child: ListTile(
                                    // ignore: unnecessary_null_comparison
                                    leading: reseps[index].imageResep != null
                                        ? Image.network(
                                            '${ResepKita.baseUrl}/${reseps[index].imageResep}',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.error),
                                          )
                                        : null,
                                    title: Text(reseps[index].title),
                                    subtitle: Text(reseps[index].description),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditResep(
                                                resep: reseps[index],
                                              ),
                                            ),
                                          ).then((shouldRefresh) {
                                            if (shouldRefresh == true) {
                                              _refreshRecipes();
                                            }
                                          });
                                        } else if (value == 'delete') {
                                          int idUser =
                                              await _userIdFuture; // Ensure idUser is available
                                          await deleteResep(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              idUser,
                                              reseps[index]
                                                  .idResep); // Pass all required arguments
                                          _refreshRecipes();
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text('No data available'));
                        }
                      },
                    );
                  }
                },
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lengkapi Data Profil Lebih Dahulu!',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: const Text('Complete Profile'),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          // Handle other states (e.g., loading, error)
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<void> deleteResep(
      BuildContext context, int idUser, int resepId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ResepKita.resep}/$idUser/reseps/$resepId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add other headers if needed, such as authorization token
        },
      );

      if (response.statusCode == 204) {
        // Recipe successfully deleted
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resep Berhasil Dihapus')));
        _refreshRecipes();
      } else {
        // Failed to delete recipe
        // ignore: avoid_print
        print('Failed to delete recipe: ${response.statusCode}');
      }
    } catch (e) {
      // Error during request
      // ignore: avoid_print
      print('Error: $e');
    }
  }
}
