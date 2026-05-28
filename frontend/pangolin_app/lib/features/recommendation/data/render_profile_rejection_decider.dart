import 'package:pangolin_app/features/recommendation/data/api_profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';

class RenderProfileRejectionDecider implements ProfileRejectionDecider {
  final ApiProfileRejectionDecider _delegate = const ApiProfileRejectionDecider(
    host: 'anne-boleyn-the-pangolin-huqk.onrender.com',
    useHttps: true,
  );

  @override
  Future<void> putProfileRejection({
    required int userId,
    required bool rejected,
  }) {
    return _delegate.putProfileRejection(userId: userId, rejected: rejected);
  }
}
