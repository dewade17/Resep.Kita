import 'package:my_projek/constants/secure_storage_util.dart';
import 'package:my_projek/utils/constants.dart';

class ResepKita {
  static String baseUrl = '';

  static String login = '';
  static String logout = '';
  static String profile = '';
  static String resep = '';
  static String register = '';
  static String newPassword = '';
  static String verificationCode = '';

  /// Initialize URLs based on the stored base URL.
  static Future<void> initializeURLs() async {
    try {
      baseUrl = await SecureStorageUtil.storage.read(key: baseURL) ?? '';
      if (baseUrl.isNotEmpty) {
        if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
          // Assuming default to http if scheme is missing
          baseUrl = 'http://$baseUrl';
        }
        login = "$baseUrl/login";
        logout = "$baseUrl/logout";
        profile = "$baseUrl/profiles";
        resep = "$baseUrl/users";
        register = "$baseUrl/register";
        newPassword = "$baseUrl/update-password";
        verificationCode = "$baseUrl/send-verification-code";
      } else {
        // Handle the case where the base URL is not set or invalid
        throw Exception('Base URL is empty');
      }
    } catch (e) {
      // Handle any errors that might occur during reading from storage
      // ignore: avoid_print
      print('Error initializing URLs: $e');
      rethrow; // Re-throwing to ensure calling code can handle this error if needed
    }
  }
}
