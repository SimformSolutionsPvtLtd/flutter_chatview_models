import 'package:flutter/widgets.dart';

extension TargetPlatformExtension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;

  bool get isIOS => this == TargetPlatform.iOS;

  // TODO: As audio_waveforms(https://pub.dev/packages/audio_waveforms) only supports Android & iOS as of now.
  bool get isAudioWaveformsSupported => isIOS || isAndroid;
}
