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
            final lattice = DiamondTwoRowLattice(
              count: guests.length,
              diamondSize: 140,
              spacing: 8,
              borderColor: Colors.red,
              borderWidth: 2,
              fillColor: Colors.white,
              itemBuilder: (context, i) => Text(
                guests[i],
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              onTapIndex: (i) => debugPrint('Tapped ${guests[i]}'),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Seats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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

