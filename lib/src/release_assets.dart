import 'dart:convert';
import 'dart:io';

final class ReleaseAssets {
  ReleaseAssets(this._client, this._release);

  final HttpClient _client;
  final Uri _release;

  Future<String> checksumFor(String asset) async {
    final response = await _get('checksums.txt');
    final text = await utf8.decoder.bind(response).join();
    final checksums = <String, String>{};
    final entry = RegExp(r'^([0-9a-fA-F]{64})  ([a-zA-Z0-9_.-]+)$');
    final lines = const LineSplitter().convert(text);
    for (var index = 0; index < lines.length; index++) {
      final match = entry.firstMatch(lines[index]);
      if (match == null) {
        throw FormatException('Malformed checksums.txt at line ${index + 1}.');
      }
      final name = match[2]!;
      if (checksums.containsKey(name)) {
        throw FormatException('Duplicate checksum for $name in checksums.txt.');
      }
      checksums[name] = match[1]!.toLowerCase();
    }

    final digest = checksums[asset];
    if (digest == null) {
      throw FormatException('Missing checksum for $asset in checksums.txt.');
    }
    return digest;
  }

  Future<void> download(String asset, File destination) async {
    final response = await _get(asset);
    final sink = destination.openWrite();
    try {
      await sink.addStream(response);
    } finally {
      await sink.close();
    }
  }

  Future<HttpClientResponse> _get(String asset) async {
    final uri = _release.resolve(asset);
    final request = await _client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode} for $asset', uri: uri);
    }
    return response;
  }
}
