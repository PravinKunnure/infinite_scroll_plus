import 'package:flutter/material.dart';
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  Future<List<int>> _fetchData(int pageKey) async {
    await Future.delayed(const Duration(seconds: 2));
    if (pageKey > 5) return []; // simulate end of list
    return List.generate(10, (i) => i + pageKey * 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite Scroll Plus Example')),
      body: InfiniteScrollList<int>(
        fetchPage: _fetchData,
        itemBuilder: (context, item, index) => ListTile(title: Text('Item $item')),
      ),
    );
  }
}
