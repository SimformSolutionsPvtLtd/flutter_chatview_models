import 'dart:async';

import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../values/typedefs.dart';

class ItemState<T> {
  ItemState({
    required this.moveController,
    required this.item,
    required this.currentIndex,
    this.isMoving = false,
    this.isRemoving = false,
  });

  final AnimationController moveController;
  T item;
  int currentIndex;
  double? moveOffset;
  bool isMoving;
  bool isRemoving;
}

class AutoAnimateSliverListController<T> {
  AutoAnimateSliverListController({
    required List<T> items,
    required AutoAnimateItemExtractor<T> keyExtractor,
    Duration animationDuration = const Duration(milliseconds: 400),
    bool enableMoveAnimation = true,
  })  : _enableMoveAnimation = enableMoveAnimation,
        _items = items,
        _keyExtractor = keyExtractor,
        _animationDuration = animationDuration;

  final AutoAnimateItemExtractor<T> _keyExtractor;
  final Duration _animationDuration;
  final bool _enableMoveAnimation;

  final Map<String, GlobalKey> _itemKeys = {};
  late List<T> _currentItems = _currentItems = List.from(_items);
  List<T> _items = [];
  final Map<String, ItemState<T>> _itemStates = {};
  bool _isNewItemAddedAtTop = false;
  double _newItemHeight = 0;
  final Set<String> _removingItems = {};
  bool _isAddingItem = false;
  bool _isRemovingItem = false;

  List<T> get items => items;

  String getItemKey(T item) => _keyExtractor(item);

  GlobalKey? getItemGlobalKey(String key) => _itemKeys[key];

  ItemState<T>? getState(String key) => _itemStates[key];

  List<T> get currentItems => _currentItems;

  bool get isAddedAtTop => _isNewItemAddedAtTop;

  double get itemHeight => _newItemHeight;

  final StreamController<void> _updateController =
      StreamController<void>.broadcast();

  Stream<void> get updateStream => _updateController.stream;

  TickerProvider? _tickerProvider;

  /// Adds a new chat item, considering pinned items at the top
  /// If there are pinned items, the new item will be added after
  /// them without animation If no pinned items, it will be added
  /// at top with animation
  void addItem(T newItem, {required bool Function(T item) isPinned}) {
    // Count pinned items at the top
    var pinnedCount = 0;

    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      if (isPinned(_currentItems[i])) {
        pinnedCount++;
      } else {
        // Stop at first non-pinned item
        break;
      }
    }

    // If there are pinned items, add after them without animation
    // If no pinned items, add at top with animation
    final shouldAnimate = pinnedCount == 0;
    _onAddItem(newItem, position: pinnedCount, shouldAnimate: shouldAnimate);
  }

  /// Adds a new item with animation at the specified
  /// position (typically at top)
  void _onAddItem(T newItem, {int position = 0, bool shouldAnimate = true}) {
    _isAddingItem = true;

    final newItems = List<T>.from(_currentItems)..insert(position, newItem);

    final key = _keyExtractor(newItem);

    // Only animate if adding at top AND shouldAnimate is true
    _isNewItemAddedAtTop = position == 0 && shouldAnimate;
    _newItemHeight = 0.0;

    // Only setup animation parameters if adding at top and should animate
    if (_isNewItemAddedAtTop && _currentItems.isNotEmpty) {
      // Estimate new item height based on existing items
      final firstOldKey = _keyExtractor(_currentItems[0]);
      final renderBox =
          _itemKeys[firstOldKey]?.currentContext?.findRenderObject();
      if (renderBox is RenderBox && renderBox.hasSize) {
        _newItemHeight = renderBox.size.height;
      } else {
        _newItemHeight = 80.0;
      }
    }

    // Update the list immediately so new item is rendered
    _currentItems = newItems;

    final provider = _tickerProvider;
    if (provider == null) return;

    // Create animation controller for new item
    final moveController = AnimationController(
      duration: _animationDuration,
      vsync: provider,
    );

    _itemStates[key] = ItemState<T>(
      moveController: moveController,
      item: newItem,
      currentIndex: position,
    );
    _itemKeys[key] = GlobalKey();

    // Update indices for existing items after the insertion point
    for (var i = position + 1; i < _currentItems.length; i++) {
      final itemKey = _keyExtractor(_currentItems[i]);
      final itemState = _itemStates[itemKey];
      if (itemState != null) {
        itemState.currentIndex = i;
      }
    }

    _updateController.add(null);

    // Only animate if new item is added at top and should animate
    if (_isNewItemAddedAtTop) {
      // Animate new item at top
      moveController
        ..value = 0
        ..forward();

      // Animate all existing items down when new item added at top
      for (var i = position + 1; i < _currentItems.length; i++) {
        final itemKey = _keyExtractor(_currentItems[i]);
        final itemState = _itemStates[itemKey];
        if (itemState != null) {
          itemState.moveController
            ..value = 0
            ..forward();
        }
      }
    } else {
      // No animation for items added at other positions or
      // when shouldAnimate is false
      moveController.value = 1;
    }

    // Reset the flag after a brief delay to allow any pending widget updates
    Future.microtask(() => _isAddingItem = false);
  }

  /// Removes an item by its key with animation
  void removeItem(String key, {bool shouldAnimate = true}) {
    final item = _currentItems.cast<T?>().firstWhereOrNull(
          (item) => item != null && _keyExtractor(item) == key,
        );
    if (item == null) return;

    _onRemoveItem(item, shouldAnimate: shouldAnimate);
  }

  /// Removes an item with a smooth animation
  /// The item will fade out, scale down, and slide up before being removed
  void _onRemoveItem(T item, {bool shouldAnimate = true}) {
    final key = _keyExtractor(item);
    final itemState = _itemStates[key];

    if (itemState == null) {
      // Item doesn't exist, nothing to remove
      return;
    }

    final itemIndex = _currentItems.indexWhere((i) => _keyExtractor(i) == key);
    if (itemIndex == -1) {
      return;
    }

    if (!shouldAnimate) {
      // Remove immediately without animation
      _currentItems.removeAt(itemIndex);
      final currentItemsLength = _currentItems.length;
      _cleanupRemovedItems(
        {
          for (var i = 0; i < currentItemsLength; i++)
            if (_currentItems[i] case final item) _keyExtractor(item),
        },
      );
      _updateController.add(null);
      return;
    }

    _isRemovingItem = true;
    _removingItems.add(key);

    // Mark item as removing
    itemState.isRemoving = true;

    // Start removal animation
    itemState.moveController.reset();
    itemState.moveController.forward().then((_) {
      // if (!mounted) return;

      // Remove the item from the list
      final newItems = List<T>.from(_currentItems)
        ..removeWhere((i) => _keyExtractor(i) == key);
      _currentItems = newItems;

      // Update indices for remaining items
      final currentItemsLength = _currentItems.length;
      for (var i = 0; i < currentItemsLength; i++) {
        final itemKey = _keyExtractor(_currentItems[i]);
        final state = _itemStates[itemKey];
        if (state != null) {
          state.currentIndex = i;
        }
      }

      // Cleanup the removed item
      _removingItems.remove(key);
      _itemStates[key]?.moveController.dispose();
      _itemStates.remove(key);
      _itemKeys.remove(key);

      // Reset the removing flag
      _isRemovingItem = _removingItems.isNotEmpty;

      _updateController.add(null);
    });

    _updateController.add(null);
  }

  void _animateItemMove(
    String key,
    ItemState<T> itemState,
    int oldIndex,
    int newIndex, {
    required double itemHeight,
    VoidCallback? onAnimationEnd,
  }) {
    // Calculate how many positions this item moved
    final positionDiff = newIndex - oldIndex;
    final moveOffset = positionDiff * itemHeight;

    itemState
      ..moveOffset = moveOffset
      ..isMoving = true;

    // Two-phase animation: first go on top, then come back behind
    itemState.moveController.reset();
    itemState.moveController.forward().then((_) {
      itemState
        ..isMoving = false
        ..moveOffset = null;
      onAnimationEnd?.call();
      _updateController.add(null);
    });
  }

  void changeItems({
    required TickerProvider tickerProvider,
    required List<T> updatedItems,
  }) {
    _items = updatedItems;
    this._tickerProvider = tickerProvider;
    if (_isAddingItem || _isRemovingItem) return;

    final newItems = List<T>.from(_items);
    final newItemKeys = <String>{};

    // Create maps for old and new positions
    final oldPositions = <String, int>{};
    final newPositions = <String, int>{};

    // Map current positions
    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final key = _keyExtractor(_currentItems[i]);
      oldPositions[key] = i;
    }

    // Map new positions
    var newItemsLength = newItems.length;
    for (var i = 0; i < newItemsLength; i++) {
      final key = _keyExtractor(newItems[i]);
      newItemKeys.add(key);
      newPositions[key] = i;
    }

    // Detect removed items
    final removedKeys =
        oldPositions.keys.where((key) => !newItemKeys.contains(key)).toList();
    if (removedKeys.isNotEmpty) {
      // If items are removed, update immediately without animating moves
      _currentItems = newItems;
      _cleanupRemovedItems(newItemKeys);
      _updateController.add(null);
      return;
    }

    // Capture current positions before any changes
    final renderBoxes = <String, RenderBox?>{};
    if (_enableMoveAnimation) {
      final entries = _itemKeys.entries.toList();
      final entriesLength = entries.length;
      for (var i = 0; i < entriesLength; i++) {
        final entry = entries[i];
        final renderObject = entry.value.currentContext?.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          renderBoxes[entry.key] = renderObject;
        }
      }
    }

    var needsReorder = false;

    // Process all items
    newItemsLength = newItems.length;
    for (var i = 0; i < newItemsLength; i++) {
      final key = _keyExtractor(newItems[i]);
      final oldIndex = oldPositions[key];
      final newIndex = i;

      if (_itemStates.containsKey(key)) {
        final itemState = _itemStates[key]!;
        // Only animate if item actually moved and
        // not just shifted due to insertion
        if (oldIndex != null &&
                oldIndex != newIndex &&
                _enableMoveAnimation &&
                oldPositions.length == newItemsLength // No new item inserted
            ) {
          needsReorder = true;

          // Calculate the offset this item needs to move
          final renderBox = renderBoxes[key];
          // Default fallback
          var itemHeight = 80.0;

          if (renderBox != null && renderBox.hasSize) {
            itemHeight = renderBox.size.height;
          }

          // This item moved - calculate the offset and animate only this item
          _animateItemMove(
            key,
            itemState,
            oldIndex,
            newIndex,
            itemHeight: itemHeight,
            onAnimationEnd: () {
              _currentItems = List.from(newItems);
              // Apply reorder
              _updateController.add(null);
            },
          );
        }

        itemState
          ..item = newItems[i]
          ..currentIndex = i;
      } else {
        // New item - only initialize if not already handled by addItem methods
        if (!_itemStates.containsKey(key)) {
          final moveController = AnimationController(
            value: 1,
            duration: _animationDuration,
            vsync: this._tickerProvider ?? tickerProvider,
          );

          _itemStates[key] = ItemState<T>(
            moveController: moveController,
            item: newItems[i],
            currentIndex: i,
          );
          _itemKeys[key] = GlobalKey();
        } else {
          // Item already exists (was added via addItem), just update its data
          _itemStates[key]!
            ..item = newItems[i]
            ..currentIndex = i;
        }
      }
    }

    // Clean up removed items
    _cleanupRemovedItems(newItemKeys);

    // If nothing moved, apply immediately
    if (!needsReorder) {
      _currentItems = newItems;
    }
  }

  void _cleanupRemovedItems(Set<String> newItemKeys) {
    final keysToRemove =
        _itemStates.keys.where((key) => !newItemKeys.contains(key)).toList();
    final keysToRemoveLength = keysToRemove.length;
    for (var i = 0; i < keysToRemoveLength; i++) {
      final key = keysToRemove[i];
      _itemStates[key]?.moveController.dispose();
      _itemStates.remove(key);
      _itemKeys.remove(key);
    }
  }

  void initialize({required TickerProvider tickerProvider}) {
    this._tickerProvider ??= tickerProvider;

    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final item = _currentItems[i];
      final key = _keyExtractor(item);
      if (_itemStates.containsKey(key)) continue;

      final moveController = AnimationController(
        value: 1,
        vsync: tickerProvider,
        duration: _animationDuration,
      );

      _itemStates[key] = ItemState<T>(
        item: item,
        currentIndex: i,
        moveController: moveController,
      );
      _itemKeys[key] = GlobalKey();
    }
  }

  void dispose() {
    final values = _itemStates.values.toList();
    final valuesLength = values.length;
    for (var i = 0; i < valuesLength; i++) {
      values[i].moveController.dispose();
    }
  }
}
