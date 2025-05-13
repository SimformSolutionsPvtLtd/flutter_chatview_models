import 'dart:developer';

import 'package:chatview_utility/chatview_utility.dart';

void main() {
  // Create sample users
  const currentUser = ChatUser(
    id: '1',
    name: 'Flutter',
    profilePhoto: Constants.profileImage,
  );

  log(currentUser.toString(), name: 'ChatView Utility');

  const otherUsers = [
    ChatUser(
      id: '2',
      name: 'Simform',
      profilePhoto: Constants.profileImage,
    ),
  ];

  log(otherUsers.map((e) => e.toString()).toString(), name: 'ChatView Utility');

  // Create some initial messages
  final messages = [
    Message(
      id: '1',
      message: 'Hello!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      sentBy: '1',
      status: MessageStatus.delivered,
    ),
    Message(
      id: '2',
      message: 'Hi there!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
      sentBy: '2',
      status: MessageStatus.read,
    ),
  ];

  log(messages.map((e) => e.toString()).toString(), name: 'ChatView Utility');

  // Demonstrate reaction
  final reaction = Reaction(
    reactedUserIds: [currentUser.id],
    reactions: ['👍'],
  );

  log(reaction.toString(), name: 'ChatView Utility');

  // Demonstrate reply
  final replyMessage = Message(
    id: '4',
    message: 'I am good!',
    createdAt: DateTime.now(),
    sentBy: currentUser.id,
    status: MessageStatus.pending,
    replyMessage: ReplyMessage(
      message: 'How are you?',
      messageId: '3',
      messageType: MessageType.text,
      replyTo: 'other_user_1',
      replyBy: currentUser.id,
    ),
  );
  log(replyMessage.toString(), name: 'ChatView Utility');
}
