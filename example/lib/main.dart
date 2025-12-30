import 'package:flutter/material.dart';
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final List<String> _items = [];

  bool _hasMore = true;
  bool _isGridView = false;

  String _searchQuery = "";
  bool _sortEnabled = false;

  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _items.addAll(List.generate(20, (i) => 'Item $i'));
      _initialLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Infinite Scroll Plus',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _isGridView ? 'List view' : 'Grid view',
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            tooltip: 'Sort A → Z',
            icon: Icon(
              Icons.sort_by_alpha_rounded,
              color: _sortEnabled ? cs.primary : cs.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _sortEnabled = !_sortEnabled),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                key: ValueKey(_isGridView),
                padding: const EdgeInsets.all(12),
                child: _isGridView
                    ? InfiniteScrollGrid<String>(
                        items: _items,
                        onLoadMore: _loadMore,
                        hasMore: _hasMore,
                        enableSkeletonLoader: _initialLoading,
                        searchQuery: _searchQuery,
                        onSearch: (items, q) => items
                            .where((e) =>
                                e.toLowerCase().contains(q.toLowerCase()))
                            .toList(),
                        applySort: _sortEnabled,
                        onSort: (items) {
                          items.sort((a, b) => a.compareTo(b));
                          return items;
                        },
                        emptyWidget: const _EmptyState(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, item, index) => _GridCard(
                          title: item,
                          index: index,
                        ),
                      )
                    : InfiniteScrollList<String>(
                        items: _items,
                        onLoadMore: _loadMore,
                        hasMore: _hasMore,
                        enableSkeletonLoader: _initialLoading,
                        searchQuery: _searchQuery,
                        onSearch: (items, q) => items
                            .where((e) =>
                                e.toLowerCase().contains(q.toLowerCase()))
                            .toList(),
                        applySort: _sortEnabled,
                        onSort: (items) {
                          items.sort((a, b) => a.compareTo(b));
                          return items;
                        },
                        emptyWidget: const _EmptyState(),
                        itemBuilder: (context, item, index) => Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: cs.onPrimaryContainer),
                              ),
                            ),
                            title: Text(
                              item,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text('Tap to view details'),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🧩 Grid Card Widget
class _GridCard extends StatelessWidget {
  final String title;
  final int index;

  const _GridCard({required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cs.primaryContainer.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 36,
              color: cs.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '#${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: cs.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📭 Empty State
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No items found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
