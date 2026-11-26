import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'release_assets.dart';
import 'release_target.dart';

final class BinaryCache {
  BinaryCache(this._root, this._assets, this._makeExecutable);

  final Directory _root;
  final ReleaseAssets _assets;
  final Future<void> Function(File) _makeExecutable;

  Future<File> resolve(String version, ReleaseTarget target) async {
    final versionDirectory = Directory(p.join(_root.path, version));
    final entry = Directory(p.join(versionDirectory.path, target.rid));
    final kind = await FileSystemEntity.type(entry.path, followLinks: false);
    if (kind != FileSystemEntityType.notFound) {
      return _readEntry(entry, target);
    }

    final checksum = await _assets.checksumFor(target.asset);
    await versionDirectory.create(recursive: true);
    final stage = await versionDirectory.createTemp('.${target.rid}-');
    try {
      final binary = File(p.join(stage.path, target.asset));
      await _assets.download(target.asset, binary);
      await _verify(binary, checksum);
      if (target != ReleaseTarget.windowsX64) {
        await _makeExecutable(binary);
      }
      await File(p.join(stage.path, 'sha256'))
          .writeAsString(checksum, flush: true);

      // Both files become visible together. An already-published directory is
      // nonempty, so an overlapping rename cannot replace it.
      try {
        await stage.rename(entry.path);
      } on FileSystemException {
        if (!await entry.exists()) rethrow;
        return await _readEntry(entry, target);
      }
      return File(p.join(entry.path, target.asset));
    } finally {
      if (await stage.exists()) {
        await stage.delete(recursive: true);
      }
    }
  }

  Future<File> _readEntry(Directory entry, ReleaseTarget target) async {
    final binary = File(p.join(entry.path, target.asset));
    final checksumFile = File(p.join(entry.path, 'sha256'));
    if (await FileSystemEntity.type(entry.path, followLinks: false) !=
            FileSystemEntityType.directory ||
        await FileSystemEntity.type(binary.path, followLinks: false) !=
            FileSystemEntityType.file ||
        await FileSystemEntity.type(checksumFile.path, followLinks: false) !=
            FileSystemEntityType.file) {
      throw FileSystemException(
          'Incomplete native binary cache entry', entry.path);
    }
    final checksum = await checksumFile.readAsString();
    if (checksum.length != 64 || !RegExp(r'^[0-9a-f]+$').hasMatch(checksum)) {
      throw FormatException('Malformed cached SHA-256: ${checksumFile.path}.');
    }
    await _verify(binary, checksum);
    return binary;
  }

  Future<void> _verify(File binary, String expected) async {
    if (await binary.length() == 0) {
      throw FormatException('Empty native binary: ${binary.path}.');
    }
    final actual = (await sha256.bind(binary.openRead()).single).toString();
    if (actual != expected) {
      throw FormatException(
        'SHA-256 mismatch for ${binary.path}. Expected $expected, got $actual.',
      );
    }
  }
}
