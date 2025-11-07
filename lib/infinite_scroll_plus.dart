import 'package:flutter/material.dart';

typedef FetchPage<T> = Future<List<T>> Function(int pageKey);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class InfiniteScrollList<T> extends StatefulWidget {
  final FetchPage<T> fetchPage;
  final ItemBuilder<T> itemBuilder;
  final Widget? loadingIndicator;
  final Widget? emptyWidget;
  final double triggerThreshold;
  final ScrollController? scrollController;
  final bool reverse;

  const InfiniteScrollList({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.loadingIndicator,
    this.emptyWidget,
    this.triggerThreshold = 200,
    this.scrollController,
    this.reverse = false,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
    _controller.addListener(_onScroll);
    _fetchNextPage();
  }

  void _onScroll() {
    if (!_controller.hasClients || _isLoading || !_hasMore) return;
    final thresholdReached =
    widget.reverse
        ? _controller.position.pixels <= widget.triggerThreshold
        : _controller.position.maxScrollExtent - _controller.position.pixels <= widget.triggerThreshold;

    if (thresholdReached) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchNextPage() async {
    setState(() => _isLoading = true);
    final newItems = await widget.fetchPage(_page);
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _hasMore = newItems.isNotEmpty;
      if (newItems.isNotEmpty) _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items'));
    }

    return ListView.builder(
      reverse: widget.reverse,
      controller: _controller,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return widget.loadingIndicator ??
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _controller.dispose();
    super.dispose();
  }
}
