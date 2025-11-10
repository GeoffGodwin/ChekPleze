import 'package:flutter/material.dart';
import 'diamond_widget.dart'; // still needed for DiamondTile

/// Two-row alternating diamond layout.
///
/// Ordering pattern: even indices placed in the top row (row 0), odd indices in
/// the bottom row (row 1). Visually this alternates placement left-to-right:
///  top(0), bottom(1), top(2), bottom(3), ...
///
/// Width expands with number of columns (ceil(count / 2)). The whole cluster is
/// centered in its parent; parent should give unconstrained width (e.g.
/// SizedBox.expand / constraints.maxWidth) then wrap this widget in Center.
///
/// If [stagger] is true, the bottom row diamonds are horizontally offset by
/// half a diamond size producing a classic lattice look. If false, rows align.
class DiamondTwoRowLattice extends StatelessWidget {
  const DiamondTwoRowLattice({
    super.key,
    required this.count,
    this.diamondSize = 70,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.fillColor = Colors.white,
    this.spacing = 4.0,
    this.stagger = true,
    this.itemBuilder,
    this.onTapIndex,
    this.debug = false,
    this.debugTileBounds = false,
    this.debugOuterBorderColor = const Color(0xFF00C853),
    this.debugTileBorderColor = const Color(0xFF2962FF),
    this.debugBackground,
    this.dropEnabled = false,
    this.onItemDropped,
    this.buildHighlightFill,
    this.selectionMode = false,
    this.selectedIndices = const {},
  });

  final int count;
  final double diamondSize;
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;
  final double spacing;
  final bool stagger;
  final IndexedWidgetBuilder? itemBuilder;
  final ValueChanged<int>? onTapIndex;
  // Debugging helpers
  final bool debug;
  final bool debugTileBounds;
  final Color debugOuterBorderColor;
  final Color debugTileBorderColor;
  final Color? debugBackground;
  // Drag & drop
  final bool dropEnabled;
  final void Function(int index, Object data)? onItemDropped;
  // Optional dynamic fill override when highlighting (drag over or selected)
  final Color Function(int index, bool isSelected, bool isDragHover)? buildHighlightFill;
  // Selection mode state passed from parent
  final bool selectionMode;
  final Set<int> selectedIndices;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox();
  // columns previously used for rough sizing; bounding box now computed precisely.

    // First pass: compute placements to calculate exact bounding box (avoids extra side padding).
    final placements = <Map<String, dynamic>>[];
    // Centering correction base offset: balances visual left bias in staggered layout.
    final baseOffsetX = stagger ? diamondSize / 4 : 0.0;
    final verticalFactor = stagger ? 0.5 : 0.6; // tweak for visual balance

    for (int i = 0; i < count; i++) {
      final col = i ~/ 2; // floor(i/2)
      final isTopRow = i % 2 == 0;
      final row = isTopRow ? 0 : 1;
      final dy = row * diamondSize * verticalFactor;
      double dx = baseOffsetX + col * diamondSize;
      if (stagger && row == 1) dx += diamondSize / 2;
      placements.add({'i': i, 'dx': dx, 'dy': dy});
    }

    double minLeft = double.infinity;
    double maxRight = -double.infinity;
    double minTop = double.infinity;
    double maxBottom = -double.infinity;
    for (final p in placements) {
      final dx = p['dx'] as double;
      final dy = p['dy'] as double;
      // dx/dy represent the top-left of the padded tile container (before Padding applies inside),
      // so the full padded bounds are exactly [dx .. dx + diamondSize + spacing].
      final left = dx;
      final right = dx + diamondSize + spacing;
      final top = dy;
      final bottom = dy + diamondSize + spacing;
      if (left < minLeft) minLeft = left;
      if (right > maxRight) maxRight = right;
      if (top < minTop) minTop = top;
      if (bottom > maxBottom) maxBottom = bottom;
    }
    if (minLeft == double.infinity) minLeft = 0;
    if (minTop == double.infinity) minTop = 0;

    final width = (maxRight - minLeft).clamp(0.0, double.infinity);
    final height = (maxBottom - minTop).clamp(0.0, double.infinity);

    // Second pass: build widgets with a normalization shift so leftmost aligns to x=0.
  final widgets = <Widget>[];
  final underlays = <Widget>[]; // debug underlays per tile
    for (final p in placements) {
      final i = p['i'] as int;
      final dx = (p['dx'] as double) - minLeft;
      final dy = (p['dy'] as double) - minTop;
      if (debug && debugTileBounds) {
        underlays.add(
          Transform.translate(
            // dx/dy already normalized by subtracting minLeft/minTop.
            offset: Offset(dx, dy),
            child: Container(
              width: diamondSize + spacing,
              height: diamondSize + spacing,
              decoration: BoxDecoration(
                border: Border.all(color: debugTileBorderColor, width: 1),
                color: debugBackground?.withOpacity(0.05),
              ),
            ),
          ),
        );
      }

      final isSelected = selectedIndices.contains(i);
      widgets.add(
        _BuildDroppableTile(
          key: ValueKey('diamond-$i'),
          dx: dx,
          dy: dy,
          spacing: spacing,
          index: i,
          diamondSize: diamondSize,
          borderColor: borderColor,
          borderWidth: borderWidth,
          baseFillColor: fillColor,
          isSelected: isSelected,
          selectionMode: selectionMode,
          dropEnabled: dropEnabled,
          buildHighlightFill: buildHighlightFill,
          onTapIndex: onTapIndex,
          onItemDropped: onItemDropped,
          child: _buildChild(context, i),
        ),
      );
    }
    final stackChildren = <Widget>[...underlays, ...widgets];
    if (debug) {
      // Outer bounding box overlay
      stackChildren.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: debugOuterBorderColor, width: 1.5),
                color: debugBackground?.withOpacity(0.04),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: debug && debugBackground != null ? debugBackground!.withOpacity(0.02) : null,
      child: Stack(children: stackChildren),
    );
  }

  Widget _buildChild(BuildContext context, int index) {
    if (itemBuilder != null) return itemBuilder!(context, index);
    return Text(
      '$index',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}

class _BuildDroppableTile extends StatelessWidget {
  const _BuildDroppableTile({
    super.key,
    required this.dx,
    required this.dy,
    required this.spacing,
    required this.index,
    required this.diamondSize,
    required this.borderColor,
    required this.borderWidth,
    required this.baseFillColor,
    required this.isSelected,
    required this.selectionMode,
    required this.dropEnabled,
    required this.buildHighlightFill,
    required this.onTapIndex,
    required this.onItemDropped,
    required this.child,
  });

  final double dx;
  final double dy;
  final double spacing;
  final int index;
  final double diamondSize;
  final Color borderColor;
  final double borderWidth;
  final Color baseFillColor;
  final bool isSelected;
  final bool selectionMode;
  final bool dropEnabled;
  final Color Function(int index, bool isSelected, bool isDragHover)? buildHighlightFill;
  final ValueChanged<int>? onTapIndex;
  final void Function(int index, Object data)? onItemDropped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Build the interactive tile using candidate list length for hover state.
    return Transform.translate(
      offset: Offset(dx, dy),
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) => dropEnabled,
        onAcceptWithDetails: (details) {
          if (!dropEnabled) return;
          onItemDropped?.call(index, details.data);
        },
        builder: (context, candidate, rejected) {
          final isHover = dropEnabled && candidate.isNotEmpty;
          final fill = buildHighlightFill?.call(index, isSelected, isHover) ??
              (isSelected
                  ? Colors.amberAccent.withOpacity(0.7)
                  : isHover
                      ? baseFillColor.withOpacity(0.6)
                      : baseFillColor);
          return Padding(
            padding: EdgeInsets.all(spacing / 2),
            child: DiamondTile(
              size: diamondSize,
              borderColor: borderColor,
              borderWidth: borderWidth,
              fillColor: fill,
              onTap: onTapIndex == null ? null : () => onTapIndex!(index),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
