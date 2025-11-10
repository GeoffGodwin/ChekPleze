import 'package:chekpleze_flutter/view-widgets/diamond_two_row_lattice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';

class TableScreen extends StatelessWidget {
  const TableScreen({super.key});

  void _showReceiptScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/receipt-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table')), // Optional, helps navigation.
      body: SafeArea(
        child: StoreConnector<AppState, List<String>>(
          converter: (store) => store.state.getGuests,
          builder: (context, guests) {
            final store = StoreProvider.of<AppState>(context);
            final state = store.state;
            final isReady = state.isDraftValid;
            final lattice = DiamondTwoRowLattice(
              count: guests.length,
              diamondSize: 140,
              spacing: 8,
              borderColor: Colors.red,
              borderWidth: 2,
              fillColor: Colors.white,
              itemBuilder: (context, i) => _SeatLabel(name: guests[i]),
              onTapIndex: state.assigning
                  ? (i) => store.dispatch(ToggleAssignSeatAction(i))
                  : (i) => debugPrint('Tapped ${guests[i]}'),
              dropEnabled: isReady,
              onItemDropped: (i, data) {
                if (data is _DraftPayload) {
                  store.dispatch(DirectAssignItemToSeatAction(
                    name: data.name,
                    price: data.price,
                    seatIndex: i,
                  ));
                }
              },
              selectionMode: state.assigning,
              selectedIndices: state.draftSelectedSeats,
              buildHighlightFill: (i, isSelected, isHover) {
                if (isSelected) return Colors.greenAccent.withOpacity(0.6);
                if (isHover) return Colors.amber.withOpacity(0.5);
                return Colors.white;
              },
              debug: true,
              debugTileBounds: true,
              debugOuterBorderColor: Colors.greenAccent,
              debugTileBorderColor: Colors.blueAccent,
              debugBackground: Colors.purple,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            child: TextField(
                              onChanged: (v) => store.dispatch(DraftSetNameAction(v)),
                              decoration: const InputDecoration(
                                labelText: 'Item',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (v) => store.dispatch(DraftSetPriceAction(v)),
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isReady
                                ? () {
                                    if (state.assigning) {
                                      store.dispatch(ConfirmAssignItemAction());
                                    } else {
                                      store.dispatch(EnterAssignModeAction());
                                    }
                                  }
                                : null,
                            child: Text(state.assigning ? 'Confirm' : 'Assign'),
                          ),
                          const SizedBox(width: 12),
                          Opacity(
                            opacity: isReady ? 1.0 : 0.4,
                            child: IgnorePointer(
                              ignoring: !isReady,
                              child: Draggable<_DraftPayload>(
                                data: _DraftPayload(
                                  name: state.draftName,
                                  price: double.tryParse(state.draftPrice) ?? 0.0,
                                ),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Chip(label: Text('${state.draftName} - ${state.draftPrice}')),
                                ),
                                childWhenDragging: const Icon(Icons.drag_indicator, color: Colors.grey),
                                child: const Icon(Icons.drag_indicator),
                              ),
                            ),
                          ),
                          if (state.assigning) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => store.dispatch(CancelAssignModeAction()),
                              child: const Text('Cancel'),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Expanded area: full width; lattice centered horizontally, scrolls horizontally if overflow.
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: lattice,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () => _showReceiptScreen(context),
                    child: const Text('Receipt'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Payload carried during drag operations for a draft item.
class _DraftPayload {
  final String name;
  final double price;
  const _DraftPayload({required this.name, required this.price});
}

// Seat label widget (allows styling & future status icons)
class _SeatLabel extends StatelessWidget {
  final String name;
  const _SeatLabel({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

