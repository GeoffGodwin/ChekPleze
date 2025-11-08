import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/custom_slider_thumb_circle.dart';

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  double _currentSliderValue = 20;
  bool _showTipTextField = false;

  final tip = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the current percentage.
    tip.text = _currentSliderValue.round().toString();
  }

  @override
  void dispose() {
    tip.dispose();
    super.dispose();
  }

  void showTableScreen() {
      Navigator.of(context).pushNamed('/table-screen');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                SizedBox(height: 35.0),
                Row(
                  children: [
                    SizedBox(
                      width: 195,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('*Subtotal')
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 10.0,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 195,
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(), label: Text('*Total Tax')),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 195,
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(), label: Text('Tip')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), label: Text('*Total')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                const ElevatedButton(onPressed: null, child: Text('Add Custom Charge')),
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _showTipTextField = !_showTipTextField;
                    });
                  },
                  child: _showTipTextField ? 
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: tip,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), 
                          hintText: 'Tip Amount'
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _currentSliderValue = double.tryParse(value) ?? _currentSliderValue;
                          _showTipTextField = !_showTipTextField;
                          tip.text = _currentSliderValue.round().toString();
                        });
                      }
                    )
                  )
                  :
                  SliderTheme(
                    data: SliderThemeData(
                      showValueIndicator: ShowValueIndicator.never,
                      thumbShape: CustomSliderThumbCircle(
                        thumbRadius: 15,
                        min: 0,
                        max: 100,
                      )
                    ),
                    child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        tip.text = _currentSliderValue.round().toString();
                      });
                    },
                  ),
                  )
                ),
                ElevatedButton(onPressed: showTableScreen, child: Text('Next'))
              ],
            )
          ],
        )
      ),
      floatingActionButton: defaultTargetPlatform == TargetPlatform.iOS
          ? BackButton(
              style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(0, 30, 20, 0)),
                  iconSize: WidgetStateProperty.all(30.0)))
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
    );
  }
}
