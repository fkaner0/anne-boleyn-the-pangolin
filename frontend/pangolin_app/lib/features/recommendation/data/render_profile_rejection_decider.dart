import 'package:pangolin_app/features/recommendation/data/api_profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';

class RenderProfileRejectionDecider implements ProfileRejectionDecider {
  final ApiProfileRejectionDecider _delegate;

  RenderProfileRejectionDecider({String host = 'anne-boleyn-the-pangolin-huqk.onrender.com', bool useHttps = true}) : _delegate = ApiProfileRejectionDecider(host: host, useHttps: useHttps);

  @override
  Future<void> putProfileRejection({
    required int userId,
    required bool rejected,
  }) {
    return _delegate.putProfileRejection(userId: userId, rejected: rejected);
  }
}
