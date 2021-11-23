import 'dart:math' as math;

import 'package:biodiversity/components/circlesOverview.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/text_field_with_descriptor.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/screens/create_group_page/create_group_page.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/image_service.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// Display the map with the markers
class MapsPage extends StatefulWidget {
  ///garden which should be displayed on map
  final Garden garden;

  /// Display the map with the markers
  MapsPage({Key key, this.garden}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  GoogleMapController mapController;
  LatLng _focusedLocation;
  AnimationController _fabController;
  Garden _tappedGarden = Garden.empty();

  static const List<IconData> icons = [
    Icons.playlist_add,
    Icons.house,
  ];
  var _currentSpecies;
  final double _zoom = 14.0;
  Set<Marker> _markers = {};

  Set<Circle> circles = {};

  List<Species> speciesList = [];

  @override
  void initState() {
    super.initState();
    ServiceProvider.instance.mapMarkerService.getMarkerSet(
        onTapCallback: (element) {
          setState(() {
            _tappedGarden = element;
          });
          displayModalBottomSheetConnectionProject(context);
        }).then((markers) {
      setState(() {
        _markers = markers;
      });
    });
    speciesList =
        ServiceProvider.instance.speciesService.getFullSpeciesObjectList();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void modifyPermieterCircle(String name) {
    if (name != '') {
      addCircle(500);
    } else {
      removeCircle();
    }
  }

  void removeCircle() {
    setState(() {
      circles = <Circle>{};
    });
  }

  void addCircle(radius) {
    var c = Set<Circle>.from(circles);
    var lat = widget.garden.getLatLng().latitude;
    var lon = widget.garden.getLatLng().longitude;
    c.add(Circle(
        circleId: CircleId('circleOneTest'),
        radius: radius.toDouble(),
        center: LatLng(lat, lon),
        fillColor: Color(0x339fc476),
        strokeWidth: 10));
    setState(() {
      circles = c;
    });
  }

  void loadUserLocation() async {
    if (widget.garden == null &&
        Provider.of<MapInteractionContainer>(context, listen: false)
            .selectedLocation ==
            null) {
      await Provider.of<MapInteractionContainer>(context, listen: false)
          .getLocation()
          .then((loc) => {setCurrentLocation(loc)});
    }
  }

  void setCurrentLocation(LatLng loc) async {
    mapController.animateCamera(CameraUpdate.newLatLng(loc));
  }

  @override
  Widget build(BuildContext context) {
    final mapInteraction =
    Provider.of<MapInteractionContainer>(context, listen: false);
    loadUserLocation();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte'),
      ),
      drawer: MyDrawer(),
      body: Stack(
        children: <Widget>[
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
            markers: _markers,
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
            circles: Set<Circle>.from(circles),
          ),
          speciesListWidget(),
          navigateToCreateGroupButton()
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: getWidgetListForAdvFab()
          ..add(
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                if (_fabController.isDismissed) {
                  _fabController.forward();
                } else {
                  _fabController.reverse();
                }
              },
              child: AnimatedBuilder(
                animation: _fabController,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.rotationZ(
                        _fabController.value * 0.75 * math.pi),
                    alignment: FractionalOffset.center,
                    child: Icon(
                      _fabController.isDismissed ? Icons.add : Icons.add,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
      ),
    );
  }

  Widget navigateToCreateGroupButton() {
    return Container(
        margin: EdgeInsets.fromLTRB(250, 0, 0, 0),
        color: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Create new Group',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateProjectPage()),
            );
          },
        ));
  }

  Widget speciesListWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
        child: Container(
            color: Colors.white,
            child: DropdownButton<String>(
              // value: selectedPurpose,
              hint: Text(
                _currentSpecies ?? 'Spezies auswählen',
                style: TextStyle(fontFamily: "Gotham"),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    'Keine',
                    style: TextStyle(fontFamily: "Gotham"),
                  ),
                ),
                ...speciesList.map((species) {
                  return DropdownMenuItem<String>(
                    value: species.name,
                    child: Text(
                      species.name,
                      style: const TextStyle(fontFamily: "Gotham"),
                    ),
                  );
                }).toList()
              ],
              onChanged: (String name) {
                modifyPermieterCircle(name);
                setState(() {
                  _currentSpecies = name;
                });
              },
            )));
  }

  Future<Widget> displayModalBottomSheet(BuildContext context) async {
    return await showModalBottomSheet(
        barrierColor: Colors.transparent,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            )),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.1,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    TextFieldWithDescriptor(
                        'Spitzname Garten', Text(_tappedGarden.name ?? '')),
                    TextFieldWithDescriptor(
                        'Gartentyp', Text(_tappedGarden.gardenType ?? '')),
                    TextFieldWithDescriptor(
                        'Garten Adresse', Text(_tappedGarden.street ?? '')),
                    TextFieldWithDescriptor(
                      'Besitzer',
                      FutureBuilder(
                        future: ServiceProvider.instance.gardenService
                            .getNicknameOfOwner(_tappedGarden),
                        builder: (context, owner) {
                          if (owner.hasData) {
                            return Text(owner.data);
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    CirclesOverview(context, _tappedGarden),
                    const SizedBox(height: 25.0),
                    FutureBuilder(
                      future: _tappedGarden.isShowImageOnGarden(),
                      builder: (context, showGardenImageOnMap) {
                        if (showGardenImageOnMap.hasData &&
                            showGardenImageOnMap.data) {
                          if (_tappedGarden.imageURL.isNotEmpty) {
                            return ImageService().getImageByUrl(
                                _tappedGarden.imageURL,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fitWidth);
                          } else {
                            return const Text('');
                          }
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<Widget> displayModalBottomSheetConnectionProject(BuildContext context) async {
    return await showModalBottomSheet(
        barrierColor: Colors.transparent,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            )),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.1,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 30, 8, 20),
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    Text(
                      "Save the Bees",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextFieldWithDescriptor(
                        'Name des Garten', Text(_tappedGarden.name ?? '')),
                    TextFieldWithDescriptor(
                        'Gardentyp', Text(_tappedGarden.gardenType ?? '')),
                    TextFieldWithDescriptor(
                      'Besitzer',
                      FutureBuilder(
                        future: ServiceProvider.instance.gardenService
                            .getNicknameOfOwner(_tappedGarden),
                        builder: (context, owner) {
                          if (owner.hasData) {
                            return Text(owner.data);
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    CirclesOverview(context, _tappedGarden),
                    const SizedBox(height: 25.0),
                    FutureBuilder(
                      future: _tappedGarden.isShowImageOnGarden(),
                      builder: (context, showGardenImageOnMap) {
                        if (showGardenImageOnMap.hasData &&
                            showGardenImageOnMap.data) {
                          if (_tappedGarden.imageURL.isNotEmpty) {
                            return ImageService().getImageByUrl(
                                _tappedGarden.imageURL,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fitWidth);
                          } else {
                            return const Text('');
                          }
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  List<Widget> getWidgetListForAdvFab() {
    return [
      Container(
        height: 56.0,
        width: 75.0,
        alignment: FractionalOffset.centerLeft,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Interval(0.0, 1.0 - 1 / icons.length / 2.0,
                curve: Curves.easeOut),
          ),
          child: FloatingActionButton(
            heroTag: null,
            tooltip: 'Garten erstellen',
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () {
              ServiceProvider.instance.gardenService.handle_create_garden(
                  context,
                  startingPosition: _focusedLocation);
            },
            child: Icon(icons[1], color: Theme.of(context).backgroundColor),
          ),
        ),
      ),
    ];
  }
}
