import 'dart:async';

import 'package:flutter/material.dart';

import '../models/data_models/chat_view_list_item.dart';
import '../values/enumeration.dart';
import '../values/typedefs.dart';
import 'auto_animated_sliver_list_controller.dart';

base class ChatViewListController {
  ChatViewListController({
    required List<ChatViewListItem> initialChatList,
    required this.scrollController,
    bool sortEnable = true,
    ChatSorter? chatSorter,
  }) {
    _animatedListController = AutoAnimateSliverListController<ChatViewListItem>(
      items: initialChatList,
      keyExtractor: (item) => item.id,
    );

    chatListStream = _chatListStreamController.stream.map(
      (chatMap) {
        final chatList = chatMap.values.toList();
        if (sortEnable) {
          chatList.sort(
            chatSorter ?? ChatViewListSortBy.pinFirstByPinTime.sort,
          );
        }
        return chatList;
      },
    );

    final chatListLength = initialChatList.length;

    final chatsMap = {
      for (var i = 0; i < chatListLength; i++)
        if (initialChatList[i] case final chat) chat.id: chat,
    };

    chatListMap = chatsMap;

    // Adds the current chat map to the stream controller
    // after the first frame render.
    Future.delayed(
      Duration.zero,
      () => _chatListStreamController.add(chatListMap),
    );
  }

  late final AutoAnimateSliverListController<ChatViewListItem>
      _animatedListController;

  AutoAnimateSliverListController<ChatViewListItem>
      get animatedListController => _animatedListController;

  /// Stores and manages chat items by their unique IDs.
  /// A map is used for efficient lookup, update, and removal of chats
  /// by their unique id.
  Map<String, ChatViewListItem> chatListMap = {};
  Map<String, ChatViewListItem>? _searchResultMap;

  /// Provides scroll controller for chat list.
  ScrollController scrollController;

  /// Stream controller to manage the chat list stream.
  final StreamController<Map<String, ChatViewListItem>>
      _chatListStreamController =
      StreamController<Map<String, ChatViewListItem>>.broadcast();

  late final Stream<List<ChatViewListItem>> chatListStream;

  /// Adds a chat to the chat list.
  void addChat(ChatViewListItem chat) {
    if (_searchResultMap != null) {
      chatListMap[chat.id] = chat;
      return;
    }

    chatListMap[chat.id] = chat;
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
    _animatedListController.addItem(
      chat,
      isPinned: (item) => item.settings.pinStatus.isPinned,
    );
  }

  void removeChat(String chatId) {
    chatListMap.remove(chatId);

    if (_searchResultMap != null) {
      if (_searchResultMap?.containsKey(chatId) ?? false) {
        _searchResultMap?.remove(chatId);
        if (_chatListStreamController.isClosed) return;
        _animatedListController.removeItem(chatId);
        _chatListStreamController.add(_searchResultMap ?? chatListMap);
      }
      return;
    }
    if (_chatListStreamController.isClosed) return;
    _animatedListController.removeItem(chatId);
    _chatListStreamController.add(chatListMap);
  }

  /// Function for loading data while pagination.
  void loadMoreChats(List<ChatViewListItem> chatList) {
    final chatListLength = chatList.length;
    chatListMap.addAll(
      {
        for (var i = 0; i < chatListLength; i++)
          if (chatList[i] case final chat) chat.id: chat,
      },
    );
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Updates the chat entry in [chatListMap] for the given [chatId] using
  /// the provided [newChat] callback.
  ///
  /// If the chat with [chatId] does not exist, the method returns without
  /// making changes.
  void updateChat(String chatId, UpdateChatCallback newChat) {
    if (_searchResultMap != null) {
      final searchChat = _searchResultMap?[chatId];
      if (searchChat == null) {
        final chat = chatListMap[chatId];
        if (chat == null) return;
        chatListMap[chatId] = newChat(chat);
        return;
      }

      final updatedChat = newChat(searchChat);
      _searchResultMap?[chatId] = updatedChat;
      chatListMap[chatId] = updatedChat;
      if (_chatListStreamController.isClosed) return;
      _chatListStreamController.add(_searchResultMap ?? chatListMap);
      return;
    }

    final chat = chatListMap[chatId];
    if (chat == null) return;

    chatListMap[chatId] = newChat(chat);
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Adds the given chat search results to the stream after the current frame.
  void setSearchChats(List<ChatViewListItem> searchResults) {
    final searchResultLength = searchResults.length;
    _searchResultMap = {
      for (var i = 0; i < searchResultLength; i++)
        if (searchResults[i] case final chat) chat.id: chat,
    };
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(_searchResultMap ?? chatListMap);
  }

  /// Function to clear the search results and show the original chat list.
  void clearSearch() {
    _searchResultMap?.clear();
    _searchResultMap = null;
    if (_chatListStreamController.isClosed) return;
    _chatListStreamController.add(chatListMap);
  }

  /// Used to dispose ValueNotifiers and Streams.
  void dispose() {
    scrollController.dispose();
    _chatListStreamController.close();
  }
}
