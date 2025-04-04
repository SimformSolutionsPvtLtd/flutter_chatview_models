import 'package:flutter/widgets.dart';

import '../models/data_models/reaction.dart';
import '../models/data_models/reply_message.dart';

extension TargetPlatformExtension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;

  bool get isIOS => this == TargetPlatform.iOS;

  // TODO(YASH): As audio_waveforms(https://pub.dev/packages/audio_waveforms)
  //  only supports Android & iOS as of now.
  bool get isAudioWaveformsSupported => isIOS || isAndroid;
}

extension ReplyMessageExteension on ReplyMessage {
  bool get isEmpty =>
      messageId.isEmpty &&
      message.isEmpty &&
      replyTo.isEmpty &&
      replyBy.isEmpty;
}

extension ReactionExteension on Reaction {
  bool get isEmpty => reactions.isEmpty && reactedUserIds.isEmpty;
}

extension ListExtension<T> on List<T> {
  /// Extension method to convert a list to a map with customizable key-value pairs.
  /// * required: [getKey] to extract the key from each element of the list.
  ///
  /// (optional): [getValue] to determines the value associated with each element in the resulting map.
  /// If not provided, the elements themselves will be used as values.
  ///
  /// (optional): [where] return all elements that satisfy the predicate [where].
  /// Example:
  /// ```dart
  /// final numbers = <int>[1,2,3,4,5,6,7];
  /// result = numbers.toMap<int, int>(getKey: (e) => e, where: (x) => x > 5); // {6: 6, 7: 7}
  /// ```
  Map<K, V> toMap<K, V>({
    required K? Function(T element) getKey,
    V Function(T element)? getValue,
    bool Function(T element)? where,
  }) {
    assert(
      getValue == null && T is! V,
      'Ensure generic type of value of map is same as generic type of list',
    );

    final mapList = <K, V>{};

    for (final element in this) {
      if (element == null) continue;
      if (where != null && !where(element)) continue;
      final key = getKey(element);
      if (key == null) continue;
      mapList[key] = (getValue?.call(element) ?? element) as V;
    }
    return mapList;
  }
}
