import 'package:http/http.dart' as http;
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import '/utils/connection_utils.dart';

class ApiProfileRejectionDecider implements ProfileRejectionDecider {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiProfileRejectionDecider({
    this.host = 'localhost',
    this.port,
    this.useHttps = false,
  });

  @override
  Future<void> putProfileRejection({
    required int userId,
    required bool rejected,
  }) async {
    String authority;
    if (port == null) {
      authority = host;
    } else {
      authority = '$host:$port';
    }

    final body = rejected.toString();

    final uri = newUri(authority, '/profile/$userId', useHttps);

    final response = await http.put(uri, body: body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update profile rejection: ${response.statusCode}',
      );
    }
  }
}
