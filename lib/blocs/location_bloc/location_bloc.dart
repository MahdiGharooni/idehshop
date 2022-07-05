import 'package:idehshop/blocs/bloc.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  double lat;
  double lng;
  bool locationWasChosenAddStore = false; // add store
  bool locationWasChosenAddLocation = false;

  LocationBloc() : super(null);

  LocationState get initialState => UninitializedLocationState();

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    if (event is MarkerMovedLocationEvent) {
      yield ShowLoadingLocationState();
      lat = event.lat;
      lng = event.lng;
      locationWasChosenAddLocation = true;
      locationWasChosenAddStore = true;
      yield SetNewLocationLocationState();
    }
  }
}
