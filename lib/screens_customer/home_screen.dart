import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_projek/components/asset_image_widget.dart';
import 'package:my_projek/dto/resep.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:http/http.dart' as http;
import 'package:my_projek/screens_customer/resep/detail_resep.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  final TextEditingController _searchController = TextEditingController();
  List<Resep> reseps = [];
  int currentPage = 1;
  final int pageSize = 3; // Number of items per page
  bool isLoading = false;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReseps();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchReseps() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        '${ResepKita.resep}/reseps?page=$currentPage&pageSize=$pageSize'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      List<Resep> fetchedReseps =
          data.map((item) => Resep.fromJson(item)).toList();

      setState(() {
        reseps.addAll(fetchedReseps);
        currentPage++;
        isLoading = false;
        if (fetchedReseps.length < pageSize) {
          hasMoreData = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load reseps');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        hasMoreData &&
        !isLoading) {
      _fetchReseps();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(
              height: 0.30,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 115, 217, 235), // Warna latar belakang
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 115, 217, 235), // Warna border
                ),
              ),
              child: CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 25 / 10,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
                items: [
                  Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const AssetImageWidget(
                        imagePath: 'assets/image/ramdhan2024.png'),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const AssetImageWidget(
                        imagePath: 'assets/image/banner3.jpeg'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0988B5).withOpacity(0.19),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(child: Text("Favorite")),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0988B5).withOpacity(0.19),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(child: Text("Terbaru")),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0988B5).withOpacity(0.19),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(child: Text("Fresh")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reseps.length + (hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == reseps.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                Resep resep = reseps[index];
                return ListTile(
                  title: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "@ ${resep.namaPublic}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      '${ResepKita.baseUrl}/${resep.imageResep}',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      resep.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      resep.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              const Divider(),
                              const SizedBox(height: 10),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.favorite_border),
                                    Icon(Icons.bookmark_add_outlined),
                                    Icon(Icons.share_outlined),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}
