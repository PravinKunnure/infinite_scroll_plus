# Changelog

All notable changes to this package will be documented in this file.
This project follows early-stage semantic versioning during development.


---
## 2.0.2
- Required Document Changes done
- Minor bug fixes

## 2.0.1
- Required Document Changes done

## 2.0.0 — Major Upgrade 🎉
### Added
- `onLoadMore` now receives `LoadMoreRequest` for full API pagination control (page, offset, cursor).
- **Error handling** support via `errorBuilder` with retry callback.
- Updated example app with proper `_loadMore` using `LoadMoreRequest`.
- Skeleton loader improvements for initial empty state.
- Fully compatible ListView and GridView with search & sort.

### Changed
- Breaking change: `onLoadMore()` must accept `LoadMoreRequest` parameter.
- Skeleton loader now optional via `enableSkeletonLoader`.
- API and example updated for v2.0.0 usage.

---

## 1.0.4
### Added
- Built-in skeleton loaders for ListView and GridView.
- Optional `enableSkeletonLoader` flag.
- Customizable `skeletonWidget` and `emptyWidget` support.
- Configurable `loadMoreOffset` for pagination trigger distance.

### Improved
- Pagination stability when search or sort state changes.
- Scroll trigger debouncing using max scroll extent tracking.
- Overall UX consistency across list and grid views.

### Fixed
- Edge cases where pagination could stop after data mutations.

---

## 1.0.1 to 1.0.3
- Code formatting and Dart analyzer cleanups.

---

## 1.0.0 — Major Upgrade 🎉
### Added
- **Search support** using `searchQuery` and `onSearch`.
- **Sort support** using `applySort` and `onSort`.
- **Generic item system** (`InfiniteScrollList<T>` and `InfiniteScrollGrid<T>`).
- New improved example app with search, sort, and view toggle.
- Cleaner API replacing `itemCount` with `items`.

### Changed
- Refactored `itemBuilder` signature:
  ```dart
  Widget Function(BuildContext context, T item, int index)


## 0.0.12 – 0.0.14
### Improved
- Minor incremental lazy loading optimizations.

### Fixed
- Demo-related issues.

## 0.0.11
### Improved
- Lazy loading stability and performance.

### Fixed
- Demo loading issues.

## 0.0.10
### Added
- Advanced example app features.

### Fixed
- Demo not loading correctly.

## 0.0.9
### Added
- List/Grid toggle in example app.
- Custom loading indicator examples.

### Improved
- Lazy loading performance.

## 0.0.8
### Added
- Demo GIF for pub.dev.
- Continued documentation improvements.

### Improved
- _onScroll and _loadMore clarity.

### Fixed
- Documentation coverage issues.

## 0.0.7
### Added
- Full DartDoc coverage for all public APIs.
- Optional loadingWidget parameter.
- Detailed documentation for constructors, properties, and methods.

### Changed
- Removed unnecessary library infinite_scroll_plus; declaration.
- Improved scroll detection documentation.

### Fixed
- public_member_api_docs lint compliance.

## 0.0.6
### Added
- Complete library-level documentation.
- Inline comments for InfiniteScrollList and InfiniteScrollGrid.
- Clarified ItemWidgetBuilder typedef.

### Fixed
- Dangling doc comment warnings.
- Dart formatter issues.

### Improved
- Scroll controller lifecycle handling.
- Readability and maintainability of scroll logic.

## 0.0.5
### Added
- InfiniteScrollGrid widget.
- Improved loading indicator customization.

### Fixed
- Minor bugs and stability issues.

## 0.0.3
### Added
- Full support for all platforms.
- Infinite scrolling for Flutter ListView and GridView.
- Lazy loading support with customizable loading indicators.

## 0.0.2
### Fixed
- Resolved multi-platform issues (web still unsupported).

## 0.0.1
### Added
-  Initial release (not working across all platforms).