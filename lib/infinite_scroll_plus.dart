library;

import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> =
Widget Function(BuildContext context, T item, int index);

typedef ErrorWidgetBuilder =
Widget Function(BuildContext context, Object error, VoidCallback retry);

/// ===========================================================================
/// LOAD MORE REQUEST
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
/// STATUS
/// ===========================================================================
enum InfiniteScrollStatus {
  idle,
  initialLoading,
  loadingMore,
  error,
}

/// ===========================================================================
/// DEFAULT LIST SKELETON
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

/// ===========================================================================
/// DEFAULT GRID SKELETON
/// ===========================================================================
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

  /// SEARCH
  final String? searchQuery;
  final List<T> Function(List<T> items, String query)? onSearch;

  /// SORT
  final bool applySort;
  final List<T> Function(List<T> items)? onSort;

  /// PAGINATION
  final double loadMoreOffset;
  final int initialPage;
  final Object? initialCursor;

  /// REFRESH
  final Future<void> Function()? onRefresh;

  /// LISTVIEW OPTIONS
  final bool shrinkWrap;
  final bool reverse;
  final EdgeInsetsGeometry? padding;

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
    this.initialPage = 1,
    this.initialCursor,
    this.onRefresh,
    this.shrinkWrap = false,
    this.reverse = false,
    this.padding,
  });

  @override
  State<InfiniteScrollList<T>> createState() =>
      _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T>
    extends State<InfiniteScrollList<T>> {
  late final ScrollController _controller;

  InfiniteScrollStatus _status = InfiniteScrollStatus.idle;

  Object? _error;

  late int _page;
  Object? _cursor;

  bool _hasInitialized = false;
  bool _triggeredLoad = false;

  List<T> get _processedItems {
    var list = List<T>.from(widget.items);

    if (widget.searchQuery?.isNotEmpty == true &&
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

    _page = widget.initialPage;
    _cursor = widget.initialCursor;

    _controller = widget.controller ?? ScrollController();

    _controller.addListener(_onScroll);

    if (widget.items.isEmpty && widget.hasMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMore(isInitialLoad: true);
      });
    } else {
      _hasInitialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant InfiniteScrollList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_hasInitialized && widget.items.isNotEmpty) {
      _hasInitialized = true;
    }
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final position = _controller.position;

    final shouldLoad =
        position.pixels >=
            position.maxScrollExtent - widget.loadMoreOffset;

    if (shouldLoad && !_triggeredLoad) {
      _triggeredLoad = true;
      _loadMore();
    }

    if (!shouldLoad) {
      _triggeredLoad = false;
    }
  }

  Future<void> _loadMore({
    bool isInitialLoad = false,
  }) async {
    if (!widget.hasMore) return;

    if (_status == InfiniteScrollStatus.loadingMore ||
        _status == InfiniteScrollStatus.initialLoading) {
      return;
    }

    setState(() {
      _status = isInitialLoad
          ? InfiniteScrollStatus.initialLoading
          : InfiniteScrollStatus.loadingMore;

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

      _hasInitialized = true;

      if (mounted) {
        setState(() {
          _status = InfiniteScrollStatus.idle;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = InfiniteScrollStatus.error;
          _error = e;
          _hasInitialized = true;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;

    _page = widget.initialPage;
    _cursor = widget.initialCursor;

    await widget.onRefresh!();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  Widget _buildErrorWidget() {
    return widget.errorBuilder?.call(
      context,
      _error!,
      _loadMore,
    ) ??
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

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = _processedItems;

    final isInitialLoading =
        _status == InfiniteScrollStatus.initialLoading;

    final isLoadingMore =
        _status == InfiniteScrollStatus.loadingMore;

    final isError =
        _status == InfiniteScrollStatus.error;

    /// INITIAL SKELETON
    if (widget.enableSkeletonLoader &&
        items.isEmpty &&
        isInitialLoading) {
      return widget.skeletonWidget ??
          const _DefaultListSkeleton();
    }

    /// EMPTY
    if (_hasInitialized &&
        items.isEmpty &&
        !isInitialLoading) {
      return widget.emptyWidget ??
          const Center(
            child: Text('No items found'),
          );
    }

    Widget listView = ListView.builder(
      controller: _controller,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      padding: widget.padding,
      itemCount:
      items.length + ((isLoadingMore || isError) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(
            context,
            items[index],
            index,
          );
        }

        if (isError) {
          return _buildErrorWidget();
        }

        return _buildLoadingWidget();
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: listView,
      );
    }

    return listView;
  }
}

/// ===========================================================================
/// InfiniteScrollGrid
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
    super.initialPage,
    super.initialCursor,
    super.onRefresh,
    super.shrinkWrap,
    super.reverse,
    super.padding,
  });

  @override
  State<InfiniteScrollList<T>> createState() =>
      _InfiniteScrollGridState<T>();
}

class _InfiniteScrollGridState<T>
    extends _InfiniteScrollListState<T> {
  @override
  Widget build(BuildContext context) {
    final widget = this.widget as InfiniteScrollGrid<T>;

    final items = _processedItems;

    final isInitialLoading =
        _status == InfiniteScrollStatus.initialLoading;

    final isLoadingMore =
        _status == InfiniteScrollStatus.loadingMore;

    final isError =
        _status == InfiniteScrollStatus.error;

    /// INITIAL SKELETON
    if (widget.enableSkeletonLoader &&
        items.isEmpty &&
        isInitialLoading) {
      return widget.skeletonWidget ??
          const _DefaultGridSkeleton();
    }

    /// EMPTY
    if (_hasInitialized &&
        items.isEmpty &&
        !isInitialLoading) {
      return widget.emptyWidget ??
          const Center(
            child: Text('No items found'),
          );
    }

    Widget grid = GridView.builder(
      controller: _controller,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      padding: widget.padding,
      gridDelegate: widget.gridDelegate,
      itemCount:
      items.length + ((isLoadingMore || isError) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return widget.itemBuilder(
            context,
            items[index],
            index,
          );
        }

        if (isError) {
          return SizedBox(
            width: double.infinity,
            child: _buildErrorWidget(),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: _buildLoadingWidget(),
        );
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: grid,
      );
    }

    return grid;
  }
}