import 'dart:io';

Future<void> makeExecutable(File binary) async {
  final result = await Process.run('chmod', ['700', binary.path]);
  if (result.exitCode != 0) {
    throw FileSystemException('chmod failed: ${result.stderr}', binary.path);
  }
}

Future<int> runNative(File binary, List<String> arguments) async {
  final child = await Process.start(
    binary.absolute.path,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  if (Platform.isWindows) return child.exitCode;

  final signals = [
    ProcessSignal.sigint,
    ProcessSignal.sigterm,
    ProcessSignal.sighup,
  ];
  final subscriptions = [
    for (final signal in signals) signal.watch().listen(child.kill),
  ];
  try {
    final code = await child.exitCode;
    return code < 0 ? 128 - code : code;
  } finally {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }
}
