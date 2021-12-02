import 'dart:math' as math;

import 'package:biodiversity/components/circlesOverview.dart';
import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/join_connection_project_popup_button.dart';
import 'package:biodiversity/components/text_field_with_descriptor.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/services/image_service.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

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
  ConnectionProject _tappedConnectionProject = ConnectionProject.empty();

  static const List<IconData> icons = [
    Icons.playlist_add,
    Icons.house,
    Icons.animation_outlined,
    Icons.minimize_rounded
  ];
  var _currentSpecies;
  final double _zoom = 14.0;
  Set<Marker> _markers = {};
  Set<Marker> _markersHistory = {};

  List<Circle> _circles = [];

  List<Species> speciesList = [];

  DocumentReference reference;

  List<Garden> _allGardens = [];

  @override
  void initState() {
    super.initState();

    _allGardens = ServiceProvider.instance.gardenService.getAllGardens();
    for (var g in _allGardens) {
      debugPrint('Test Orange');
      ServiceProvider.instance.mapMarkerService.getGardenMarkerSet(g,
          onTapCallback: (element) {
        setState(() {
          _tappedGarden = element;
        });
        displayModalBottomSheetGarden(context);
      }).then((marker) {
        setState(() {
          _markers.add(marker);
        });
      });
    }

    ServiceProvider.instance.mapMarkerService.getConnectionProjectMarkerSet(
        onTapCallback: (element) {
      setState(() {
        _tappedConnectionProject = element;
      });
      displayModalBottomSheetConnectionProject(context);
      displayConnectionProjectGardensWithCircles(element.reference);
    }).then((markers) {
      setState(() {
        _markers.addAll(markers);
      });
    });

    speciesList =
        ServiceProvider.instance.speciesService.getFullSpeciesObjectList();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void modifyPerimeterCircle(String name) {
    if (name != '') {
      //Todo radius variable
      addCircle(500);
    } else {
      removeCircle();
    }
  }

  void removeCircle() {
    setState(() {
      _circles = [];
    });
  }

  void addCircle(radius) {
    var c = List<Circle>.from(_circles);
    var lat = widget.garden.getLatLng().latitude;
    var lon = widget.garden.getLatLng().longitude;
    c.add(Circle(
        circleId: const CircleId('circleOneTest'),
        radius: radius.toDouble(),
        center: LatLng(lat, lon),
        fillColor: const Color(0x339fc476),
        strokeWidth: 10));
    setState(() {
      _circles = c;
    });
  }

  void displayConnectionProjectGardensWithCircles(
      DocumentReference connectionProjectReferences) {
    _markersHistory = Set<Marker>.of(_markers);

    var connectionProject = ServiceProvider.instance.connectionProjectService
        .getConnectionProjectByReference(connectionProjectReferences);

    var radius = ServiceProvider.instance.speciesService
        .getSpeciesByReference(connectionProject.targetSpecies)
        .radius;

    var gardensOfConnectionProject = connectionProject.gardens.map((element) {
      return ServiceProvider.instance.gardenService
          .getGardenByReference(element);
    }).toList();

    var allGardensNotInProject = _allGardens
        .where((element) => !gardensOfConnectionProject.contains(element))
        .toList();

    debugPrint('allGardensNotInProject.length' +
        allGardensNotInProject.length.toString());
    debugPrint('gardensOfConnectionProject.length' +
        gardensOfConnectionProject.length.toString());

    gardensOfConnectionProject.forEach((element) {
      _circles.add(Circle(
          circleId: CircleId(element.reference.id),
          radius: radius.toDouble(),
          center: LatLng(
              element.getLatLng().latitude, element.getLatLng().longitude),
          fillColor: const Color(0x5232d5f3),
          strokeWidth: 1));

      setJoinableMarkers(element, allGardensNotInProject, radius);
    });
  }

  void setJoinableMarkers(Garden gardenOfConnectionProject,
      List<Garden> gardensToCompareWith, int radius) {
    // Iterate through all gardens to compare them with the garden of the connectionProject
    for (var o in gardensToCompareWith) {
      var distance = Geolocator.distanceBetween(
        o.getLatLng().latitude,
        o.getLatLng().longitude,
        gardenOfConnectionProject.getLatLng().latitude,
        gardenOfConnectionProject.getLatLng().longitude,
      );

      if (distance <= radius * 2 && distance != 0.0) {
        ServiceProvider.instance.mapMarkerService.getJoinableMarker(o,
            onTapCallback: (element) {
          setState(() {
            _tappedGarden = element;
          });
          displayModalBottomSheetGarden(context);
        }).then((marker) {
          setState(() {
            _markers.removeWhere((element) =>
                element.markerId.value == 'garden' + o.reference.id);
            _markers.add(marker);
          });
        });
      }
    }
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
            circles: _circles.toSet(),
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
          ),
          speciesListWidget(),
          navigateToCreateGroupButton()
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: getWidgetsForAdvFab().toList()
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
        margin: const EdgeInsets.fromLTRB(250, 0, 0, 0),
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
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          color: const Color(0xFFE36F00),
          child: DropdownButton<String>(
            icon: const Icon(Icons.emoji_nature, color: Colors.white),
            hint: Text(
              _currentSpecies ?? 'Spezies anzeigen',
              style: const TextStyle(color: Colors.white),
            ),
            iconSize: 24,
            isExpanded: true,
            // value: selectedPurpose,
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
              modifyPerimeterCircle(name);
              setState(() {
                _currentSpecies = name;
              });
            },
          ))
    ]));
  }

  Future<Widget> displayModalBottomSheetGarden(BuildContext context) async {
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
            initialChildSize: 0.2,
            minChildSize: 0.1,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    Icon(Icons.horizontal_rule_rounded,
                        color: Color(0xFFE36F00), size: 34.0),
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

  Future<Widget> displayModalBottomSheetConnectionProject(
      BuildContext context) async {
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
              initialChildSize: 0.18,
              minChildSize: 0.1,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: ListView(
                    controller: scrollController,
                    children: <Widget>[
                      Icon(
                        Icons.horizontal_rule_rounded,
                        color: Color(0xFFE36F00),
                        size: 34.0,

                      ),
                      TextFieldWithDescriptor('Verbindungsprojekt',
                          Text(_tappedConnectionProject.title ?? '')),
                      TextFieldWithDescriptor(
                          'Tierart',
                          Text(ServiceProvider.instance.speciesService
                                  .getSpeciesByReference(
                                      _tappedConnectionProject.targetSpecies)
                                  ?.name ??
                              '')),
                      TextFieldWithDescriptor('Projektbeschreibung',
                          Text(_tappedConnectionProject.description ?? '')),
                      joinConnectionProjectButton(
                          connectionProject: _tappedConnectionProject),
                    ],
                  ),
                );
              });
        }).whenComplete(() => {
          setState(() {
            _markers = Set<Marker>.of(_markersHistory);
            _circles.clear();
          })
        });
  }

  List<Widget> getWidgetsForAdvFab() {
    var containers = <Widget>[];
    containers.add(Container(
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
            ServiceProvider.instance.gardenService.handle_create_garden(context,
                startingPosition: _focusedLocation);
          },
          child: Icon(icons[1], color: Theme.of(context).backgroundColor),
        ),
      ),
    ));

    if (ServiceProvider.instance.gardenService
        .getAllGardensFromUser(Provider.of<User>(context))
        .isNotEmpty) {
      containers.add(Container(
        height: 56.0,
        width: 75.0,
        alignment: FractionalOffset.center,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Interval(0.0, 1.0 - 1 / icons.length / 2.0,
                curve: Curves.easeOut),
          ),
          child: FloatingActionButton(
            heroTag: null,
            tooltip: 'Vernetzungsprojekt erstellen',
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProjectPage(),
                  settings: RouteSettings(
                    arguments: speciesList.firstWhereOrNull(
                            (element) => element.name == _currentSpecies) ??
                        speciesList[2],
                  ),
                ),
              );
            },
            child: Icon(icons[2], color: Theme.of(context).backgroundColor),
          ),
        ),
      ));
    }
    return containers;
  }
}
