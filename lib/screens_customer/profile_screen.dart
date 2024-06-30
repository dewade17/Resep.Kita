import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_projek/components/asset_image_widget.dart';
import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/cubit/cubit/profile_cubit.dart';
import 'package:my_projek/dto/profile.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/screens_customer/negarascreen.dart';
import 'package:my_projek/screens_customer/profile/new_profile.dart';
import 'package:my_projek/screens_customer/profile/update_profile.dart';
import 'package:my_projek/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Profile> futureProfile;
  final Completer<Profile> _completer = Completer<Profile>();

  @override
  void initState() {
    super.initState();
    futureProfile = _completer.future;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      int idUser = await _getUserId();
      final profile = await fetchProfile(idUser);
      _completer.complete(profile);
    } catch (e) {
      _completer.completeError(e);
    }
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

  Future<Profile> fetchProfile(int idUser) async {
    final response = await http.get(Uri.parse('${ResepKita.profile}/$idUser'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Profile.fromJson(data.first);
      } else {
        throw Exception('Profile not found');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Account not found');
    } else {
      throw Exception('Failed to fetch account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image Section
            Stack(
              alignment: Alignment.topCenter,
              children: [
                const AssetImageWidget(
                  imagePath: "assets/image/bg_profile.jpg",
                ),
                // Profile Picture Section
                FutureBuilder<Profile>(
                  future: futureProfile,
                  builder:
                      (BuildContext context, AsyncSnapshot<Profile> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      if (snapshot.error is Exception) {
                        return Container(
                          color: const Color.fromARGB(255, 104, 194, 200),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 350,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: Colors.blue, // Warna border
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 50,
                                        ),
                                        Text("Lengkapi Data Profil Anda !")
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(child: Text('${snapshot.error}'));
                      }
                    } else if (snapshot.hasData) {
                      final Profile profile = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height:
                                      120, // Space for the profile picture circle
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 104, 194, 200),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top:
                                            -50, // Adjust the position of the CircleAvatar
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(
                                            '${ResepKita.baseUrl}/${profile.profile_picture!}',
                                            // errorBuilder:
                                            //     (context, error, stackTrace) {
                                            //   print(
                                            //       'Error loading image: $error');
                                            //   print(
                                            //       'Stack trace: $stackTrace');
                                            //   return Icon(Icons.error);
                                            // },
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(
                                            height: 70,
                                          ),
                                          Text(
                                            ' ${profile.nama ?? "Not Available"}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20,
                                              fontStyle: FontStyle.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            ' ${profile.email ?? "Not Available"}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              fontStyle: FontStyle.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            // ignore: unnecessary_string_interpolations
                                            ('${profile.alamat ?? "Not Available"}'),
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              fontStyle: FontStyle.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    "Tanggal Lahir",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    // ignore: unnecessary_string_interpolations
                                                    '${profile.tanggalLahir != null ? DateFormat('yyyy-MM-dd').format(profile.tanggalLahir!) : "Not Available"}',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.black87,
                                                    ),
                                                  ), // Assuming you have a tanggalLahir field in the Profile class
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    "No.Handphone",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    // ignore: unnecessary_string_interpolations
                                                    ('${profile.noHandphone ?? "Not Available"}'),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                      Positioned(
                                        top:
                                            20, // Position the edit icon properly
                                        child: GestureDetector(
                                          onTap: () async {
                                            int idUser = await _getUserId();
                                            Profile profile =
                                                await fetchProfile(idUser);
                                            Navigator.push(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateProfile(
                                                  profile: profile,
                                                  idUser: idUser,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 248, 248, 248),
                                              shape: BoxShape.circle,
                                              border: Border.all(),
                                            ),
                                            child: const Icon(Icons.edit),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text('No data found'));
                    }
                  },
                ),
              ],
            ),
            // Info Sections
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 104, 194, 200),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman lain di sini
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NegaraScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Colors.blue, // Warna border
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Bahasa"),
                            Row(
                              children: [
                                Text("Indonesia"),
                                SizedBox(
                                  width: 13,
                                ),
                                Hero(
                                  tag: 'flagImage',
                                  child: AssetImageWidget(
                                    imagePath: 'assets/image/Indonesia.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.blue,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Kebijakan Privasi")],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Ketentuan Pemakaian")],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Hubungi Kami")],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded && !state.isProfileComplete) {
            return FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () async {
                int idUser = await _getUserId();
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewProfile(idUser: idUser),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class ProfileNotFoundException implements Exception {
  final String message;

  ProfileNotFoundException(this.message);
}
