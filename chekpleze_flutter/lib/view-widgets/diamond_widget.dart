import 'package:flutter/material.dart';

/// A custom diamond (rotated square) border that supports rounded tips
/// via [cornerRadius]. The radius is clamped so arcs never overlap.
class DiamondBorder extends OutlinedBorder {
  const DiamondBorder({super.side = BorderSide.none, this.cornerRadius = 0});

  /// Corner radius for rounding the diamond tips. 0 = sharp corners.
  final double cornerRadius;

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      DiamondBorder(side: side ?? this.side, cornerRadius: cornerRadius);

  Path _buildRoundedDiamondPath(Rect rect, double radius) {
    final cx = rect.center.dx, cy = rect.center.dy;
    final top = Offset(cx, rect.top);
    final right = Offset(rect.right, cy);
    final bottom = Offset(cx, rect.bottom);
    final left = Offset(rect.left, cy);

    double edgeLength(Offset a, Offset b) => (b - a).distance;
    final lengths = [edgeLength(top, right), edgeLength(right, bottom), edgeLength(bottom, left), edgeLength(left, top)];
    final maxR = lengths.map((l) => l * 0.5).reduce((a, b) => a < b ? a : b);
    final r = radius.clamp(0.0, maxR);
    if (r <= 0) {
      return Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(bottom.dx, bottom.dy)
        ..lineTo(left.dx, left.dy)
        ..close();
    }

    Offset along(Offset p0, Offset p1, double d) {
      final v = p1 - p0;
      final len = v.distance;
      if (len == 0) return p0;
      final t = (d / len).clamp(0.0, 1.0);
      return p0 + v * t;
    }

    final tEntry = along(left, top, edgeLength(left, top) - r); // entering top corner from left
    final tExit = along(top, right, r);                         // exiting top corner toward right
    final rEntry = along(top, right, edgeLength(top, right) - r);
    final rExit = along(right, bottom, r);
    final bEntry = along(right, bottom, edgeLength(right, bottom) - r);
    final bExit = along(bottom, left, r);
    final lEntry = along(bottom, left, edgeLength(bottom, left) - r);
    final lExit = along(left, top, r);

    return Path()
      ..moveTo(tEntry.dx, tEntry.dy)
      ..arcToPoint(tExit, radius: Radius.circular(r), clockwise: true)
      ..lineTo(rEntry.dx, rEntry.dy)
      ..arcToPoint(rExit, radius: Radius.circular(r), clockwise: true)
      ..lineTo(bEntry.dx, bEntry.dy)
      ..arcToPoint(bExit, radius: Radius.circular(r), clockwise: true)
      ..lineTo(lEntry.dx, lEntry.dy)
      ..arcToPoint(lExit, radius: Radius.circular(r), clockwise: true)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildRoundedDiamondPath(rect, cornerRadius);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.solid && side.width > 0) {
      final path = getOuterPath(rect, textDirection: textDirection);
      final paint = side.toPaint()..isAntiAlias = true;
      canvas.drawPath(path, paint);
    }
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    if (side.width <= 0) return getOuterPath(rect, textDirection: textDirection);
    final shrink = side.width;
    final safeRect = Rect.fromLTWH(
      rect.left + shrink,
      rect.top + shrink,
      (rect.width - 2 * shrink).clamp(0.0, rect.width),
      (rect.height - 2 * shrink).clamp(0.0, rect.height),
    );
    // Recompute path with same radius (implicitly clamped to new rect).
    return _buildRoundedDiamondPath(safeRect, cornerRadius);
  }

  @override
  ShapeBorder scale(double t) => DiamondBorder(
        side: side == BorderSide.none ? BorderSide.none : side.copyWith(width: side.width * t),
        cornerRadius: cornerRadius * t,
      );

  @override
  int get hashCode => Object.hash(side, cornerRadius);

  @override
  bool operator ==(Object other) =>
      other is DiamondBorder && other.side == side && other.cornerRadius == cornerRadius;
}

class DiamondTile extends StatelessWidget {
  const DiamondTile({
    super.key,
    required this.size,
    required this.child,
    this.fillColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.cornerRadius = 8.0,
    this.onTap,
    this.onLongPress,
    this.contentPadding = const EdgeInsets.all(8.0),
  });

  final double size;
  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  /// Rounded corner radius for diamond tips.
  final double cornerRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  /// Padding inside the diamond for its child content.
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final shape = DiamondBorder(
      side: BorderSide(color: borderColor, width: borderWidth),
      cornerRadius: cornerRadius,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        shape: DiamondBorder(cornerRadius: cornerRadius), // clip & ripple shape
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: DiamondBorder(cornerRadius: cornerRadius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Ink(
            decoration: ShapeDecoration(
              shape: shape,
              color: fillColor,
            ),
            child: Padding(
              padding: contentPadding,
              child: Center(child: _coerceChild(context, child)),
            ),
          ),
        ),
      ),
    );
  }

  /// Ensure text children don't overflow by enforcing max line rules and ellipsis.
  /// - Single word: maxLines = 1
  /// - Contains a space: maxLines = 2
  /// Other widgets are wrapped with FittedBox(scaleDown) to avoid overflow.
  Widget _coerceChild(BuildContext context, Widget child) {
    if (child is Text) {
      // Try to detect simple single-word vs spaced text.
      final data = child.data;
      final hasSpace = data?.contains(' ') ?? false;
      final maxLines = hasSpace ? 2 : 1;
      // Resolve a non-deprecated text scaler: prefer child's own, else inherit from MediaQuery.
      final inheritedScaler = MediaQuery.maybeOf(context)?.textScaler;
      return Text(
        data ?? '',
        key: child.key,
        style: child.style,
        strutStyle: child.strutStyle,
        textAlign: child.textAlign ?? TextAlign.center,
        textDirection: child.textDirection,
        locale: child.locale,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        // Use non-deprecated textScaler; do not reference textScaleFactor.
        textScaler: child.textScaler ?? inheritedScaler,
        maxLines: maxLines,
        semanticsLabel: child.semanticsLabel,
        textWidthBasis: child.textWidthBasis ?? TextWidthBasis.parent,
        textHeightBehavior: child.textHeightBehavior,
      );
    }
    // For non-Text widgets, scale down to fit the available area.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: child,
    );
  }
}