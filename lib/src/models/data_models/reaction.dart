/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class Reaction {
  Reaction({required this.reactions, required this.reactedUserIds});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    final reactionsData = json['reactions'];
    final reactionsList =
        reactionsData is List<dynamic> ? reactionsData : <dynamic>[];

    final reactionsListLength = reactionsList.length;
    final reactions = <String>[
      for (var i = 0; i < reactionsListLength; i++)
        if (reactionsList[i]?.toString() case final reaction?) reaction,
    ];

    final reactedUserIdsData = json['reactedUserIds'];
    final reactedUserIdList =
        reactedUserIdsData is List<dynamic> ? reactedUserIdsData : <dynamic>[];

    final reactedUserIdListLength = reactedUserIdList.length;
    final reactedUserIds = <String>[
      for (var i = 0; i < reactedUserIdListLength; i++)
        if (reactedUserIdList[i]?.toString() case final reactedUserId?)
          reactedUserId,
    ];

    return Reaction(
      reactions: reactions,
      reactedUserIds: reactedUserIds,
    );
  }

  /// Provides list of reaction in single message.
  final List<String> reactions;

  /// Provides list of user who reacted on message.
  final List<String> reactedUserIds;

  Map<String, dynamic> toJson() => {
        'reactions': reactions,
        'reactedUserIds': reactedUserIds,
      };

  Reaction copyWith({
    List<String>? reactions,
    List<String>? reactedUserIds,
  }) {
    return Reaction(
      reactions: reactions ?? this.reactions,
      reactedUserIds: reactedUserIds ?? this.reactedUserIds,
    );
  }

  @override
  String toString() => '''Reaction(${toJson()})''';
}
