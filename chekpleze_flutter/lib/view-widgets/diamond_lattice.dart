import 'package:flutter/material.dart';
import 'diamond_widget.dart';

/// A staggered (offset) lattice of diamond tiles.
///
/// Layout logic:
/// - Each logical row offsets every second row horizontally by half the tile width.
/// - Vertical spacing is chosen so adjacent diamonds touch at their corners if [tight] is true.
/// - Uses a simple Wrap with positioned offsets via Padding.
class DiamondLattice extends StatelessWidget {
  const DiamondLattice({
    super.key,
    required this.count,
    this.diamondSize = 80,
    this.columns = 6,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.fillColor = Colors.white,
    this.cornerRadius = 8.0,
    this.spacing = 8.0,
    this.tight = true,
    this.onTapIndex,
    this.itemBuilder,
    this.templateBuilder,
  });

  /// Total number of diamonds to render.
  final int count;
  /// Base square size before rotation (width == height of bounding box).
  final double diamondSize;
  /// Approximate column count (non-offset rows have this many).
  final int columns;
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;
  /// Rounded corner radius for each diamond tile.
  final double cornerRadius;
  /// Extra spacing around each diamond (outside of the geometric tight packing).
  final double spacing;
  /// If true, vertical spacing is reduced so tips touch; if false regular spacing used.
  final bool tight;
  /// Tap callback with index.
  final ValueChanged<int>? onTapIndex;
  /// Build a per-index child widget to place inside each diamond.
  /// If null, [templateBuilder] is used; if both are null, a fallback index Text is used.
  final IndexedWidgetBuilder? itemBuilder;
  /// Convenience for uniform children: returns a fresh widget instance for each tile.
  final ValueGetter<Widget>? templateBuilder;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox();
  final List<Widget> children = [];
    final rows = (count / columns).ceil();

    // Vertical spacing: for a diamond (rotated square), the effective vertical distance
    // between centers for tight packing is diamondSize / 2. sqrt(2)/2 of square size.
    final verticalStep = tight ? (diamondSize * 0.5) : (diamondSize + spacing);
    final horizontalOffset = diamondSize / 2; // Offset for staggered rows.

    int globalIndex = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns && globalIndex < count; c++) {
        final currentIndex = globalIndex; // capture for closure
        final isOddRow = r.isOdd;
        final dx = isOddRow ? horizontalOffset : 0.0;
        children.add(
          Transform.translate(
            offset: Offset(dx + c * diamondSize, r * verticalStep),
            child: Padding(
              padding: EdgeInsets.all(spacing / 2),
              child: DiamondTile(
                size: diamondSize,
                borderColor: borderColor,
                borderWidth: borderWidth,
                fillColor: fillColor,
                cornerRadius: cornerRadius,
                onTap: onTapIndex == null ? null : () => onTapIndex!(currentIndex),
                child: _buildChild(context, currentIndex),
              ),
            ),
          ),
        );
        globalIndex++;
      }
    }

    // We use a sized box to constrain width. Total width accounts for columns and possible offset.
    final totalWidth = columns * diamondSize + horizontalOffset + spacing;
    final totalHeight = rows * verticalStep + diamondSize; // approximate.

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(children: children),
    );
  }

  Widget _buildChild(BuildContext context, int index) {
    if (itemBuilder != null) return itemBuilder!(context, index);
    if (templateBuilder != null) return templateBuilder!();
    // Fallback: show index number
    return Text(
      '$index',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

/// Simple demo widget you can drop into a screen to visualize the lattice.
class DiamondLatticeDemo extends StatefulWidget {
  const DiamondLatticeDemo({super.key});

  @override
  State<DiamondLatticeDemo> createState() => _DiamondLatticeDemoState();
}

class _DiamondLatticeDemoState extends State<DiamondLatticeDemo> {
  int lastTapped = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DiamondLattice(
          count: 40,
          columns: 6,
          diamondSize: 70,
          tight: true,
          spacing: 4,
          fillColor: Colors.white,
          borderColor: Colors.indigo,
          borderWidth: 2,
          onTapIndex: (i) => setState(() => lastTapped = i),
          // Example: provide per-index child content
          itemBuilder: (context, i) => Text(
            '$i',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lastTapped >= 0 ? 'Tapped: $lastTapped' : 'Tap a diamond',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
