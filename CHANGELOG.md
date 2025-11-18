## 0.0.1

* Have initial phase not working for all platforms


## 0.0.2

* Not working for web


## 0.0.3

* Working for all platforms,
* Provides infinite scrolling for Flutter ListViews and GridViews.
* Supports lazy loading and customizable loading indicators.

## 0.0.5
- Added InfiniteScrollGrid
- Improved loading indicator customization
- Fixed minor bugs


## [0.0.6] - 2025-11-13
### Added
- Proper library-level documentation and version comment.
- Inline comments explaining key parts of `InfiniteScrollList` and `InfiniteScrollGrid`.
- Type definition for `ItemWidgetBuilder` clarified.

### Fixed
- Dangling library doc comment warning in `infinite_scroll_plus.dart`.
- Dart formatter issues; file now fully formatted.

### Improved
- Readability and maintainability of infinite scroll logic.
- Consistent use of `_scrollController` and proper disposal handling.

## [0.0.7] - 2025-11-14
### Added
- Fully documented public API with DartDoc comments for `InfiniteScrollList` and `InfiniteScrollGrid`.
- Added descriptions for constructors, properties, and methods to improve readability and pub.dev documentation.
- Optional `loadingWidget` support in both `InfiniteScrollList` and `InfiniteScrollGrid`.
- `ItemWidgetBuilder` typedef introduced for consistent item builder signatures.

### Changed
- Removed unnecessary `library infinite_scroll_plus;` declaration to comply with Dart lints.
- Improved scroll detection logic documentation.
- Minor refactoring for clarity in `_onScroll` and `_loadMore` methods.

### Fixed
- Documentation coverage issue for public API (now above 20%) to pass `public_member_api_docs` lint check.



## [0.0.8] - 2025-11-14
### Added
- Fully documented public API with DartDoc comments for `InfiniteScrollList` and `InfiniteScrollGrid`.
- Added descriptions for constructors, properties, and methods to improve readability and pub.dev documentation.
- Optional `loadingWidget` support in both `InfiniteScrollList` and `InfiniteScrollGrid`.
- `ItemWidgetBuilder` typedef introduced for consistent item builder signatures.

### Changed
- Removed unnecessary `library infinite_scroll_plus;` declaration to comply with Dart lints.
- Improved scroll detection logic documentation.
- Minor refactoring for clarity in `_onScroll` and `_loadMore` methods.

### Fixed
- Documentation coverage issue for public API (now above 20%) to pass `public_member_api_docs` lint check.
- Added demo.gif for more information

## [0.0.9] - 2025-11-14
### Added
- Added the ability to **toggle between ListView and GridView dynamically**.
- Support for **customizable loading indicators** for both list and grid views.
- Updated example app to demonstrate the new toggle feature.
- Minor performance improvements for infinite scrolling and lazy loading.

## [0.0.10] - 2025-11-14
### Added
- Added the ability to **toggle between ListView and GridView dynamically**.
- Support for **customizable loading indicators** for both list and grid views.
- Updated example app to demonstrate the new toggle feature.
- Minor performance improvements for infinite scrolling and lazy loading.
- Demo not loading issue.


## [0.0.11] - 2025-11-14
### Added
- Minor performance improvements for infinite scrolling and lazy loading.
- Demo not loading issue.


## [0.0.12] - 2025-11-18
### Added
- Minor performance improvements for infinite scrolling and lazy loading.
- Demo not loading issue.



