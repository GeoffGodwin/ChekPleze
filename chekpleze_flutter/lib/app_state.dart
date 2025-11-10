import 'package:redux/redux.dart';

// -------- Models --------

class BillItem {
  final String id;
  final String name;
  final double price;
  final List<int> seatIndices; // indices of seats this item is assigned to

  BillItem({
    required this.id,
    required this.name,
    required this.price,
    required this.seatIndices,
  });
}

class AppState {
  final List<String> _guests;
  final List<BillItem> items;
  // Draft item fields (kept in Redux so UI can rebuild everywhere consistently)
  final String draftName;
  final String draftPrice; // raw text, parse lazily
  final bool assigning; // selection mode active
  final Set<int> draftSelectedSeats;
  // Bill details (set from BillDetailsScreen)
  final double billSubtotal; // pre-tax amount
  final double billTaxTotal; // absolute tax amount
  final double billTipPercent; // tip percent (0-100), applied on (subtotal + tax)

  List<String> get getGuests => _guests;
  bool get isDraftValid => draftName.trim().isNotEmpty && double.tryParse(draftPrice) != null;

  AppState(
    this._guests, {
    this.items = const [],
    this.draftName = '',
    this.draftPrice = '',
    this.assigning = false,
    Set<int>? draftSelectedSeats,
    this.billSubtotal = 0.0,
    this.billTaxTotal = 0.0,
    this.billTipPercent = 0.0,
  }) : draftSelectedSeats = draftSelectedSeats ?? <int>{};

  AppState.initialState()
      : _guests = ["Me", "Myself", "I"],
        items = const [],
        draftName = '',
        draftPrice = '',
        assigning = false,
        draftSelectedSeats = <int>{},
        billSubtotal = 0.0,
        billTaxTotal = 0.0,
        billTipPercent = 20.0;

  AppState copyWith({
    List<String>? guests,
    List<BillItem>? items,
    String? draftName,
    String? draftPrice,
    bool? assigning,
    Set<int>? draftSelectedSeats,
    double? billSubtotal,
    double? billTaxTotal,
    double? billTipPercent,
  }) => AppState(
        guests ?? _guests,
        items: items ?? this.items,
        draftName: draftName ?? this.draftName,
        draftPrice: draftPrice ?? this.draftPrice,
        assigning: assigning ?? this.assigning,
        draftSelectedSeats: draftSelectedSeats ?? this.draftSelectedSeats,
        billSubtotal: billSubtotal ?? this.billSubtotal,
        billTaxTotal: billTaxTotal ?? this.billTaxTotal,
        billTipPercent: billTipPercent ?? this.billTipPercent,
      );

  // Computed bill values
  double get billTipTotal => (billSubtotal + billTaxTotal) * (billTipPercent / 100.0);
  double get billTotal => billSubtotal + billTaxTotal + billTipTotal;
}

class AddGuestAction {
  final String guest;

  AddGuestAction(this.guest);
}

class RemoveGuestAction {
  final String guest;

  RemoveGuestAction(this.guest);
}

// Draft item actions
class DraftSetNameAction { final String name; DraftSetNameAction(this.name); }
class DraftSetPriceAction { final String price; DraftSetPriceAction(this.price); }
class DraftClearAction {}

// Selection / assign mode
class EnterAssignModeAction {}
class CancelAssignModeAction {}
class ToggleAssignSeatAction { final int seatIndex; ToggleAssignSeatAction(this.seatIndex); }

// Persist item(s)
class ConfirmAssignItemAction {}
class DirectAssignItemToSeatAction {
  final String name;
  final double price;
  final int seatIndex;
  DirectAssignItemToSeatAction({required this.name, required this.price, required this.seatIndex});
}

// Bill details actions
class SetBillSubtotalAction { final double value; SetBillSubtotalAction(this.value); }
class SetBillTaxTotalAction { final double value; SetBillTaxTotalAction(this.value); }
class SetBillTipPercentAction { final double value; SetBillTipPercentAction(this.value); }

class GetGuestAction {
  final List<String> guests;

  GetGuestAction(this.guests);
}

List<String> getGuestsReducer(List<String> guests, GetGuestAction action) {
  return action.guests;
}

List<String> addGuestReducer(List<String> guests, AddGuestAction action) {
  return List.from(guests)..add(action.guest);
}

List<String> removeGuestReducer(List<String> guests, RemoveGuestAction action) {
  return List.from(guests)..remove(action.guest);
}

int getCounterReducer(int counter, dynamic action) {
  return action.counter;
}

Reducer<List<String>> allReducers = combineReducers<List<String>>([
  TypedReducer<List<String>, GetGuestAction>(getGuestsReducer).call,
  TypedReducer<List<String>, AddGuestAction>(addGuestReducer).call,
  TypedReducer<List<String>, RemoveGuestAction>(removeGuestReducer).call,
]);

AppState appStateReducer(AppState state, dynamic action) {
  // First reduce guests
  final guests = allReducers(state._guests, action);

  // Draft field mutations
  if (action is DraftSetNameAction) {
    return state.copyWith(guests: guests, draftName: action.name);
  } else if (action is DraftSetPriceAction) {
    return state.copyWith(guests: guests, draftPrice: action.price);
  } else if (action is DraftClearAction) {
    return state.copyWith(
      guests: guests,
      draftName: '',
      draftPrice: '',
      assigning: false,
      draftSelectedSeats: <int>{},
    );
  } else if (action is EnterAssignModeAction) {
    if (!state.isDraftValid) return state; // ignore if invalid
    return state.copyWith(guests: guests, assigning: true, draftSelectedSeats: <int>{});
  } else if (action is CancelAssignModeAction) {
    return state.copyWith(assigning: false, draftSelectedSeats: <int>{});
  } else if (action is ToggleAssignSeatAction) {
    if (!state.assigning) return state;
    final set = Set<int>.from(state.draftSelectedSeats);
    if (set.contains(action.seatIndex)) {
      set.remove(action.seatIndex);
    } else {
      set.add(action.seatIndex);
    }
    return state.copyWith(draftSelectedSeats: set);
  } else if (action is ConfirmAssignItemAction) {
    if (!state.assigning || !state.isDraftValid || state.draftSelectedSeats.isEmpty) return state;
    final price = double.parse(state.draftPrice);
    final newItem = BillItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: state.draftName.trim(),
      price: price,
      seatIndices: state.draftSelectedSeats.toList()..sort(),
    );
    final newItems = [...state.items, newItem];
    return state.copyWith(
      items: newItems,
      draftName: '',
      draftPrice: '',
      assigning: false,
      draftSelectedSeats: <int>{},
    );
  } else if (action is DirectAssignItemToSeatAction) {
    final newItem = BillItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: action.name.trim(),
      price: action.price,
      seatIndices: [action.seatIndex],
    );
    return state.copyWith(
      guests: guests,
      items: [...state.items, newItem],
      draftName: '',
      draftPrice: '',
      assigning: false,
      draftSelectedSeats: <int>{},
    );
  } else if (action is SetBillSubtotalAction) {
    return state.copyWith(guests: guests, billSubtotal: action.value);
  } else if (action is SetBillTaxTotalAction) {
    return state.copyWith(guests: guests, billTaxTotal: action.value);
  } else if (action is SetBillTipPercentAction) {
    final pct = action.value.clamp(0.0, 100.0);
    return state.copyWith(guests: guests, billTipPercent: pct);
  }

  // Default passthrough (only guests changed or unrelated action)
  return state.copyWith(guests: guests);
}
