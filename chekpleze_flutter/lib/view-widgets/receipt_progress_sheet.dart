import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';

/// A bottom "receipt paper" stub that shows running total and expands on tap/swipe.
class ReceiptProgressSheet extends StatelessWidget {
  const ReceiptProgressSheet({super.key, this.onOpenFullReceipt});

  /// Called when the user taps or swipes up on the stub to open full receipt view.
  final VoidCallback? onOpenFullReceipt;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ReceiptVM>(
      distinct: true,
      converter: (store) {
        final s = store.state;
        final items = s.items;
        final assignedSubtotal = items.fold<double>(0.0, (sum, it) => sum + it.price);
        // Proportionally allocate tax and tip to show progress toward grand total.
        final sub = s.billSubtotal;
        final tax = s.billTaxTotal;
        final tip = s.billTipTotal;
        final grand = s.billTotal;
        final progressP = sub > 0 ? (assignedSubtotal / sub).clamp(0.0, 1.0) : 0.0;
        final taxSoFar = tax * progressP;
        final tipSoFar = tip * progressP; // proportional for now
        final assignedTotal = assignedSubtotal + taxSoFar + tipSoFar;
        final ratio = grand > 0 ? (assignedTotal / grand).clamp(0.0, 1.0) : 0.0;
        return _ReceiptVM(
          assigned: assignedTotal,
          total: grand,
          ratio: ratio,
        );
      },
      builder: (context, vm) {
        return _PaperStub(
          assigned: vm.assigned,
          total: vm.total,
          ratio: vm.ratio,
          onOpen: onOpenFullReceipt,
        );
      },
    );
  }
}

class _ReceiptVM {
  final double assigned;
  final double total;
  final double ratio;
  const _ReceiptVM({required this.assigned, required this.total, required this.ratio});
}

class _PaperStub extends StatelessWidget {
  final double assigned;
  final double total;
  final double ratio;
  final VoidCallback? onOpen;

  const _PaperStub({
    required this.assigned,
    required this.total,
    required this.ratio,
    this.onOpen,
  });

  String _money(double v) => v.toStringAsFixed(2);

  void _maybeOpen(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
      onOpen?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return GestureDetector(
      onTap: onOpen,
      onVerticalDragEnd: _maybeOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total so far: \$${_money(assigned)} of \$${total > 0 ? _money(total) : '--'}',
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text('${(ratio * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total > 0 ? ratio : null,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
