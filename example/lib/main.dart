import 'package:flutter/material.dart';
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Infinite Scroll')),
      body: InfiniteScrollList(
        itemCount: _items.length,
        itemBuilder: (context, index) => ListTile(title: Text(_items[index])),
        onLoadMore: _loadMore,
        hasMore: _hasMore,
      ),
    );
  }
}
