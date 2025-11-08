import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Seats()
            ],
          )
      ),
    );
  }
}

class Seats extends StatelessWidget {
  const Seats({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    void showReceiptScreen() {
      Navigator.of(context).pushNamed('/receipt-screen');
    }

    return Expanded(
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Seats', style: TextStyle(fontSize: 20.0))
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black)
                ),
                height: 250,
                child: RowSuper(
                  innerDistance: 8.0,
                  outerDistance: 8.0,
                  children: [
                    ...state.getGuests
                      .asMap()
                      .entries
                      .map((guest) => ListTile(
                            dense: true,
                            iconColor: Colors.red,
                            title: Text(guest.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                            trailing: guest.key > 0
                                ? IconButton(
                                    onPressed: () {
                                      store.dispatch(
                                          RemoveGuestAction(guest.value));
                                    },
                                    icon: const Icon(Icons.close))
                                : null,
                          )
                        )
                      ,
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: showReceiptScreen,
                child: const Text('Receipt'),
              ),
            ],
          );
        },
      ),
    );
  }
}

