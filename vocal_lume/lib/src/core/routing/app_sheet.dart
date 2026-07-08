import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Size presets
// ─────────────────────────────────────────────────────────────────────────────

/// Controls how tall the bottom sheet is relative to the screen.
enum SheetSize {
  /// Sheet wraps its content — height is determined by the child widget.
  dynamic,

  /// Sheet occupies exactly half the screen height.
  half,

  /// Sheet occupies the full screen height (minus the status bar).
  full,
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable bottom sheet helper.
///
/// Three size presets: [SheetSize.dynamic], [SheetSize.half], [SheetSize.full].
///
/// ## Basic usage
/// ```dart
/// // Dynamic height (wraps content)
/// AppSheet.show(context, child: const MyWidget());
///
/// // Half screen
/// AppSheet.show(context, size: SheetSize.half, child: const MyWidget());
///
/// // Full screen
/// AppSheet.show(context, size: SheetSize.full, child: const MyWidget());
///
/// // With a return value
/// final result = await AppSheet.show<String>(context, child: const MyWidget());
/// ```
abstract final class AppSheet {
  /// Shows a modal bottom sheet.
  ///
  /// - [size] — [SheetSize.dynamic] (default), [SheetSize.half], or [SheetSize.full].
  /// - [isDismissible] — tap outside to close (default `true`).
  /// - [showDragHandle] — show the drag pill at the top (default `true`).
  /// - [backgroundColor] — defaults to [ColorScheme.surface].
  /// - [useSafeArea] — wrap content in [SafeArea] (default `true`).
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    SheetSize size = SheetSize.dynamic,
    bool isDismissible = true,
    bool showDragHandle = true,
    Color? backgroundColor,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true, // required for any size > intrinsic
      enableDrag: isDismissible,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SheetSizer(size: size, child: child),
    );
  }

  /// Shows a **half-screen** bottom sheet.
  static Future<T?> half<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool showDragHandle = true,
  }) =>
      show<T>(
        context,
        child: child,
        size: SheetSize.half,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
      );

  /// Shows a **full-screen** bottom sheet.
  static Future<T?> full<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool showDragHandle = true,
  }) =>
      show<T>(
        context,
        child: child,
        size: SheetSize.full,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
      );

  /// Shows a **dynamic-height** bottom sheet (wraps content).
  static Future<T?> dynamic<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool showDragHandle = true,
  }) =>
      show<T>(
        context,
        child: child,
        size: SheetSize.dynamic,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal sizer widget
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSizer extends StatelessWidget {
  const _SheetSizer({required this.size, required this.child});

  final SheetSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case SheetSize.dynamic:
        // Wraps child — sheet grows/shrinks with content.
        // Padding handles the software keyboard pushing content up.
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: child,
        );

      case SheetSize.half:
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: child,
        );

      case SheetSize.full:
        // Leave room for the status bar.
        return SizedBox(
          height: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).top,
          child: child,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension on BuildContext for ergonomic call-site syntax
// ─────────────────────────────────────────────────────────────────────────────

extension AppSheetX on BuildContext {
  /// Shows a dynamic-height bottom sheet.
  ///
  /// ```dart
  /// context.showSheet(child: const MyWidget());
  /// ```
  Future<T?> showSheet<T>({
    required Widget child,
    SheetSize size = SheetSize.dynamic,
    bool isDismissible = true,
    bool showDragHandle = true,
  }) =>
      AppSheet.show<T>(
        this,
        child: child,
        size: size,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
      );

  /// Shows a half-screen bottom sheet.
  Future<T?> showHalfSheet<T>({
    required Widget child,
    bool isDismissible = true,
  }) =>
      AppSheet.half<T>(this, child: child, isDismissible: isDismissible);

  /// Shows a full-screen bottom sheet.
  Future<T?> showFullSheet<T>({
    required Widget child,
    bool isDismissible = true,
  }) =>
      AppSheet.full<T>(this, child: child, isDismissible: isDismissible);
}
