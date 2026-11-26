import 'dart:ffi';

enum ReleaseTarget {
  macArm64('osx-arm64'),
  macX64('osx-x64'),
  linuxArm64('linux-arm64'),
  linuxX64('linux-x64'),
  windowsX64('win-x64', extension: '.exe');

  const ReleaseTarget(this.rid, {this.extension = ''});

  final String rid;
  final String extension;

  String get asset => 'metaengine-openapi-dart-dio-$rid$extension';

  static ReleaseTarget forAbi(Abi abi) => switch (abi) {
        Abi.macosArm64 => macArm64,
        Abi.macosX64 => macX64,
        Abi.linuxArm64 => linuxArm64,
        Abi.linuxX64 => linuxX64,
        Abi.windowsX64 => windowsX64,
        _ => throw PlatformException('Unsupported platform: $abi. '
            'Supported platforms: macOS arm64/x64, Linux arm64/x64, Windows x64.'),
      };
}

final class PlatformException implements Exception {
  PlatformException(this.message);

  final String message;

  @override
  String toString() => message;
}
