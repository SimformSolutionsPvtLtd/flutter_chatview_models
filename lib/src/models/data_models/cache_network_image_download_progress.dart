/// Progress of the file that is being downloaded from the [originalUrl].
class CacheNetworkImageDownloadProgress {
  const CacheNetworkImageDownloadProgress(
    this.originalUrl,
    this.totalSize,
    this.downloaded,
  );

  /// Url from which the file is coming.
  final String originalUrl;

  /// Final size of the download. If total size is unknown this will be null.
  final int? totalSize;

  /// Total of currently downloaded bytes.
  final int downloaded;

  /// download progress as an double between 0 and 1.
  /// When the final size is unknown or the downloaded size exceeds the total
  /// size [progress] is null.
  double? get progress {
    final totalSize = this.totalSize;
    if (totalSize == null || downloaded > totalSize) return null;
    return downloaded / totalSize;
  }
}
