import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AddGuest(),
              const GuestList()
            ],
          )
      )
    );
  }
}

class GuestList extends StatelessWidget {
  const GuestList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    void showBillDetailsScreen() {
      Navigator.of(context).pushNamed('/bill-details-screen');
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
                child: Text('Guest List', style: TextStyle(fontSize: 20.0))
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black)
                ),
                height: 200,
                child: ListView(
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
                          ))
                      ,
                  ],
                )
              ),
              ElevatedButton(
                onPressed: state.getGuests.length > 1 ? showBillDetailsScreen : null,
                child: const Text('Next'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddGuest extends StatelessWidget {

  AddGuest({
    super.key,
  });

  final guestMax = 12;
  final guestName = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    guestName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: StoreConnector<AppState, List<String>>(
        converter: (store) => store.state.getGuests,
        builder: (context, guests) {
          final store = StoreProvider.of<AppState>(context);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: <Widget>[
              SizedBox(
                width: 200.0,
                child: TextField(
                  controller: guestName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    hintText: 'Add Guest Name',
                  ),
                ),
              ),
              SizedBox(
                width: 150.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: guestName,
                    builder: (context, value, child) {
                      return ElevatedButton(
                        onPressed: guestName.text.isEmpty || guests.length >= guestMax ? null : () {
                          store.dispatch(AddGuestAction(guestName.text));
                          guestName.clear();
                        },
                        child: const Text('Add Guest'),
                      );
                    }
                  )
                )
              ),
              SizedBox(
                width: 150.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: ElevatedButton(
                    onPressed: guests.length >= guestMax ? null : () {
                      store.dispatch(AddGuestAction('Guest ${guests.length + 1}'));
                    },
                    child: const Text('Quick Add'),
                  )
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
