import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/profile.dart';
import 'profile_updater.dart';
import '/utils/connection_utils.dart';

class ApiProfileUpdater implements ProfileUpdater {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiProfileUpdater({
    this.host = 'localhost',
    this.port,
    this.useHttps = false,
  });

  @override
  Future<void> updateProfile(Profile profile) async {
    final authority = port == null ? host : '$host:$port';
    final uri = newUri(authority, '/profile/edit/${profile.userId}', useHttps);

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
