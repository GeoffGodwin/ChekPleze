import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../utils/custom_slider_thumb_circle.dart';
import '../app_state.dart';

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final _subtotalController = TextEditingController();
  final _taxController = TextEditingController();
  final _tipPercentController = TextEditingController();
  // Total is derived; show read-only preview

  bool _editingTipPercent = false;
  final _subtotalFocus = FocusNode();
  final _taxFocus = FocusNode();
  final _tipPercentFocus = FocusNode();

  @override
  void dispose() {
    _subtotalController.dispose();
    _taxController.dispose();
    _tipPercentController.dispose();
    _subtotalFocus.dispose();
    _taxFocus.dispose();
    _tipPercentFocus.dispose();
    super.dispose();
  }

  void _goToTable() => Navigator.of(context).pushNamed('/table-screen');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _BillVM>(
      distinct: true,
      converter: (store) => _BillVM.fromStore(store),
      builder: (context, vm) {
        // Update controllers from store ONLY when field is not focused (prevents keystroke override).
        if (!_subtotalFocus.hasFocus) {
          final subStr = vm.subtotal.toString();
          if (_subtotalController.text != subStr) {
            _subtotalController.value = _subtotalController.value.copyWith(
              text: subStr,
              selection: TextSelection.collapsed(offset: subStr.length),
              composing: TextRange.empty,
            );
          }
        }
        if (!_taxFocus.hasFocus) {
          final taxStr = vm.taxTotal.toString();
          if (_taxController.text != taxStr) {
            _taxController.value = _taxController.value.copyWith(
              text: taxStr,
              selection: TextSelection.collapsed(offset: taxStr.length),
              composing: TextRange.empty,
            );
          }
        }
        if (!_tipPercentFocus.hasFocus && !_editingTipPercent) {
          final tipPctStr = vm.tipPercent.toStringAsFixed(0);
          if (_tipPercentController.text != tipPctStr) {
            _tipPercentController.value = _tipPercentController.value.copyWith(
              text: tipPctStr,
              selection: TextSelection.collapsed(offset: tipPctStr.length),
              composing: TextRange.empty,
            );
          }
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Bill Details')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _subtotalController,
                          focusNode: _subtotalFocus,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '*Subtotal', border: OutlineInputBorder()),
                          onChanged: (v) {
                            final val = double.tryParse(v) ?? 0.0;
                            vm.setSubtotal(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _taxController,
                          focusNode: _taxFocus,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '*Total Tax', border: OutlineInputBorder()),
                          onChanged: (v) {
                            final val = double.tryParse(v) ?? 0.0;
                            vm.setTax(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _editingTipPercent
                            ? TextField(
                                controller: _tipPercentController,
                                focusNode: _tipPercentFocus,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Tip %', border: OutlineInputBorder()),
                                onSubmitted: (v) {
                                  final pct = double.tryParse(v) ?? vm.tipPercent;
                                  vm.setTipPercent(pct);
                                  setState(() => _editingTipPercent = false);
                                },
                              )
                            : GestureDetector(
                                onDoubleTap: () => setState(() => _editingTipPercent = true),
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    showValueIndicator: ShowValueIndicator.never,
                                    thumbShape: CustomSliderThumbCircle(
                                      thumbRadius: 15,
                                      min: 0,
                                      max: 100,
                                    ),
                                  ),
                                  child: Slider(
                                    value: vm.tipPercent.clamp(0.0, 100.0),
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label: vm.tipPercent.round().toString(),
                                    onChanged: (val) => vm.setTipPercent(val),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tip Total',
                            border: const OutlineInputBorder(),
                            hintText: vm.tipTotal.toStringAsFixed(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '*Total',
                        border: const OutlineInputBorder(),
                        hintText: vm.grandTotal.toStringAsFixed(2),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _goToTable,
                      child: const Text('Next'),
                    ),
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: defaultTargetPlatform == TargetPlatform.iOS
              ? BackButton(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(0, 30, 20, 0)),
                      iconSize: WidgetStateProperty.all(30.0)))
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        );
      },
    );
  }
}

class _BillVM {
  final double subtotal;
  final double taxTotal;
  final double tipPercent;
  final double tipTotal;
  final double grandTotal;
  final void Function(double) setSubtotal;
  final void Function(double) setTax;
  final void Function(double) setTipPercent;

  _BillVM({
    required this.subtotal,
    required this.taxTotal,
    required this.tipPercent,
    required this.tipTotal,
    required this.grandTotal,
    required this.setSubtotal,
    required this.setTax,
    required this.setTipPercent,
  });

  factory _BillVM.fromStore(Store<AppState> store) {
    final s = store.state;
    return _BillVM(
      subtotal: s.billSubtotal,
      taxTotal: s.billTaxTotal,
      tipPercent: s.billTipPercent,
      tipTotal: s.billTipTotal,
      grandTotal: s.billTotal,
      setSubtotal: (v) => store.dispatch(SetBillSubtotalAction(v)),
      setTax: (v) => store.dispatch(SetBillTaxTotalAction(v)),
      setTipPercent: (v) => store.dispatch(SetBillTipPercentAction(v)),
    );
  }
}
