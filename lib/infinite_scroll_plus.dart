// ================================================================
// Infinite Scroll Plus
// Flutter package: Lazy loading + Infinite scroll for List & Grid
// Version: 0.1.0 (Improved with Local Search + Sort)
// ================================================================

import 'package:flutter/material.dart';

/// Function signature for building widgets using a model item.
typedef ItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// ===========================================================================
/// InfiniteScrollList
/// A paginated ListView with optional local sorting and searching.
/// ===========================================================================
class InfiniteScrollList<T> extends StatefulWidget {
  /// The list of all items currently loaded (provided by the user).
  ///
  /// 🔥 IMPORTANT:
  /// Pagination loads new items → you append them to this list → pass it back.
  final List<T> items;

  /// Builds each list tile widget.
  final ItemWidgetBuilder<T> itemBuilder;

  /// Triggered when the user scrolls near the bottom.
  final Future<void> Function() onLoadMore;

  /// Whether there are more items available from the API.
  final bool hasMore;

  /// Optional loader widget.
  final Widget? loadingWidget;

  /// Optional scroll controller.
  final ScrollController? controller;

  // ------------------------ SEARCH OPTIONS ------------------------

  /// Optional search query. If null or empty → search disabled.
  final String? searchQuery;

  /// Function applied to filter the existing items.
  /// Example: (items, q) => items.where((e) => e.name.contains(q)).toList()
  final List<T> Function(List<T> items, String query)? onSearch;

  // ------------------------ SORT OPTIONS --------------------------

  /// Whether sorting is enabled.
  final bool applySort;

  /// Sort function applied locally (on existing items).
  final List<T> Function(List<T> items)? onSort;

  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.controller,
    this.searchQuery,
    this.onSearch,
    this.applySort = false,
    this.onSort,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  late final ScrollController _controller;
  bool _isLoading = false;

  /// Applies search and sorting to the items.
  List<T> get _processedItems {
    List<T> list = List.from(widget.items);

    // ---------- Apply Search ----------
    if (widget.searchQuery != null &&
        widget.searchQuery!.isNotEmpty &&
        widget.onSearch != null) {
      list = widget.onSearch!(list, widget.searchQuery!);
    }

    // ---------- Apply Sort ----------
    if (widget.applySort && widget.onSort != null) {
      list = widget.onSort!(list);
    }

    return list;
  }

  @override
  void initState() {
    super.initState();

    // Create our own controller only if the user didn't provide one
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  /// Detects if the user has scrolled close to the end.
  bool get _nearBottom {
    final pos = _controller.position;
    return pos.pixels >= pos.maxScrollExtent - 200;
  }

  void _onScroll() {
    if (_nearBottom) _loadMore();
  }

  /// Loads more data (only if not already loading).
  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;

    setState(() => _isLoading = true);

    await widget.onLoadMore();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Builds the ListView with loader footer.
  @override
  Widget build(BuildContext context) {
    final items = _processedItems;
    final showLoader = widget.hasMore;

    return ListView.builder(
      controller: _controller,
      itemCount: items.length + (showLoader ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(context, items[index], index);
        }

        // Loading Footer
        return widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}

/// ===========================================================================
/// InfiniteScrollGrid
/// A paginated GridView with optional local sorting and searching.
/// ===========================================================================
class InfiniteScrollGrid<T> extends StatefulWidget {
  /// All loaded items.
  final List<T> items;

  /// Builds each grid tile.
  final ItemWidgetBuilder<T> itemBuilder;

  /// Grid layout (required).
  final SliverGridDelegate gridDelegate;

  /// Called when more items must be fetched.
  final Future<void> Function() onLoadMore;

  /// Whether more items exist on the server.
  final bool hasMore;

  /// Loader widget at the end.
  final Widget? loadingWidget;

  /// Optional scroll controller.
  final ScrollController? controller;

  // ---------------- Search Options ----------------

  final String? searchQuery;
  final List<T> Function(List<T> items, String query)? onSearch;

  // ---------------- Sort Options ------------------

  final bool applySort;
  final List<T> Function(List<T> items)? onSort;

  const InfiniteScrollGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.controller,
    this.searchQuery,
    this.onSearch,
    this.applySort = false,
    this.onSort,
  });

  @override
  State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
}

class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
  late final ScrollController _controller;
  bool _isLoading = false;

  /// List after search and sort.
  List<T> get _processedItems {
    List<T> list = List.from(widget.items);

    if (widget.searchQuery != null &&
        widget.searchQuery!.isNotEmpty &&
        widget.onSearch != null) {
      list = widget.onSearch!(list, widget.searchQuery!);
    }

    if (widget.applySort && widget.onSort != null) {
      list = widget.onSort!(list);
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  bool get _nearBottom {
    final pos = _controller.position;
    return pos.pixels >= pos.maxScrollExtent - 200;
  }

  void _onScroll() {
    if (_nearBottom) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore) return;

    setState(() => _isLoading = true);
    await widget.onLoadMore();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _processedItems;
    final includeLoader = widget.hasMore;

    return GridView.builder(
      controller: _controller,
      gridDelegate: widget.gridDelegate,
      itemCount: items.length + (includeLoader ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(context, items[index], index);
        }

        // Loader tile (still inside the grid)
        return widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}
