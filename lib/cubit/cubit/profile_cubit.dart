import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:my_projek/constants/secure_storage_util.dart';

import 'package:my_projek/dto/profile.dart';
import 'package:my_projek/endpoints/resep_kita.dart';
import 'package:my_projek/utils/constants.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<int> _getUserId() async {
    String? userIdString =
        await SecureStorageUtil.storage.read(key: userIdStoreName);
    if (userIdString != null) {
      return int.parse(userIdString);
    } else {
      throw Exception('User ID not found in secure storage');
    }
  }

  Future<void> _loadProfile() async {
    try {
      int userId = await _getUserId(); // Mendapatkan userId
      final profile = await fetchProfile(userId);
      emit(ProfileLoaded(isProfileComplete: true, profile: profile));
    } catch (e) {
      emit(ProfileLoaded(isProfileComplete: false));
    }
  }

  Future<void> checkProfileCompletion() async {
    try {
      await _loadProfile();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user ID: $e');
      // ignore: use_rethrow_when_possible
      throw e;
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
}
