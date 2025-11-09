import 'package:flutter/material.dart';
import 'diamond_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox();
    final columns = (count / 2).ceil();

    final widgets = <Widget>[];
    for (int i = 0; i < count; i++) {
      final currentIndex = i;
      final col = i ~/ 2; // floor(i/2)
      final isTopRow = i % 2 == 0;
      final row = isTopRow ? 0 : 1;

      // Vertical positioning: row0 at y=0, row1 at y=diamondSize * verticalFactor
      final verticalFactor = stagger ? 0.5 : 0.6; // tweak for visual balance
      final dy = row * diamondSize * verticalFactor;

      // Horizontal base position
      double dx = col * diamondSize;
      // Apply stagger horizontal offset to bottom row for lattice look.
      if (stagger && row == 1) {
        dx += diamondSize / 2;
      }

      widgets.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Padding(
            padding: EdgeInsets.all(spacing / 2),
            child: DiamondTile(
              size: diamondSize,
              borderColor: borderColor,
              borderWidth: borderWidth,
              fillColor: fillColor,
              onTap: onTapIndex == null ? null : () => onTapIndex!(currentIndex),
              child: _buildChild(context, currentIndex),
            ),
          ),
        ),
      );
    }

    // Calculate overall width/height needed for the stack.
    final width = columns * diamondSize + (stagger ? diamondSize / 2 : 0) + spacing;
    final height = diamondSize + // top row height
        (count > 1 ? diamondSize * (stagger ? 0.5 : 0.6) : 0) + spacing; // extra for second row

    return SizedBox(
      width: width,
      height: height,
      child: Stack(children: widgets),
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
