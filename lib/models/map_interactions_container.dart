import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

/// container class to manage map interactions over different screens.
class MapInteractionContainer extends ChangeNotifier {
  BiodiversityMeasure _element;
  LatLng _selectedLocation;
  String _lastSelectedAddress;

  /// creates a new Container with a element at a given location
  MapInteractionContainer(this._element, this._selectedLocation);

  /// creates an empty Container
  MapInteractionContainer.empty();

  /// a default location if no other location could be evaluated
  final LatLng _defaultLocation = const LatLng(47.516940, 8.025059);

  /// returns a [BiodiversityMeasure] object of the stored element
  BiodiversityMeasure get element => _element;

  /// returns a [LatLng] object of the stored location
  LatLng get selectedLocation => _selectedLocation;

  /// returns the resolved address for the last selected location
  String get lastSelectedAddress => _lastSelectedAddress;

  ///returns a [LatLng] object of the default location
  LatLng get defaultLocation => _defaultLocation;

  /// returns the type of the stored element
  String get type => _element != null ? _element.type : '';

  set element(BiodiversityMeasure element) {
    _element = element;
    notifyListeners();
  }

  set selectedLocation(LatLng value) {
    _selectedLocation = value;
    notifyListeners();
  }

  set lastSelectedAddress(String addr) {
    _lastSelectedAddress = addr;
    notifyListeners();
  }

  /// resets the container to null
  void reset() {
    _element = null;
    _selectedLocation = null;
    _lastSelectedAddress = null;
  }

  /// returns the users current location as LatLng
  /// a default location is returned if no coordinates were found
  Future<LatLng> getLocation() async {
    loc.LocationData currentLocation;
    var location = loc.Location();
    try {
      currentLocation = await location.getLocation();
      return LatLng(currentLocation.latitude, currentLocation.longitude);
    } on Exception {
      return _defaultLocation;
    }
  }

  /// returns the address of the stored coordinates as string.
  /// a default message is returned if no coordinates are stored
  Future<String> getAddressOfSelectedLocation() async {
    if (_selectedLocation == null) {
      return '';
    }
    final placeMark = await placemarkFromCoordinates(
        _selectedLocation.latitude, _selectedLocation.longitude);
    return '${placeMark[0].street}, ${placeMark[0].locality}';
  }

  /// returns the address of the stored coordinates as string.
  /// a default message is returned if no coordinates are stored
  Future<LatLng> getLocationOfAddress(String adr) async {
    if (adr == null || adr.isEmpty) {
      return _defaultLocation;
    }
    var result = _defaultLocation;
    try {
      final location = await locationFromAddress(adr);
      result = LatLng(location.first.latitude, location.first.longitude);
      selectedLocation = result;
    } catch (e) {
      return result;
    }
    return result;
  }

  /// returns a [CameraPosition] which has the stored location in focus
  CameraPosition getCameraPosition() {
    return CameraPosition(
        zoom: 18.0, target: _selectedLocation ?? _defaultLocation);
  }
}
