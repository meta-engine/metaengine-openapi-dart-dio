import 'dart:io';

import 'package:path/path.dart' as p;

Directory userCacheRoot(Map<String, String> environment) {
  if (Platform.isWindows) {
    final localAppData = environment['LOCALAPPDATA'];
    if (localAppData == null || !p.isAbsolute(localAppData)) {
      throw const FileSystemException('LOCALAPPDATA must be an absolute path.');
    }
    return Directory(p.join(localAppData, 'metaengine_openapi_dart_dio'));
  }

  final xdg = environment['XDG_CACHE_HOME'];
  if (xdg != null && p.isAbsolute(xdg)) {
    return Directory(p.join(xdg, 'metaengine_openapi_dart_dio'));
  }

  final home = environment['HOME'];
  if (home == null || !p.isAbsolute(home)) {
    throw const FileSystemException('HOME must be an absolute path.');
  }
  final base = Platform.isMacOS
      ? p.join(home, 'Library', 'Caches')
      : p.join(home, '.cache');
  return Directory(p.join(base, 'metaengine_openapi_dart_dio'));
}
