import 'package:redux/redux.dart';

class AppState {
  final List<String> _guests;

  List<String> get getGuests => _guests;

  AppState(this._guests);
  AppState.initialState() : _guests = ["Me", "Myself", "I"];
}

class AddGuestAction {
  final String guest;

  AddGuestAction(this.guest);
}

class RemoveGuestAction {
  final String guest;

  RemoveGuestAction(this.guest);
}

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
  return AppState(allReducers(state._guests, action));
}
