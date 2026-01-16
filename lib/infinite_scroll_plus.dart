library;

import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

typedef ErrorWidgetBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// ===========================================================================
/// LOAD MORE REQUEST (API CONTROL)
/// ===========================================================================
class LoadMoreRequest {
  final int page;
  final int currentItemCount;
  final Object? cursor;

  const LoadMoreRequest({
    required this.page,
    required this.currentItemCount,
    this.cursor,
  });
}

/// ===========================================================================
/// INTERNAL STATUS
/// ===========================================================================
enum InfiniteScrollStatus { idle, loading, error }

/// ===========================================================================
/// DEFAULT SKELETONS (Internal)
/// ===========================================================================
class _DefaultListSkeleton extends StatelessWidget {
  const _DefaultListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _DefaultGridSkeleton extends StatelessWidget {
  const _DefaultGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// InfiniteScrollList
/// ===========================================================================
class InfiniteScrollList<T> extends StatefulWidget {
  final List<T> items;
  final ItemWidgetBuilder<T> itemBuilder;

  final Future<void> Function(LoadMoreRequest request) onLoadMore;
  final bool hasMore;

  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? skeletonWidget;
  final ErrorWidgetBuilder? errorBuilder;

  final bool enableSkeletonLoader;

  final ScrollController? controller;
  final ScrollPhysics? physics;

  // Search
  final String? searchQuery;
  final List<T> Function(List<T> items, String query)? onSearch;

  // Sort
  final bool applySort;
  final List<T> Function(List<T> items)? onSort;

  final double loadMoreOffset;

  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.emptyWidget,
    this.skeletonWidget,
    this.errorBuilder,
    this.enableSkeletonLoader = false,
    this.controller,
    this.physics,
    this.searchQuery,
    this.onSearch,
    this.applySort = false,
    this.onSort,
    this.loadMoreOffset = 200,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  late final ScrollController _controller;

  InfiniteScrollStatus _status = InfiniteScrollStatus.idle;
  Object? _error;

  int _page = 1;
  Object? _cursor;
  double _lastMaxExtent = 0;

  List<T> get _processedItems {
    var list = List<T>.from(widget.items);

    if (widget.searchQuery?.isNotEmpty == true && widget.onSearch != null) {
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

  @override
  void didUpdateWidget(covariant InfiniteScrollList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _lastMaxExtent = 0;
    }
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final pos = _controller.position;

    if (pos.maxScrollExtent == _lastMaxExtent) return;

    if (pos.pixels >= pos.maxScrollExtent - widget.loadMoreOffset) {
      _lastMaxExtent = pos.maxScrollExtent;
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_status == InfiniteScrollStatus.loading || !widget.hasMore) return;

    setState(() {
      _status = InfiniteScrollStatus.loading;
      _error = null;
    });

    try {
      await widget.onLoadMore(
        LoadMoreRequest(
          page: _page,
          currentItemCount: widget.items.length,
          cursor: _cursor,
        ),
      );

      _page++;

      if (mounted) {
        setState(() => _status = InfiniteScrollStatus.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = InfiniteScrollStatus.error;
          _error = e;
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _processedItems;

    final showLoader =
        _status == InfiniteScrollStatus.loading && widget.hasMore;
    final showError = _status == InfiniteScrollStatus.error;

    if (widget.enableSkeletonLoader &&
        widget.items.isEmpty &&
        _status == InfiniteScrollStatus.loading &&
        widget.hasMore) {
      return widget.skeletonWidget ?? const _DefaultListSkeleton();
    }

    if (items.isEmpty && _status == InfiniteScrollStatus.idle) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return ListView.builder(
      controller: _controller,
      physics: widget.physics,
      itemCount: items.length + (showLoader || showError ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(context, items[index], index);
        }

        if (showError) {
          return widget.errorBuilder?.call(context, _error!, _loadMore) ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Failed to load more items'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadMore,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
        }

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
/// InfiniteScrollGrid (same behavior, grid layout)
/// ===========================================================================
class InfiniteScrollGrid<T> extends InfiniteScrollList<T> {
  final SliverGridDelegate gridDelegate;

  const InfiniteScrollGrid({
    super.key,
    required super.items,
    required super.itemBuilder,
    required super.onLoadMore,
    required this.gridDelegate,
    super.hasMore,
    super.loadingWidget,
    super.emptyWidget,
    super.skeletonWidget,
    super.errorBuilder,
    super.enableSkeletonLoader,
    super.controller,
    super.physics,
    super.searchQuery,
    super.onSearch,
    super.applySort,
    super.onSort,
    super.loadMoreOffset,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollGridState<T>();
}

class _InfiniteScrollGridState<T> extends _InfiniteScrollListState<T> {
  @override
  Widget build(BuildContext context) {
    final widget = this.widget as InfiniteScrollGrid<T>;
    final items = _processedItems;

    final showLoader =
        _status == InfiniteScrollStatus.loading && widget.hasMore;
    final showError = _status == InfiniteScrollStatus.error;

    if (widget.enableSkeletonLoader &&
        widget.items.isEmpty &&
        _status == InfiniteScrollStatus.loading &&
        widget.hasMore) {
      return widget.skeletonWidget ?? const _DefaultGridSkeleton();
    }

    if (items.isEmpty && _status == InfiniteScrollStatus.idle) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return GridView.builder(
      controller: _controller,
      physics: widget.physics,
      gridDelegate: widget.gridDelegate,
      itemCount: items.length + (showLoader || showError ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(context, items[index], index);
        }

        if (showError) {
          return widget.errorBuilder?.call(context, _error!, _loadMore) ??
              const Center(child: Text('Error loading more items'));
        }

        return widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// import 'package:flutter/material.dart';
//
// typedef ItemWidgetBuilder<T> =
//     Widget Function(BuildContext context, T item, int index);
//
// /// ===========================================================================
// /// DEFAULT SKELETONS (Internal)
// /// ===========================================================================
//
// class _DefaultListSkeleton extends StatelessWidget {
//   const _DefaultListSkeleton();
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 6,
//       itemBuilder: (_, __) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Container(
//           height: 64,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _DefaultGridSkeleton extends StatelessWidget {
//   const _DefaultGridSkeleton();
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 6,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemBuilder: (_, __) => Container(
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }
// }
//
// /// ===========================================================================
// /// InfiniteScrollList
// /// ===========================================================================
// class InfiniteScrollList<T> extends StatefulWidget {
//   final List<T> items;
//   final ItemWidgetBuilder<T> itemBuilder;
//   final Future<void> Function() onLoadMore;
//   final bool hasMore;
//
//   final Widget? loadingWidget;
//   final Widget? emptyWidget;
//   final Widget? skeletonWidget;
//   final bool enableSkeletonLoader;
//
//   final ScrollController? controller;
//   final ScrollPhysics? physics;
//
//   // Search
//   final String? searchQuery;
//   final List<T> Function(List<T> items, String query)? onSearch;
//
//   // Sort
//   final bool applySort;
//   final List<T> Function(List<T> items)? onSort;
//
//   final double loadMoreOffset;
//
//   const InfiniteScrollList({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.emptyWidget,
//     this.skeletonWidget,
//     this.enableSkeletonLoader = false,
//     this.controller,
//     this.physics,
//     this.searchQuery,
//     this.onSearch,
//     this.applySort = false,
//     this.onSort,
//     this.loadMoreOffset = 200,
//   });
//
//   @override
//   State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
// }
//
// class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
//   late final ScrollController _controller;
//   bool _isLoading = false;
//   double _lastMaxExtent = 0;
//
//   List<T> get _processedItems {
//     var list = List<T>.from(widget.items);
//
//     if (widget.searchQuery?.isNotEmpty == true && widget.onSearch != null) {
//       list = widget.onSearch!(list, widget.searchQuery!);
//     }
//
//     if (widget.applySort && widget.onSort != null) {
//       list = widget.onSort!(list);
//     }
//
//     return list;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? ScrollController();
//     _controller.addListener(_onScroll);
//   }
//
//   @override
//   void didUpdateWidget(covariant InfiniteScrollList<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.items.length != widget.items.length) {
//       _lastMaxExtent = 0;
//     }
//   }
//
//   void _onScroll() {
//     if (!_controller.hasClients) return;
//
//     final pos = _controller.position;
//
//     if (pos.maxScrollExtent == _lastMaxExtent) return;
//
//     if (pos.pixels >= pos.maxScrollExtent - widget.loadMoreOffset) {
//       _lastMaxExtent = pos.maxScrollExtent;
//       _loadMore();
//     }
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       await widget.onLoadMore();
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = _processedItems;
//     final showLoader = _isLoading && widget.hasMore;
//
//     if (widget.enableSkeletonLoader &&
//         widget.items.isEmpty &&
//         _isLoading &&
//         widget.hasMore) {
//       return widget.skeletonWidget ?? const _DefaultListSkeleton();
//     }
//
//     if (items.isEmpty && !_isLoading) {
//       return widget.emptyWidget ?? const Center(child: Text('No items found'));
//     }
//
//     return ListView.builder(
//       controller: _controller,
//       physics: widget.physics,
//       itemCount: items.length + (showLoader ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < items.length) {
//           return widget.itemBuilder(context, items[index], index);
//         }
//
//         return widget.loadingWidget ??
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(child: CircularProgressIndicator()),
//             );
//       },
//     );
//   }
// }
//
// /// ===========================================================================
// /// InfiniteScrollGrid
// /// ===========================================================================
// class InfiniteScrollGrid<T> extends StatefulWidget {
//   final List<T> items;
//   final ItemWidgetBuilder<T> itemBuilder;
//   final SliverGridDelegate gridDelegate;
//   final Future<void> Function() onLoadMore;
//   final bool hasMore;
//
//   final Widget? loadingWidget;
//   final Widget? emptyWidget;
//   final Widget? skeletonWidget;
//   final bool enableSkeletonLoader;
//
//   final ScrollController? controller;
//   final ScrollPhysics? physics;
//
//   final String? searchQuery;
//   final List<T> Function(List<T> items, String query)? onSearch;
//
//   final bool applySort;
//   final List<T> Function(List<T> items)? onSort;
//
//   final double loadMoreOffset;
//
//   const InfiniteScrollGrid({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.gridDelegate,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.emptyWidget,
//     this.skeletonWidget,
//     this.enableSkeletonLoader = false,
//     this.controller,
//     this.physics,
//     this.searchQuery,
//     this.onSearch,
//     this.applySort = false,
//     this.onSort,
//     this.loadMoreOffset = 200,
//   });
//
//   @override
//   State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
// }
//
// class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
//   late final ScrollController _controller;
//   bool _isLoading = false;
//   double _lastMaxExtent = 0;
//
//   List<T> get _processedItems {
//     var list = List<T>.from(widget.items);
//
//     if (widget.searchQuery?.isNotEmpty == true && widget.onSearch != null) {
//       list = widget.onSearch!(list, widget.searchQuery!);
//     }
//
//     if (widget.applySort && widget.onSort != null) {
//       list = widget.onSort!(list);
//     }
//
//     return list;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? ScrollController();
//     _controller.addListener(_onScroll);
//   }
//
//   @override
//   void didUpdateWidget(covariant InfiniteScrollGrid<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.items.length != widget.items.length) {
//       _lastMaxExtent = 0;
//     }
//   }
//
//   void _onScroll() {
//     if (!_controller.hasClients) return;
//
//     final pos = _controller.position;
//
//     if (pos.maxScrollExtent == _lastMaxExtent) return;
//
//     if (pos.pixels >= pos.maxScrollExtent - widget.loadMoreOffset) {
//       _lastMaxExtent = pos.maxScrollExtent;
//       _loadMore();
//     }
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       await widget.onLoadMore();
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = _processedItems;
//     final showLoader = _isLoading && widget.hasMore;
//
//     if (widget.enableSkeletonLoader &&
//         widget.items.isEmpty &&
//         _isLoading &&
//         widget.hasMore) {
//       return widget.skeletonWidget ?? const _DefaultGridSkeleton();
//     }
//
//     if (items.isEmpty && !_isLoading) {
//       return widget.emptyWidget ?? const Center(child: Text('No items found'));
//     }
//
//     return GridView.builder(
//       controller: _controller,
//       physics: widget.physics,
//       gridDelegate: widget.gridDelegate,
//       itemCount: items.length + (showLoader ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < items.length) {
//           return widget.itemBuilder(context, items[index], index);
//         }
//
//         return widget.loadingWidget ??
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(child: CircularProgressIndicator()),
//             );
//       },
//     );
//   }
// }

///OldVersion
// // ================================================================
// // Infinite Scroll Plus
// // Flutter package: Lazy loading + Infinite scroll for List & Grid
// // Version: 0.1.0 (Improved with Local Search + Sort)
// // ================================================================
//
// import 'package:flutter/material.dart';
//
// /// Function signature for building widgets using a model item.
// typedef ItemWidgetBuilder<T> =
//     Widget Function(BuildContext context, T item, int index);
//
// /// ===========================================================================
// /// InfiniteScrollList
// /// A paginated ListView with optional local sorting and searching.
// /// ===========================================================================
// class InfiniteScrollList<T> extends StatefulWidget {
//   /// The list of all items currently loaded (provided by the user).
//   ///
//   /// 🔥 IMPORTANT:
//   /// Pagination loads new items → you append them to this list → pass it back.
//   final List<T> items;
//
//   /// Builds each list tile widget.
//   final ItemWidgetBuilder<T> itemBuilder;
//
//   /// Triggered when the user scrolls near the bottom.
//   final Future<void> Function() onLoadMore;
//
//   /// Whether there are more items available from the API.
//   final bool hasMore;
//
//   /// Optional loader widget.
//   final Widget? loadingWidget;
//
//   /// Optional scroll controller.
//   final ScrollController? controller;
//
//   // ------------------------ SEARCH OPTIONS ------------------------
//
//   /// Optional search query. If null or empty → search disabled.
//   final String? searchQuery;
//
//   /// Function applied to filter the existing items.
//   /// Example: (items, q) => items.where((e) => e.name.contains(q)).toList()
//   final List<T> Function(List<T> items, String query)? onSearch;
//
//   // ------------------------ SORT OPTIONS --------------------------
//
//   /// Whether sorting is enabled.
//   final bool applySort;
//
//   /// Sort function applied locally (on existing items).
//   final List<T> Function(List<T> items)? onSort;
//
//   const InfiniteScrollList({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.controller,
//     this.searchQuery,
//     this.onSearch,
//     this.applySort = false,
//     this.onSort,
//   });
//
//   @override
//   State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
// }
//
// class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
//   late final ScrollController _controller;
//   bool _isLoading = false;
//
//   /// Applies search and sorting to the items.
//   List<T> get _processedItems {
//     List<T> list = List.from(widget.items);
//
//     // ---------- Apply Search ----------
//     if (widget.searchQuery != null &&
//         widget.searchQuery!.isNotEmpty &&
//         widget.onSearch != null) {
//       list = widget.onSearch!(list, widget.searchQuery!);
//     }
//
//     // ---------- Apply Sort ----------
//     if (widget.applySort && widget.onSort != null) {
//       list = widget.onSort!(list);
//     }
//
//     return list;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Create our own controller only if the user didn't provide one
//     _controller = widget.controller ?? ScrollController();
//     _controller.addListener(_onScroll);
//   }
//
//   /// Detects if the user has scrolled close to the end.
//   bool get _nearBottom {
//     final pos = _controller.position;
//     return pos.pixels >= pos.maxScrollExtent - 200;
//   }
//
//   void _onScroll() {
//     if (_nearBottom) _loadMore();
//   }
//
//   /// Loads more data (only if not already loading).
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//
//     setState(() => _isLoading = true);
//
//     await widget.onLoadMore();
//
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }
//
//   /// Builds the ListView with loader footer.
//   @override
//   Widget build(BuildContext context) {
//     final items = _processedItems;
//     final showLoader = widget.hasMore;
//
//     return ListView.builder(
//       controller: _controller,
//       itemCount: items.length + (showLoader ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < items.length) {
//           return widget.itemBuilder(context, items[index], index);
//         }
//
//         // Loading Footer
//         return widget.loadingWidget ??
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(child: CircularProgressIndicator()),
//             );
//       },
//     );
//   }
// }
//
// /// ===========================================================================
// /// InfiniteScrollGrid
// /// A paginated GridView with optional local sorting and searching.
// /// ===========================================================================
// class InfiniteScrollGrid<T> extends StatefulWidget {
//   /// All loaded items.
//   final List<T> items;
//
//   /// Builds each grid tile.
//   final ItemWidgetBuilder<T> itemBuilder;
//
//   /// Grid layout (required).
//   final SliverGridDelegate gridDelegate;
//
//   /// Called when more items must be fetched.
//   final Future<void> Function() onLoadMore;
//
//   /// Whether more items exist on the server.
//   final bool hasMore;
//
//   /// Loader widget at the end.
//   final Widget? loadingWidget;
//
//   /// Optional scroll controller.
//   final ScrollController? controller;
//
//   // ---------------- Search Options ----------------
//
//   final String? searchQuery;
//   final List<T> Function(List<T> items, String query)? onSearch;
//
//   // ---------------- Sort Options ------------------
//
//   final bool applySort;
//   final List<T> Function(List<T> items)? onSort;
//
//   const InfiniteScrollGrid({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.gridDelegate,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.controller,
//     this.searchQuery,
//     this.onSearch,
//     this.applySort = false,
//     this.onSort,
//   });
//
//   @override
//   State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
// }
//
// class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
//   late final ScrollController _controller;
//   bool _isLoading = false;
//
//   /// List after search and sort.
//   List<T> get _processedItems {
//     List<T> list = List.from(widget.items);
//
//     if (widget.searchQuery != null &&
//         widget.searchQuery!.isNotEmpty &&
//         widget.onSearch != null) {
//       list = widget.onSearch!(list, widget.searchQuery!);
//     }
//
//     if (widget.applySort && widget.onSort != null) {
//       list = widget.onSort!(list);
//     }
//
//     return list;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? ScrollController();
//     _controller.addListener(_onScroll);
//   }
//
//   bool get _nearBottom {
//     final pos = _controller.position;
//     return pos.pixels >= pos.maxScrollExtent - 200;
//   }
//
//   void _onScroll() {
//     if (_nearBottom) _loadMore();
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//
//     setState(() => _isLoading = true);
//     await widget.onLoadMore();
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = _processedItems;
//     final includeLoader = widget.hasMore;
//
//     return GridView.builder(
//       controller: _controller,
//       gridDelegate: widget.gridDelegate,
//       itemCount: items.length + (includeLoader ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < items.length) {
//           return widget.itemBuilder(context, items[index], index);
//         }
//
//         // Loader tile (still inside the grid)
//         return widget.loadingWidget ??
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(child: CircularProgressIndicator()),
//             );
//       },
//     );
//   }
// }
