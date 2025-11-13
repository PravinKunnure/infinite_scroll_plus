///----------V0.0.5
import 'package:flutter/material.dart';

// Make sure your custom InfiniteScrollList code is in the same file
// or imported from another file.

typedef ItemWidgetBuilder = Widget Function(BuildContext context, int index);

///ListView
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
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

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


///GridView
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

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
          // Loading indicator at the end
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


///----------V0.0.4
// import 'package:flutter/material.dart';
//
// typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);
// typedef ItemFilter<T> = bool Function(T item);
// typedef ItemSort<T> = int Function(T a, T b);
//
// class InfiniteScrollList<T> extends StatefulWidget {
//   final List<T> items;
//   final ItemWidgetBuilder<T> itemBuilder;
//   final Future<void> Function() onLoadMore;
//   final bool hasMore;
//   final Widget? loadingWidget;
//   final ScrollController? controller;
//
//   const InfiniteScrollList({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.controller,
//   });
//
//   @override
//   State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
// }
//
// class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
//   late final ScrollController _scrollController;
//   bool _isLoading = false;
//
//   // For filtering/searching/sorting
//   String _searchQuery = '';
//   List<ItemFilter<T>> _filters = [];
//   ItemSort<T>? _sorter;
//
//   List<T> get _displayedItems {
//     List<T> list = widget.items;
//
//     // Apply filters
//     for (var filter in _filters) {
//       list = list.where(filter).toList();
//     }
//
//     // Apply search
//     if (_searchQuery.isNotEmpty) {
//       list = list
//           .where((item) =>
//           item.toString().toLowerCase().contains(_searchQuery.toLowerCase()))
//           .toList();
//     }
//
//     // Apply sorting
//     if (_sorter != null) {
//       list.sort(_sorter);
//     }
//
//     return list;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.controller ?? ScrollController();
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       _loadMore();
//     }
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//     setState(() => _isLoading = true);
//     await widget.onLoadMore();
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   /// Public methods to modify filters/search/sort
//   void setSearchQuery(String query) {
//     setState(() => _searchQuery = query);
//   }
//
//   void addFilter(ItemFilter<T> filter) {
//     setState(() => _filters.add(filter));
//   }
//
//   void clearFilters() {
//     setState(() => _filters.clear());
//   }
//
//   void setSorter(ItemSort<T> sorter) {
//     setState(() => _sorter = sorter);
//   }
//
//   void clearSorter() {
//     setState(() => _sorter = null);
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _scrollController.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final displayedItems = _displayedItems;
//
//     return ListView.builder(
//       controller: _scrollController,
//       itemCount: displayedItems.length + (widget.hasMore ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < displayedItems.length) {
//           return widget.itemBuilder(context, displayedItems[index]);
//         } else {
//           return widget.loadingWidget ??
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Center(child: CircularProgressIndicator()),
//               );
//         }
//       },
//     );
//   }
// }



///----------V0.0.3
// import 'package:flutter/material.dart';
//
// typedef ItemWidgetBuilder = Widget Function(BuildContext context, int index);
//
// class InfiniteScrollList extends StatefulWidget {
//   final int itemCount;
//   final ItemWidgetBuilder itemBuilder;
//   final Future<void> Function() onLoadMore;
//   final bool hasMore;
//   final Widget? loadingWidget;
//   final ScrollController? controller;
//
//   const InfiniteScrollList({
//     super.key,
//     required this.itemCount,
//     required this.itemBuilder,
//     required this.onLoadMore,
//     this.hasMore = true,
//     this.loadingWidget,
//     this.controller,
//   });
//
//   @override
//   State<InfiniteScrollList> createState() => _InfiniteScrollListState();
// }
//
// class _InfiniteScrollListState extends State<InfiniteScrollList> {
//   late final ScrollController _scrollController;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.controller ?? ScrollController();
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       // Close to bottom — trigger load more
//       _loadMore();
//     }
//   }
//
//   Future<void> _loadMore() async {
//     if (_isLoading || !widget.hasMore) return;
//     setState(() => _isLoading = true);
//     await widget.onLoadMore();
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _scrollController.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       controller: _scrollController,
//       itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
//       itemBuilder: (context, index) {
//         if (index < widget.itemCount) {
//           return widget.itemBuilder(context, index);
//         } else {
//           // Loading indicator at the end
//           return widget.loadingWidget ??
//               const Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Center(child: CircularProgressIndicator()),
//               );
//         }
//       },
//     );
//   }
// }
