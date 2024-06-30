import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_projek/dto/resep.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/screens_customer/resep/detail_resep.dart';

class DetailSearch extends StatefulWidget {
  const DetailSearch({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DetailSearchState createState() => _DetailSearchState();
}

class _DetailSearchState extends State<DetailSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Resep> _reseps = [];
  bool _loading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  Future<void> searchResep(String title) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final response = await http
          .get(Uri.parse('${ResepKita.resep}/reseps/search?title=$title'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          _reseps = jsonResponse.map((resep) => Resep.fromJson(resep)).toList();
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        searchResep(_searchController.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_hasSearched)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Please enter a recipe name to search.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (_loading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_hasSearched && _reseps.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No recipes found',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reseps.length,
                itemBuilder: (context, index) {
                  Resep resep = _reseps[index];
                  return ListTile(
                    // ignore: unnecessary_null_comparison
                    leading: _reseps[index].imageResep != null
                        ? Image.network(
                            '${ResepKita.baseUrl}/${_reseps[index].imageResep}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          )
                        : null,
                    title: Text(resep.title),
                    subtitle: Text(resep.description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailResep(resep: resep),
                        ),
                      );
                    },
                  );
                },
              ),
            const Text(
              "Bahan populer di Bulan Ramadhan",
              style: TextStyle(fontFamily: 'poppins', fontSize: 19),
            ),
            const SizedBox(
              height: 15,
            ),
            Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                                // boxShadow: [
                                //   // BoxShadow(
                                //   //   // color: Color(0xFF0988B5), // Warna bayangan
                                //   //   spreadRadius: 5, // Radius penyebaran bayangan
                                //   //   blurRadius: 7, // Radius blur bayangan
                                //   //   offset: Offset(0, 3), // Offset bayangan (dx, dy)
                                //   // ),
                                // ],
                                color:
                                    const Color(0xFF0988B5).withOpacity(0.19),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: Colors.black),
                                image: const DecorationImage(
                                    image: AssetImage("assets/image/ikan.png"),
                                    fit: BoxFit.cover)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Ikan",
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: 20,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1.2
                                      ..color = const Color.fromARGB(
                                          221, 255, 255, 255),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                                // boxShadow: [
                                //   // BoxShadow(
                                //   //   // color: Color(0xFF0988B5), // Warna bayangan
                                //   //   spreadRadius: 5, // Radius penyebaran bayangan
                                //   //   blurRadius: 7, // Radius blur bayangan
                                //   //   offset: Offset(0, 3), // Offset bayangan (dx, dy)
                                //   // ),
                                // ],
                                color:
                                    const Color(0xFF0988B5).withOpacity(0.19),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: Colors.black),
                                image: const DecorationImage(
                                    image: AssetImage("assets/image/ayam.png"),
                                    fit: BoxFit.cover)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Daging Ayam",
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: 19,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1.2
                                      ..color = const Color.fromARGB(
                                          221, 255, 255, 255),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                                // boxShadow: [
                                //   // BoxShadow(
                                //   //   // color: Color(0xFF0988B5), // Warna bayangan
                                //   //   spreadRadius: 5, // Radius penyebaran bayangan
                                //   //   blurRadius: 7, // Radius blur bayangan
                                //   //   offset: Offset(0, 3), // Offset bayangan (dx, dy)
                                //   // ),
                                // ],
                                color:
                                    const Color(0xFF0988B5).withOpacity(0.19),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: Colors.black),
                                image: const DecorationImage(
                                    image:
                                        AssetImage("assets/image/kambing.png"),
                                    fit: BoxFit.cover)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Daging Kambing",
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: 20,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1.2
                                      ..color = const Color.fromARGB(
                                          221, 255, 255, 255),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 150,
                          height: 100,
                          decoration: BoxDecoration(
                              // boxShadow: [
                              //   // BoxShadow(
                              //   //   // color: Color(0xFF0988B5), // Warna bayangan
                              //   //   spreadRadius: 5, // Radius penyebaran bayangan
                              //   //   blurRadius: 7, // Radius blur bayangan
                              //   //   offset: Offset(0, 3), // Offset bayangan (dx, dy)
                              //   // ),
                              // ],
                              color: const Color(0xFF0988B5).withOpacity(0.19),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: Colors.black),
                              image: const DecorationImage(
                                  image: AssetImage("assets/image/sapi.png"),
                                  fit: BoxFit.cover)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Daging Sapi",
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontFamily: 'poppins',
                                  fontSize: 20,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.2
                                    ..color = const Color.fromARGB(
                                        221, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
