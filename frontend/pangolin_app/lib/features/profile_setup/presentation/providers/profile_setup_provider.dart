import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TODO: not sure where this one shld acc go
import '../../../../shared/user_model.dart';
// import '../services/api_service.dart';
// import 'auth_provider.dart';

/// Holds the editable state of the current user's profile during sign-up
/// and on the profile/edit pages.
final profileSetupProvider = StateNotifierProvider<ProfileNotifier, UserModel?>(
  (ref) {
    return ProfileNotifier();
    // return ProfileNotifier(ref.read(apiServiceProvider));
  },
);

class ProfileNotifier extends StateNotifier<UserModel?> {
  // final ApiService _api;
  // ProfileNotifier(this._api) : super(null);
  ProfileNotifier() : super(null);

  void initialise(UserModel user) => state = user;

  void updateHobby(String hobby) => ();
  // state = state?.copyWith(hobby: hobby);

  void updatePassionLevel(double level) => ();
  // state = state?.copyWith(passionLevel: level);

  void updateName(String name) => ();
  // state = state?.copyWith(name: name);

  void updateAge(int age) => ();
  // state = state?.copyWith(age: age);

  void addSubInterest(String interest) {
    // if (state == null) return;
    // final updated = List<String>.from(state!.subInterests)..add(interest);
    // state = state!.copyWith(subInterests: updated);
  }

  void removeSubInterest(String interest) {
    // if (state == null) return;
    // final updated = List<String>.from(state!.subInterests)..remove(interest);
    // state = state!.copyWith(subInterests: updated);
  }

  void addOtherInterest(String interest) {
    // if (state == null) return;
    // final updated = List<String>.from(state!.otherInterests)..add(interest);
    // state = state!.copyWith(otherInterests: updated);
  }

  void removeOtherInterest(String interest) {
    // if (state == null) return;
    // final updated = List<String>.from(state!.otherInterests)..remove(interest);
    // state = state!.copyWith(otherInterests: updated);
  }

  Future<void> saveProfile() async {
    // if (state == null) return;
    // await _api.updateProfile(state!);
  }
}
