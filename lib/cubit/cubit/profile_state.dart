part of 'profile_cubit.dart';

@immutable
class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final bool isProfileComplete;
  final Profile? profile;

  ProfileLoaded({required this.isProfileComplete, this.profile});
}
