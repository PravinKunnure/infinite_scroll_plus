/// Infinite Scroll Plus
/// Flutter package providing lazy loading and infinite scroll
/// functionality for ListView and GridView.
///
/// Version: 0.0.5

library infinite_scroll_plus;

import 'package:flutter/material.dart';

/// Type definition for the item builder function.
typedef ItemWidgetBuilder = Widget Function(BuildContext context, int index);

/// --------------------
/// InfiniteScrollList
/// --------------------
/// A ListView that supports infinite scrolling and lazy loading.
class InfiniteScrollList extends StatefulWidget {
  final int itemCount;
  final ItemWidgetBuilder itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final ScrollController? controller;

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
    // Use provided controller or create a new one
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  /// Detects when the user scrolls near the bottom and triggers loading more items
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Handles the load more logic, prevents duplicate calls
  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;
    setState(() => _isLoading = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    // Dispose only if we created the controller
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
          // Display loading widget at the bottom
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
  final int itemCount;
  final ItemWidgetBuilder itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final ScrollController? controller;
  final SliverGridDelegate gridDelegate; // Customizable grid layout

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

  /// Detects when the user scrolls near the bottom and triggers loading more items
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Handles the load more logic, prevents duplicate calls
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
          // Display loading widget at the end
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
