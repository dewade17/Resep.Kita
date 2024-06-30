import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/components/auth_wrapper.dart';
import 'package:my_projek/cubit/auth/auth_cubit.dart';
import 'package:my_projek/cubit/cubit/profile_cubit.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
// import 'package:my_projek/masakan/masakan_screen.dart';
import 'package:my_projek/screens/test_screen.dart';
import 'package:my_projek/screens_customer/about_us.dart';
import 'package:my_projek/screens_customer/detail_search.dart';
import 'package:my_projek/screens_customer/home_screen.dart';
import 'package:my_projek/screens_customer/profile_screen.dart';
import 'package:my_projek/screens_customer/resep_screen.dart';
import 'package:my_projek/utils/constants.dart';
import 'package:my_projek/utils/secure_storage_util.dart'; // Import SecureStorageUtil

// Definisikan nama kunci untuk penyimpanan ID pengguna

// Metode untuk mengambil ID pengguna dari penyimpanan yang aman
// ignore: unused_element
Future<int> _getUserId() async {
  String? userIdString =
      await SecureStorageUtil.storage.read(key: userIdStoreName);
  if (userIdString != null) {
    return int.parse(userIdString);
  } else {
    throw Exception('User ID not found in secure storage ppp');
  }
}

const String tokenStoreName = 'access_token';

// Fungsi main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize URLs before running the app
  try {
    await ResepKita.initializeURLs();
  } catch (e) {
    // Handle initialization error if necessary
    // ignore: avoid_print
    print('Failed to initialize URLs: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/intro-screen',
        routes: {
          '/profile-screen': (context) => const ProfileScreen(),
          '/intro-screen': (context) => const TestScreen(),
          '/home-screen': (context) => const AuthWrapper(
                child: MyHomePage(
                  title: 'Resep.Kita',
                ),
              ),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    ResepScreen(),
    DetailSearch(),
    ProfileScreen(),
  ];

  final List<String> _appBarTitles = const [
    'Resep.Kita',
    'Resep.anda',
    'Search.Resep',
    'Profile',
  ];

  late Future<int> _futureUserId; // Menyimpan future userId

  @override
  void initState() {
    super.initState();
    _futureUserId = _getUserId(); // Memulai proses pengambilan userId
    _loadProfile();
  }

  // Metode untuk memuat profil pengguna
  Future<void> _loadProfile() async {
    try {
      // ignore: unused_local_variable
      int userId = await _futureUserId; // Menunggu pengambilan userId
      // Jika userId telah ditemukan, panggil checkProfileCompletion
      // ignore: use_build_context_synchronously
      await BlocProvider.of<ProfileCubit>(context).checkProfileCompletion();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user ID: $e');
    }
  }

  // Metode untuk mengambil ID pengguna dari penyimpanan yang aman
  Future<int> _getUserId() async {
    String? userIdString =
        await SecureStorageUtil.storage.read(key: userIdStoreName);
    if (userIdString != null) {
      return int.parse(userIdString);
    } else {
      throw Exception('User ID not found in secure storage idoiii');
    }
  }

  // Metode untuk menangani penekanan tombol navigasi bawah
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && !state.isProfileComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan lengkapi profil Anda terlebih dahulu.'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitles[_selectedIndex]),
          backgroundColor: Colors.blue,
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Constants.scaffoldBackgroundColor,
          buttonBackgroundColor: Constants.primaryColor,
          items: <Widget>[
            Icon(
              Icons.home,
              size: 30.0,
              color: _selectedIndex == 0 ? Colors.white : Constants.activeMenu,
            ),
            Icon(
              Icons.add,
              size: 30.0,
              color: _selectedIndex == 1 ? Colors.white : Constants.activeMenu,
            ),
            Icon(
              Icons.search,
              size: 30.0,
              color: _selectedIndex == 2 ? Colors.white : Constants.activeMenu,
            ),
            Icon(
              Icons.person,
              size: 30.0,
              color: _selectedIndex == 3 ? Colors.white : Constants.activeMenu,
            ),
          ],
          onTap: _onItemTapped,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Resep.Kita',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.contact_emergency_outlined),
              //   title: const Text('Additional Info'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.pushNamed(context, '/divison-screen');
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.contact_emergency_outlined),
              //   title: const Text('Customer Screeen'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.pushNamed(context, '/customer-screen');
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.food_bank),
              //   title: Text('Makanan'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const MasakanScreen(),
              //       ),
              //     );
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.spatial_audio),
                title: const Text('About Us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUs()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  _onItemTapped(3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Log Out'),
                onTap: () {
                  // Call logout method when ListTile is tapped
                  logout(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    try {
      // Retrieve token from SecureStorageUtil
      String? storedToken =
          await SecureStorageUtil.storage.read(key: tokenStoreName);

      if (storedToken == null) {
        // ignore: avoid_print
        print('Token not found in secure storage.');
        return; // Exit function if token is not found
      }

      final url = Uri.parse(
          // ignore: unnecessary_string_interpolations
          '${ResepKita.logout}'); // Replace with appropriate logout URL

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'token': storedToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // ignore: avoid_print
        print('Logout successful: ${responseBody['message']}');

        // Delete token from SecureStorageUtil after successful logout (optional)
        await SecureStorageUtil.storage.delete(key: tokenStoreName);

        // Navigate to '/intro-screen' and remove all previous routes from the stack
        Navigator.pushNamedAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            '/intro-screen',
            (route) => false);
      } else if (response.statusCode == 422) {
        final responseBody = jsonDecode(response.body);
        // ignore: avoid_print
        print('Validation failed: ${responseBody['errors']}');
      } else {
        final responseBody = jsonDecode(response.body);
        // ignore: avoid_print
        print('Logout failed: ${responseBody['message']}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('An error occurred: $e');
    }
  }
}
