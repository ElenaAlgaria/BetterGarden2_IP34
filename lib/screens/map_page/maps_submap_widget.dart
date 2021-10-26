import 'dart:async';

import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// Small Map widget which displays the selection
/// stored in [MapInteractionContainer]
class SubMap extends StatefulWidget {
  /// Small Map widget which displays the selection
  /// stored in [MapInteractionContainer]
  SubMap({this.initialPosition, Key key}) : super(key: key);

  /// [LatLng] Object where the submap should be centered around
  final LatLng initialPosition;

  @override
  _SubMapState createState() => _SubMapState();
}

class _SubMapState extends State<SubMap> {
  Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};

  void loadUserLocation() async {
    final controller = await mapController.future;
    final mapInteraction =
        Provider.of<MapInteractionContainer>(context, listen: false);
    if (mapInteraction.selectedLocation == null) {
      await mapInteraction
          .getLocation()
          .then((loc) => mapInteraction.selectedLocation = loc);
      controller
          .moveCamera(CameraUpdate.newLatLng(mapInteraction.selectedLocation));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapInteraction = Provider.of<MapInteractionContainer>(context);
    loadUserLocation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: FutureBuilder(
            future: mapInteraction.getAddressOfSelectedLocation(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('');
              }
              mapController.future.then((controller) =>
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                      mapInteraction.getCameraPosition())));

              return TextButton.icon(
                onPressed: () =>
                    mapInteraction.lastSelectedAddress = snapshot.data,
                icon: const Icon(Icons.location_on),
                label: Text(
                  snapshot.data,
                  textScaleFactor: 1.3,
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          child: GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => mapController.complete(controller),
            initialCameraPosition: (widget.initialPosition != null)
                ? CameraPosition(
                    target: LatLng(widget.initialPosition.latitude,
                        widget.initialPosition.longitude),
                    zoom: 18.0)
                : mapInteraction.getCameraPosition(),
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.hybrid,
            markers: <Marker>{}..add(Marker(
                position: mapInteraction.selectedLocation ??
                    mapInteraction.defaultLocation,
                markerId: const MarkerId('subMapMarker'))),
            onTap: (pos) {
              mapInteraction.selectedLocation = pos;
              mapController.future.then((controller) =>
                  controller.animateCamera(CameraUpdate.newLatLng(pos)));
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}..add(
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
          ),
        ),
      ],
    );
  }
}
