# infinite_scroll_plus

A lightweight Flutter package that provides **infinite scroll functionality** for `ListView` and `GridView` widgets.  
Easily add lazy loading, automatic pagination, and customizable loading indicators to your Flutter apps.

---

## ✨ Features

- 🔁 Infinite scrolling for lists and grids
- ⚡ Lazy loading with async `onLoadMore` callback
- 🧩 Customizable loading indicators
- 🪶 Lightweight and easy to integrate
- 📱 Supports both ListView and GridView use cases

---

## 🚀 Installation

Add the dependency in your **`pubspec.yaml`** file:

```yaml
dependencies:
  infinite_scroll_plus: ^0.0.3



# infinite_scroll_plus

A Flutter package that provides **infinite scrolling** for `ListView` and `GridView` widgets.  
It supports lazy loading, easy pagination, and customizable loading indicators — perfect for long lists or API-based data loading.

---

## ✨ Features

- Infinite scrolling for lists and grids  
- Simple API with `onLoadMore` callback  
- Customizable loading widget  
- Lightweight and flexible  
- Works with both static and dynamic data sources  

---

## 🧠 Usage

```dart
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
