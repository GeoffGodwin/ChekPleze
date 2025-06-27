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
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AddGuest(),
              const GuestList()
            ],
          )
        )
      ),
      floatingActionButton: defaultTargetPlatform == TargetPlatform.iOS ?
        BackButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(0, 30, 20, 0)),
            iconSize: MaterialStateProperty.all(30.0)
          )
        ) : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
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
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Guest List')
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black)
                ),
                height: 250,
                width: 300,
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
                      .toList(),
                  ],
                )
              ),
              const SizedBox(height: 20.0,),
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


  final guestName = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    guestName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: TextField(
                controller: guestName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  hintText: 'Add Guest Name',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0,),
          SizedBox(
            width: 150.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: guestName,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: guestName.text.isEmpty ? null : () {
                      store.dispatch(AddGuestAction(guestName.text));
                      guestName.clear();
                    },
                    child: const Text('Add Guest'),
                  );
                }
              )
            )
          ),
        ],
      ),
    );
  }
}
