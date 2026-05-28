import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';

class MockProfileRejectionDecider implements ProfileRejectionDecider {
  final Map<int, bool> rejections = {};

  @override
  Future<void> putProfileRejection({
    required int userId,
    required bool rejected,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    rejections[userId] = rejected;
  }
}
