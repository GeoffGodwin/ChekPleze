import 'package:chekpleze_flutter/view-widgets/diamond_two_row_lattice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _showReceiptScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/receipt-screen');
  }

  @override
  void dispose() {
    _nameController.dispose();  //Controller for the name of the item
    _priceController.dispose(); //Controller for the price of the item
    super.dispose();
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
            // Keep text fields in sync with Redux state, including after Confirm/Cancel.
            if (_nameController.text != state.draftName) {
              _nameController.value = _nameController.value.copyWith(
                text: state.draftName,
                selection: TextSelection.collapsed(offset: state.draftName.length),
                composing: TextRange.empty,
              );
            }
            if (_priceController.text != state.draftPrice) {
              _priceController.value = _priceController.value.copyWith(
                text: state.draftPrice,
                selection: TextSelection.collapsed(offset: state.draftPrice.length),
                composing: TextRange.empty,
              );
            }
            final lattice = DiamondTwoRowLattice(
              count: guests.length,
              diamondSize: 140,
              cornerRadius: 16,
              spacing: 12,
              borderColor: Colors.red,
              borderWidth: 2,
              fillColor: Colors.white,
              itemBuilder: (context, i) => _SeatLabel(name: guests[i]),
              onTapIndex: state.assigning
                  ? (i) => store.dispatch(ToggleAssignSeatAction(i))
                  : (i) => debugPrint('Tapped ${guests[i]}'),
              dropEnabled: isReady && !state.assigning,
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
                // Assign mode: only show selection color (no hover shading).
                if (state.assigning) {
                  return isSelected
                      ? Colors.greenAccent.withAlpha((0.6 * 255).round())
                      : Colors.white;
                }
                // Drag/drop mode: yellow hover feedback.
                if (isHover) return Colors.amber.withAlpha((0.5 * 255).round());
                return Colors.white;
              },
              showSelectionIcons: state.assigning,
              debug: false,
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
                              controller: _nameController,
                              onChanged: (v) => store.dispatch(DraftSetNameAction(v)),
                              decoration: const InputDecoration(
                                labelText: 'Item',
                                border: OutlineInputBorder(),
                                // Provide standard padding to avoid floating label clipping.
                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _priceController,
                              onChanged: (v) => store.dispatch(DraftSetPriceAction(v)),
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: state.assigning
                                ? (state.draftSelectedSeats.isNotEmpty
                                    ? () => store.dispatch(ConfirmAssignItemAction())
                                    : null)
                                : (isReady
                                    ? () => store.dispatch(EnterAssignModeAction())
                                    : null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.assigning ? const Color(0xFF00E676) : null, // mint green
                              foregroundColor: state.assigning ? Colors.white : null,
                            ),
                            child: Text(state.assigning ? 'Confirm' : 'Assign'),
                          ),
                          const SizedBox(width: 12),
                          // Keep layout stable: show either draggable icon or an X to cancel assign.
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: state.assigning
                                ? IconButton(
                                    tooltip: 'Cancel assign',
                                    onPressed: () => store.dispatch(CancelAssignModeAction()),
                                    icon: const Icon(Icons.close, color: Colors.red),
                                  )
                                : Opacity(
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
                          ),
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

