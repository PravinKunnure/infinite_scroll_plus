import 'package:flutter/material.dart';
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

// Example App
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final List<String> _items = List.generate(20, (i) => 'Item $i');

  bool _hasMore = true;
  bool _isGridView = false;

  // Search / Sort state
  String _searchQuery = "";
  bool _sortEnabled = false;

  // ---- Load more items (pagination) ----
  Future<void> _loadMore() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_items.length >= 100) {
      setState(() => _hasMore = false);
      return;
    }

    setState(() {
      _items.addAll(
        List.generate(10, (i) => 'Item ${_items.length + i}'),
      );
    });
  }

  void _toggleView() {
    setState(() => _isGridView = !_isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Example'),
        actions: [
          // Toggle List / Grid
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
          ),

          // Toggle Sort
          IconButton(
            icon: Icon(
              Icons.sort,
              color: _sortEnabled ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() => _sortEnabled = !_sortEnabled);
            },
            tooltip: "Sort A→Z",
          ),
        ],
      ),

      // Search Bar
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search items...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Expanded area for Infinite Scroll Widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isGridView
                  ? InfiniteScrollGrid<String>(
                      items: _items,
                      onLoadMore: _loadMore,
                      hasMore: _hasMore,

                      // SEARCH
                      searchQuery: _searchQuery,
                      onSearch: (items, q) => items
                          .where(
                              (e) => e.toLowerCase().contains(q.toLowerCase()))
                          .toList(),

                      // SORT
                      applySort: _sortEnabled,
                      onSort: (items) {
                        items.sort((a, b) => a.compareTo(b));
                        return items;
                      },

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),

                      itemBuilder: (context, item, index) => Card(
                        color: Colors.blue.shade100,
                        child: Center(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : InfiniteScrollList<String>(
                      items: _items,
                      onLoadMore: _loadMore,
                      hasMore: _hasMore,

                      // SEARCH
                      searchQuery: _searchQuery,
                      onSearch: (items, q) => items
                          .where(
                              (e) => e.toLowerCase().contains(q.toLowerCase()))
                          .toList(),

                      // SORT
                      applySort: _sortEnabled,
                      onSort: (items) {
                        items.sort((a, b) => a.compareTo(b));
                        return items;
                      },

                      itemBuilder: (context, item, index) => ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(item),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
