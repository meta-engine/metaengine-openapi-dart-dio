import 'dart:ffi';
import 'dart:io';

import 'binary_cache.dart';
import 'cache_root.dart';
import 'native_process.dart';
import 'release_assets.dart';
import 'release_target.dart';

Future<int> runCli(
  List<String> arguments, {
  required String version,
  required Uri releaseOrigin,
}) async {
  try {
    final target = ReleaseTarget.forAbi(Abi.current());
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    final File binary;
    try {
      final assets = ReleaseAssets(client, releaseOrigin.resolve('v$version/'));
      final cache = BinaryCache(
        userCacheRoot(Platform.environment),
        assets,
        makeExecutable,
      );
      binary = await cache.resolve(version, target);
    } finally {
      client.close(force: true);
    }
    return await runNative(binary, arguments);
  } on Exception catch (error) {
    stderr.writeln('metaengine_openapi_dart_dio: $error');
    return 1;
  }
}
