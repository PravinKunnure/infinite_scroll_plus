// Infinite Scroll Plus
// Flutter package providing lazy loading and infinite scroll
// functionality for ListView and GridView.
//
// Version: 0.0.7

import 'package:flutter/material.dart';

/// Type definition for the item builder function.
typedef ItemWidgetBuilder = Widget Function(BuildContext context, int index);

/// --------------------
/// InfiniteScrollList
/// --------------------
/// A ListView that supports infinite scrolling and lazy loading.
class InfiniteScrollList extends StatefulWidget {
  /// Number of items currently loaded in the list.
  final int itemCount;

  /// Builds the widget for each item.
  final ItemWidgetBuilder itemBuilder;

  /// Callback triggered when more items need to be loaded.
  final Future<void> Function() onLoadMore;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Widget to display at the bottom while loading.
  final Widget? loadingWidget;

  /// Optional scroll controller. If null, a controller is created internally.
  final ScrollController? controller;

  /// Creates an [InfiniteScrollList].
  const InfiniteScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.controller,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  late final ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  /// Detects when the user scrolls near the bottom and triggers loading more items.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Handles the load more logic and prevents duplicate calls.
  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;
    setState(() => _isLoading = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        } else {
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }
      },
    );
  }
}

/// --------------------
/// InfiniteScrollGrid
/// --------------------
/// A GridView that supports infinite scrolling and lazy loading.
class InfiniteScrollGrid extends StatefulWidget {
  /// Number of items currently loaded in the grid.
  final int itemCount;

  /// Builds the widget for each grid item.
  final ItemWidgetBuilder itemBuilder;

  /// Callback triggered when more items need to be loaded.
  final Future<void> Function() onLoadMore;

  /// Layout configuration for the grid.
  final SliverGridDelegate gridDelegate;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Widget to display at the end while loading.
  final Widget? loadingWidget;

  /// Optional scroll controller. If null, a controller is created internally.
  final ScrollController? controller;

  /// Creates an [InfiniteScrollGrid].
  const InfiniteScrollGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.gridDelegate,
    this.hasMore = true,
    this.loadingWidget,
    this.controller,
  });

  @override
  State<InfiniteScrollGrid> createState() => _InfiniteScrollGridState();
}

class _InfiniteScrollGridState extends State<InfiniteScrollGrid> {
  late final ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  /// Detects when the user scrolls near the end and triggers loading more items.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Handles the load more logic and prevents duplicate calls.
  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;
    setState(() => _isLoading = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        } else {
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }
      },
    );
  }
}
