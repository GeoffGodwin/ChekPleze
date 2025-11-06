import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final newTableButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    );

     void showGuestScreen() {
      Navigator.of(context).pushNamed('/guest-screen');
    }

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'ChekPleze',
              style: TextStyle(
                fontSize: 60,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: showGuestScreen,
                  style: newTableButtonStyle,
                  child: const Text('New Table'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Load Table'),
                ),
              ],
            )
          ]
        ),
      )
    );
  }
}
