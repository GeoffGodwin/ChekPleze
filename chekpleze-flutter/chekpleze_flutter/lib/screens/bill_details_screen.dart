import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chekpleze_flutter/app_state.dart';

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('*Subtotal')
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), label: Text('*Total Tax')),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), label: Text('Tip')),
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), label: Text('*Total')),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const ElevatedButton(onPressed: null, child: Text('Add Custom Charge')),
                Slider(
                  value: _currentSliderValue,
                  max: 100,
                  divisions: 100,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
                const ElevatedButton(onPressed: null, child: Text('Next'))
              ],
            )
          ],
        )
      ),
      floatingActionButton: defaultTargetPlatform == TargetPlatform.iOS
          ? BackButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(0, 30, 20, 0)),
                  iconSize: MaterialStateProperty.all(30.0)))
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
    );
  }
}
