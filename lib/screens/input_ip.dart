import 'package:flutter/material.dart';
import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/utils/constants.dart'; // Assuming this is where baseURL is defined

// Stateful widget for InputIp
class InputIp extends StatefulWidget {
  const InputIp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InputIpState createState() => _InputIpState();
}

class _InputIpState extends State<InputIp> {
  // Controller for the TextField
  final TextEditingController _ipController = TextEditingController();

  // Method to save the IP address
  void saveIP() async {
    await SecureStorageUtil.storage
        .write(key: baseURL, value: _ipController.text);
    // Show a SnackBar to confirm saving
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('IP BaseURL berhasil disimpan'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input IP BaseURL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Masukkan IP BaseURL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: saveIP,
              child: const Text('Simpan IP'),
            ),
          ],
        ),
      ),
    );
  }
}
