import 'package:flutter/material.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newTableButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    );

    void showBillSplitScreen() {
      Navigator.of(context).pushNamed('/bill-split');
    }

    return const Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Guest List goes here',
                  style: TextStyle(
                    fontSize: 60,
                  ),
                ),
              ]),
        ));
  }
}
