import 'package:flutter/material.dart';

class SeatTotalScreen extends StatelessWidget {
  const SeatTotalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    height: 250,
                    width: 500,
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Seat 8: (\$17.55)"),
                            Text("Heineken: (\$3.60)"),
                            Text("Monster Burger: (\$13.95)"),
                            SizedBox(
                              height: 25
                            ),
                            Text("Subtotal: (\$17.55)"),
                            Text("4.5% Tax: \$0.79"),
                            Text("20% Tip: \$3.51"),
                            SizedBox(
                              height: 25
                            ),
                            Text("Total: \$21.85")
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red
                                )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 10.0,
              children: [
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Share'),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Zelle/Venmo'),
                ),
                SizedBox(
                  height: 40
                ),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Rename Seat'),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Combined Seat'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Remove Seat'),
                ),
              ]
            )
          ]
        ),
      )
    );
  }
}