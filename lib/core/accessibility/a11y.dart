import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper for consistent Semantics usage
class A11y {
  A11y._();

  /// Wrap a widget with semantic label for screen readers
  static Widget label({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? image,
    bool? link,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      image: image,
      link: link,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Announce a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  /// Create a semantic group for related elements
  static Widget group({
    required Widget child,
    required String label,
    bool? sortKey,
  }) {
    return Semantics(
      label: label,
      container: true,
      child: child,
    );
  }

  /// Merge semantics of child widgets
  static Widget merge({required Widget child}) {
    return MergeSemantics(child: child);
  }

  /// Exclude from semantics tree (decorative elements)
  static Widget exclude({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Wrap an interactive widget ensuring minimum touch target of 48dp
  static Widget touchTarget({
    required Widget child,
    double minSize = 48.0,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}
