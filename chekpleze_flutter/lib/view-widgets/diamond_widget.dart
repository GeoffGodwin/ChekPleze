import 'package:flutter/material.dart';

class DiamondBorder extends OutlinedBorder {
  const DiamondBorder({super.side = BorderSide.none});

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      DiamondBorder(side: side ?? this.side);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cx = rect.center.dx, cy = rect.center.dy;
    return Path()
      ..moveTo(cx, rect.top)           // top
      ..lineTo(rect.right, cy)         // right
      ..lineTo(cx, rect.bottom)        // bottom
      ..lineTo(rect.left, cy)          // left
      ..close();
  }

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
  
  /// Inner path used by ink effects. We shrink the rect by the border [side.width]
  /// to avoid painting ink under the border stroke.
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    if (side.width <= 0) {
      return getOuterPath(rect, textDirection: textDirection);
    }
    final shrink = side.width;
    // Ensure we don't invert the rect if border is huge.
    final safeRect = Rect.fromLTWH(
      rect.left + shrink,
      rect.top + shrink,
      (rect.width - 2 * shrink).clamp(0.0, rect.width),
      (rect.height - 2 * shrink).clamp(0.0, rect.height),
    );
    return getOuterPath(safeRect, textDirection: textDirection);
  }
  
  /// Scale the border. Conventionally we scale the stroke width linearly.
  @override
  ShapeBorder scale(double t) {
    return DiamondBorder(
      side: side == BorderSide.none
          ? BorderSide.none
          : side.copyWith(width: side.width * t),
    );
  }
}

class DiamondTile extends StatelessWidget {
  const DiamondTile({
    super.key,
    required this.size,
    required this.child,
    this.fillColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.onTap,
    this.onLongPress,
    this.contentPadding = const EdgeInsets.all(8.0),
  });

  final double size;
  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  /// Padding inside the diamond for its child content.
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final shape = DiamondBorder(
      side: BorderSide(color: borderColor, width: borderWidth),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        shape: const DiamondBorder(),          // clip/ripple shape
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const DiamondBorder(), // shape-aware hit test
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