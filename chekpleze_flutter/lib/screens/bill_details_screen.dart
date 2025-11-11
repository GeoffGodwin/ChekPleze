import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:chekpleze_flutter/view-widgets/custom_slider_thumb_circle.dart';
import 'package:chekpleze_flutter/app_state.dart';

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final _subtotalController = TextEditingController();
  final _taxController = TextEditingController();
  final _tipPercentController = TextEditingController();
  final _tipAbsoluteController = TextEditingController();
  // Total is derived; show read-only preview

  bool _editingTipPercent = false;
  final _subtotalFocus = FocusNode();
  final _taxFocus = FocusNode();
  final _tipPercentFocus = FocusNode();
  final _tipAbsoluteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear zero-ish values on focus to make editing easier.
    void clearIfZeroOnFocus(FocusNode node, TextEditingController c) {
      node.addListener(() {
        if (node.hasFocus) {
          final cleaned = c.text.replaceAll(RegExp('[^0-9\.]'), '');
          final val = double.tryParse(cleaned) ?? 0.0;
          if (val == 0.0 && c.text.isNotEmpty) {
            c.clear();
          }
        }
      });
    }
    clearIfZeroOnFocus(_subtotalFocus, _subtotalController);
    clearIfZeroOnFocus(_taxFocus, _taxController);
    clearIfZeroOnFocus(_tipPercentFocus, _tipPercentController);
    clearIfZeroOnFocus(_tipAbsoluteFocus, _tipAbsoluteController);
  }

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
          final subStr = vm.subtotal.toStringAsFixed(2);
          if (_subtotalController.text != subStr) {
            _subtotalController.value = _subtotalController.value.copyWith(
              text: subStr,
              selection: TextSelection.collapsed(offset: subStr.length),
              composing: TextRange.empty,
            );
          }
        }
        if (!_taxFocus.hasFocus) {
          final taxStr = vm.taxTotal.toStringAsFixed(2);
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
        if (!_tipAbsoluteFocus.hasFocus) {
          final tipAbsStr = vm.tipTotal.toStringAsFixed(2);
          if (_tipAbsoluteController.text != tipAbsStr) {
            _tipAbsoluteController.value = _tipAbsoluteController.value.copyWith(
              text: tipAbsStr,
              selection: TextSelection.collapsed(offset: tipAbsStr.length),
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
                            final cleaned = v.replaceAll(RegExp('[^0-9\.]'), '');
                            final val = double.tryParse(cleaned) ?? 0.0;
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
                            final cleaned = v.replaceAll(RegExp('[^0-9\.]'), '');
                            final val = double.tryParse(cleaned) ?? 0.0;
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
                                  final cleaned = v.replaceAll(RegExp('[^0-9\.]'), '');
                                  final pct = double.tryParse(cleaned) ?? vm.tipPercent;
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
                        width: 160,
                        child: TextField(
                          controller: _tipAbsoluteController,
                          focusNode: _tipAbsoluteFocus,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tip Total (\$)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            final cleaned = v.replaceAll(RegExp('[^0-9\.]'), '');
                            final val = double.tryParse(cleaned) ?? 0.0;
                            vm.setTipAbsolute(val);
                          },
                          onSubmitted: (v) {
                            final cleaned = v.replaceAll(RegExp('[^0-9\.]'), '');
                            final val = double.tryParse(cleaned) ?? 0.0;
                            vm.setTipAbsolute(val);
                            // force percent controller update after absolute entry
                            if (!_tipPercentFocus.hasFocus) {
                              final tipPctStr = vm.tipPercent.toStringAsFixed(0);
                              _tipPercentController.value = _tipPercentController.value.copyWith(
                                text: tipPctStr,
                                selection: TextSelection.collapsed(offset: tipPctStr.length),
                                composing: TextRange.empty,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('*Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(vm.grandTotal.toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
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
  final void Function(double) setTipAbsolute;

  _BillVM({
    required this.subtotal,
    required this.taxTotal,
    required this.tipPercent,
    required this.tipTotal,
    required this.grandTotal,
    required this.setSubtotal,
    required this.setTax,
    required this.setTipPercent,
    required this.setTipAbsolute,
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
      setTipAbsolute: (v) => store.dispatch(SetBillTipAbsoluteAction(v)),
    );
  }
}
