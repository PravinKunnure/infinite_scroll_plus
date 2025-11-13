import 'package:flutter/material.dart';
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

///0.0.5 nw
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
  bool _isGridView = false; // toggle between list & grid

  Future<void> _loadMore() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_items.length >= 100) {
      setState(() => _hasMore = false);
      return;
    }

    setState(() {
      _items.addAll(List.generate(10, (i) => 'Item ${_items.length + i}'));
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Example'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isGridView
            ? InfiniteScrollGrid(
          itemCount: _items.length,
          itemBuilder: (context, index) => Card(
            color: Colors.blue.shade100,
            child: Center(
              child: Text(
                _items[index],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          onLoadMore: _loadMore,
          hasMore: _hasMore,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
        )
            : InfiniteScrollList(
          itemCount: _items.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(_items[index]),
          ),
          onLoadMore: _loadMore,
          hasMore: _hasMore,
        ),
      ),
    );
  }
}

///0.0.5
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MyPage(),
//     );
//   }
// }
//
// class MyPage extends StatefulWidget {
//   const MyPage({super.key});
//
//   @override
//   State<MyPage> createState() => _MyPageState();
// }
//
// class _MyPageState extends State<MyPage> {
//   final List<String> _items = List.generate(20, (i) => 'Item $i');
//   bool _hasMore = true;
//
//   Future<void> _loadMore() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (_items.length >= 100) {
//       setState(() => _hasMore = false);
//       return;
//     }
//     setState(() {
//       _items.addAll(
//           List.generate(10, (i) => 'Item ${_items.length + i}'));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Infinite Scroll')),
//       body: InfiniteScrollList(
//         itemCount: _items.length,
//         itemBuilder: (context, index) => ListTile(title: Text(_items[index])),
//         onLoadMore: _loadMore,
//         hasMore: _hasMore,
//       ),
//     );
//   }
// }



///0.0.4
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MyPage(),
//     );
//   }
// }
//
// class MyPage extends StatefulWidget {
//   const MyPage({super.key});
//
//   @override
//   State<MyPage> createState() => _MyPageState();
// }
//
// class _MyPageState extends State<MyPage> {
//   final List<String> _items = List.generate(20, (i) => 'Item $i');
//   bool _hasMore = true;
//
//   Future<void> _loadMore() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (_items.length >= 100) {
//       setState(() => _hasMore = false);
//       return;
//     }
//     setState(() {
//       _items.addAll(
//           List.generate(10, (i) => 'Item ${_items.length + i}'));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Infinite Scroll')),
//       body: InfiniteScrollList(
//        // itemCount: _items.length,
//         items: _items,
//         itemBuilder: (context, int index) => ListTile(title: Text(_items[index])),
//         onLoadMore: _loadMore,
//         hasMore: _hasMore,
//       ),
//     );
//   }
// }

///0.0.3
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MyPage(),
//     );
//   }
// }
//
// class MyPage extends StatefulWidget {
//   const MyPage({super.key});
//
//   @override
//   State<MyPage> createState() => _MyPageState();
// }
//
// class _MyPageState extends State<MyPage> {
//   final List<String> _items = List.generate(20, (i) => 'Item $i');
//   bool _hasMore = true;
//
//   Future<void> _loadMore() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (_items.length >= 100) {
//       setState(() => _hasMore = false);
//       return;
//     }
//     setState(() {
//       _items.addAll(List.generate(10, (i) => 'Item ${_items.length + i}'));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Infinite Scroll')),
//       body: InfiniteScrollList(
//         itemCount: _items.length,
//         itemBuilder: (context, index) => ListTile(title: Text(_items[index])),
//         onLoadMore: _loadMore,
//         hasMore: _hasMore,
//       ),
//     );
//   }
// }
