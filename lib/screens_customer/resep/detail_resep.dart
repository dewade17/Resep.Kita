import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'package:my_projek/dto/resep.dart';
import 'package:my_projek/endpoints/resep_kita.dart';

class DetailResep extends StatefulWidget {
  const DetailResep({super.key, required this.resep});
  final Resep resep;
  @override
  // ignore: library_private_types_in_public_api
  _DetailResepState createState() => _DetailResepState();
}

class _DetailResepState extends State<DetailResep> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resep.title),
      ),
      backgroundColor: const Color.fromARGB(255, 115, 217, 235),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.resep.imageResep.isNotEmpty
                  ? Image.network(
                      '${ResepKita.baseUrl}/${widget.resep.imageResep}',
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    )
                  : const SizedBox(
                      height: 250, child: Center(child: Text('No Image'))),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                '@${widget.resep.namaPublic}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal:
                      5), // Memberikan spasi horizontal antara kontainer
              width: 400,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 212, 212, 212).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.black)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resep.title,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.resep.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.resep.kategori,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal:
                      5), // Memberikan spasi horizontal antara kontainer
              width: 400,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 212, 212, 212).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.black)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          for (var ingredient in widget.resep.ingredients)
                            if (ingredient.isNotEmpty)
                              Text(
                                '- $ingredient',
                                style: const TextStyle(fontSize: 16),
                              ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal:
                      5), // Memberikan spasi horizontal antara kontainer
              width: 400,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 212, 212, 212).withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.black)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Steps',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          for (int i = 0;
                              i < widget.resep.instructions.length;
                              i++)
                            if (widget.resep.instructions[i].isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${widget.resep.stepNumbers[i]}. ${widget.resep.instructions[i]}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
