import 'package:flutter/widgets.dart';

import '../models/data_models/cache_network_image_download_progress.dart';
import '../models/data_models/suggestion_item_data.dart';

typedef AssetImageErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

typedef NetworkImageErrorBuilder = Widget Function(
  BuildContext context,
  String url,
  Object error,
);

typedef NetworkImageProgressIndicatorBuilder = Widget Function(
  BuildContext context,
  String url,
  CacheNetworkImageDownloadProgress progress,
);

typedef SuggestionItemBuilder = Widget Function(
  int index,
  SuggestionItemData suggestionItemData,
);
