import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMaps_Factory extends StatefulWidget {
  final Set<Marker> markers;
  final List<Circle> circles;
  final Garden garden;

  const GoogleMaps_Factory({Key key, this.markers, this.circles, this.garden})
      : super(key: key);

  @override
  _GoogleMaps_Factory createState() => _GoogleMaps_Factory();
}

class _GoogleMaps_Factory extends State<GoogleMaps_Factory> {

  final double _zoom = 14.0;
  LatLng _focusedLocation;

  @override
  Widget build(BuildContext context) {
    GoogleMapController mapController;
    final mapInteraction =
        Provider.of<MapInteractionContainer>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Karte'),
        ),
        drawer: MyDrawer(),
        body: Stack(children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled:
                (defaultTargetPlatform == TargetPlatform.iOS) ? false : true,
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: (widget.garden != null)
                ? CameraPosition(target: widget.garden.getLatLng(), zoom: _zoom)
                : (mapInteraction.selectedLocation != null)
                    ? CameraPosition(
                        target: mapInteraction.selectedLocation, zoom: _zoom)
                    : CameraPosition(
                        target: mapInteraction.defaultLocation,
                        zoom: _zoom,
                      ),
            zoomControlsEnabled: false,
            rotateGesturesEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.hybrid,
            markers: widget.markers,
            circles: widget.circles.toSet(),
            onCameraIdle: () {
              mapController.getVisibleRegion().then((bounds) {
                final lat =
                    (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
                final long =
                    (bounds.southwest.longitude + bounds.northeast.longitude) /
                        2;
                _focusedLocation = LatLng(lat, long);
              });
            },
            onTap: (pos) {
              Provider.of<MapInteractionContainer>(context, listen: false)
                  .selectedLocation = pos;
            },
          )
        ]));
  }
}
