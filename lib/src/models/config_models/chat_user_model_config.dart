/// This class provides a structure for specifying custom JSON key mappings
/// for user properties, ensuring flexibility in parsing and serializing
/// different user data formats.
abstract interface class ChatUserModelConfigBase {
  /// The JSON key used for uniquely identifying a user.
  String? get idKey;

  /// The JSON key used for storing the user's display name.
  String? get nameKey;

  /// The JSON key used for the user's profile photo.
  String? get profilePhotoKey;
}
