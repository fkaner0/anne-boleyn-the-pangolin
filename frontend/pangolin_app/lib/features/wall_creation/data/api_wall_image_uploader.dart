import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'wall_image_uploader.dart';

class ApiWallImageUploader implements WallImageUploader {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiWallImageUploader({
    this.host = 'localhost',
    this.port,
    this.useHttps = false,
  });

  @override
  Future<String> uploadImage(Uint8List bytes) async {
    final authority = port == null ? host : '$host:$port';
    final uri = useHttps
        ? Uri.https(authority, '/wallImage')
        : Uri.http(authority, '/wallImage');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: 'image'),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to upload wall image: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['url'] as String;
  }
}
