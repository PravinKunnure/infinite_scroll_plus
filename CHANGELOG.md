## 0.0.1
### Added
- Initial release (not working across all platforms).

## 0.0.2
### Fixed
- Resolved multi-platform issues but still not working for web.

## 0.0.3
### Added
- Full support for all platforms.
- Infinite scrolling for Flutter ListViews and GridViews.
- Lazy loading support with customizable loading indicators.

## 0.0.5
### Added
- `InfiniteScrollGrid` widget.
- Improved loading indicator customization.

### Fixed
- Minor bugs and stability issues.

## 0.0.6
### Added
- Complete library-level documentation.
- Inline comments for `InfiniteScrollList` and `InfiniteScrollGrid`.
- Clarified `ItemWidgetBuilder` typedef.

### Fixed
- Dangling doc comment warning.
- Formatting issues with Dart formatter.

### Improved
- Scroll controller lifecycle handling.
- Readability and maintainability of scroll logic.

## 0.0.7
### Added
- Full DartDoc coverage for all public API elements.
- Optional `loadingWidget` parameter.
- More detailed documentation for constructors, properties, and methods.

### Changed
- Removed unnecessary `library infinite_scroll_plus;` declaration.
- Improved documentation around scroll detection.

### Fixed
- Public API documentation coverage to meet `public_member_api_docs` lint requirement.

## 0.0.8
### Added
- Demo GIF added for pub.dev.
- Continued documentation improvements.

### Changed
- Improved `_onScroll` and `_loadMore` clarity.

### Fixed
- More documentation coverage issues.

## 0.0.9
### Added
- Ability to toggle between ListView and GridView in the example.
- Custom loading indicator examples.

### Improved
- Lazy loading performance.

## 0.0.10
### Added
- More advanced example app details.

### Fixed
- Demo not loading issue.

## 0.0.11
### Improved
- Lazy loading stability and performance.

### Fixed
- Additional demo loading issues.

## 0.0.12 — 0.0.14
### Improved
- Minor incremental improvements to lazy loading performance.

### Fixed
- Demo related issues.

---

## **1.0.0 — Major Upgrade 🎉**
### Added
- **Search support**:  
  Allows filtering of already loaded data using `searchQuery` and `onSearch` callbacks.
- **Sort support**:  
  Local list/grid sorting through `applySort` and `onSort` callbacks.
- **Generic item system (`InfiniteScrollList<T>` & `InfiniteScrollGrid<T>`)**:
  Ensures type safety and flexibility.
- **New improved example app**:
  Includes search bar, sort button, and list/grid toggle.
- **Cleaner API**:  
  Replaced `itemCount` with `items` to enable local search & sort processing.

### Changed
- Refactored `itemBuilder` to use:
  ```dart
  (BuildContext context, T item, int index)


## 1.0.1
### Improved
- Minor incremental improvements to lazy loading performance.

## 1.0.2
### Improved
- Minor improvements.
