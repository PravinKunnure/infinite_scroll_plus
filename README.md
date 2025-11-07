# infinite_scroll_plus

A Flutter package that provides infinite scroll functionality for ListViews and GridViews.
Supports lazy loading, automatic pagination, and easy customization.

## Features

- Infinite scrolling for Flutter widgets
- Easy integration with ListView and GridView
- Customizable loading indicators
- Lightweight and fast

## Usage

```dart
import 'package:infinite_scroll_plus/infinite_scroll_plus.dart';

InfiniteScrollList(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
  onLoadMore: () async {
    // load more data
  },
);
