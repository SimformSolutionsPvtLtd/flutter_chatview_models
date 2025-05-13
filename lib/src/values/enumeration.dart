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

/// {@template chatview_utility.enumeration.MessageType}
/// Defines the various message types in ChatView.
/// - [image]: An image message.
/// - [text]: A text message.
/// - [voice]: A voice message (Android & iOS only).
/// - [custom]: A custom message type.
/// {@endtemplate}
enum MessageType {
  image,
  text,

  /// Only supported on android and ios
  voice,
  custom;

  bool get isImage => this == image;

  bool get isText => this == text;

  bool get isVoice => this == voice;

  bool get isCustom => this == custom;

  static MessageType? tryParse(String? value) {
    final type = value?.trim().toLowerCase();
    if (type?.isEmpty ?? true) return null;
    if (type == image.name.toLowerCase()) {
      return image;
    } else if (type == text.name.toLowerCase()) {
      return text;
    } else if (type == voice.name.toLowerCase()) {
      return voice;
    } else if (type == custom.name.toLowerCase()) {
      return custom;
    }
    return null;
  }
}

/// {@template chatview_utility.enumeration.TypeWriterStatus}
/// Indicates whether the user is currently typing or has finished typing.
/// - [typing]: User is still typing.
/// - [typed]: User has completed typing.
/// {@endtemplate}
enum TypeWriterStatus {
  typing,
  typed;

  bool get isTyping => this == typing;

  bool get isTyped => this == typed;
}

/// {@template chatview_utility.enumeration.MessageStatus}
/// Represents the current state of a message from sending to delivery.
/// - [read]: Opened by the recipient.
/// - [delivered]: Successfully delivered.
/// - [undelivered]: Failed to deliver.
/// - [pending]: Message is being sent.
/// {@endtemplate}
enum MessageStatus {
  read,
  delivered,
  undelivered,
  pending;

  bool get isRead => this == read;

  bool get isDelivered => this == delivered;

  bool get isUndelivered => this == undelivered;

  bool get isPending => this == pending;

  static MessageStatus? tryParse(String? value) {
    final status = value?.trim().toLowerCase();
    if (status?.isEmpty ?? true) return null;
    if (status == read.name.toLowerCase()) {
      return read;
    } else if (status == delivered.name.toLowerCase()) {
      return delivered;
    } else if (status == undelivered.name.toLowerCase()) {
      return undelivered;
    } else if (status == pending.name.toLowerCase()) {
      return pending;
    }
    return null;
  }
}

/// {@template chatview_utility.enumeration.ImageType}
/// Defines the different types of image sources.
/// - [asset]: Image from local assets.
/// - [network]: Image from a network URL.
/// - [base64]: Image encoded in base64 format.
/// {@endtemplate}
enum ImageType {
  asset,
  network,
  base64;

  bool get isNetwork => this == network;

  bool get isAsset => this == asset;

  bool get isBase64 => this == base64;

  static ImageType? tryParse(String? value) {
    final type = value?.trim().toLowerCase();
    if (type?.isEmpty ?? true) return null;
    if (type == asset.name.toLowerCase()) {
      return asset;
    } else if (type == network.name.toLowerCase()) {
      return network;
    } else if (type == base64.name.toLowerCase()) {
      return base64;
    }
    return null;
  }
}

/// {@template chatview_utility.enumeration.ChatViewState}
/// Represents the different states of the chat view.
/// - [hasMessages]: Chat has messages to display.
/// - [noData]: No messages available.
/// - [loading]: Messages are being loaded.
/// - [error]: An error occurred while loading messages.
/// {@endtemplate}
enum ChatViewState {
  hasMessages,
  noData,
  loading,
  error;

  bool get isHasMessages => this == hasMessages;

  bool get isNoData => this == noData;

  bool get isLoading => this == loading;

  bool get isError => this == error;
}
