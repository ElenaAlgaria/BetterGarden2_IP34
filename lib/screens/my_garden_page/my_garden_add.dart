import 'dart:async';
import 'dart:typed_data';

import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/select_image_for_garden.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/map_page/maps_submap_widget.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

///creates a new garden for the user
class MyGardenAdd extends StatefulWidget {
  ///MyGardenAdd constructor
  MyGardenAdd({this.route, this.startingPosition, Key key}) : super(key: key);

  /// the Page which you will be redirected to after the timeout
  final Widget route;

  /// the coordinates where the garden should be created
  final LatLng startingPosition;

  @override
  _MyGardenAddState createState() => _MyGardenAddState();
}

class _MyGardenAddState extends State<MyGardenAdd> {
  final _formKey = GlobalKey<FormState>();
  Timer _timer;
  String _toDeleteURL;
  bool _deleteRequested = false;
  Uint8List _toSaveImage;
  bool _saveRequested = false;
  String _name;
  String _selectedType;
  String _address;
  final _gardenType = [
    'Familiengarten',
    'Hausgarten',
    'Dachgarten',
    'Balkon / Terrasse',
    'Gemeinschaftsgarten',
    'Innenhof'
  ];

  @override
  void initState() {
    Provider.of<MapInteractionContainer>(context, listen: false).reset();
    Provider.of<MapInteractionContainer>(context, listen: false)
        .selectedLocation = widget.startingPosition;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garden = Garden.empty();
    final mapInteractions = Provider.of<MapInteractionContainer>(context);

    return EditDialog(
      title: ('Mein Garten'),
      abortCallback: () {
        Navigator.of(context).pop();
      },
      saveCallback: () async {
        final selLoc = mapInteractions.selectedLocation;
        if (_saveRequested) {
          garden.imageURL = await ServiceProvider.instance.imageService
              .uploadImage(_toSaveImage, 'gardenpictures',
                  filename: '${garden.name}_${const Uuid().v4()}');
        }
        if (_deleteRequested) {
          ServiceProvider.instance.imageService
              .deleteImage(imageURL: _toDeleteURL);
        }
        _formKey.currentState.save();
        final user = Provider.of<User>(context, listen: false);
        if (user.gardens.contains(_name)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Du hast bereits einen Garten mit dem namen $_name.\n'
                'Wähle bitte einen anderen.'),
          ));
        } else {
          garden.name = _name;
          garden.street = _address;
          garden.gardenType = _selectedType ?? '';
          garden.owner = user.userUUID;
          garden.coordinates = (selLoc != null)
              ? GeoPoint(selLoc.latitude, selLoc.longitude)
              : GeoPoint(mapInteractions.defaultLocation.latitude,
                  mapInteractions.defaultLocation.longitude);
          await garden.saveGarden();
          user.addGarden(garden);
          Provider.of<Garden>(context, listen: false).switchGarden(garden);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => WhiteRedirectPage(
                    'Der Garten $_name wurde erstellt.',
                    widget.route ?? MyGarden(),
                    duration: 2,
                  )));
        }
      },
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Garten hinzufügen', style: TextStyle(fontSize: 20.0)),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Spitzname Garten',
                          contentPadding: EdgeInsets.symmetric(vertical: 4)),
                      onSaved: (value) => _name = value,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: Text('Gartentyp',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6))),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          value: _selectedType,
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                          hint: const Text('Garten auswählen'),
                          items: _gardenType.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    TextFormField(
                      key: Key(mapInteractions.lastSelectedAddress),
                      initialValue: mapInteractions.lastSelectedAddress,
                      autofocus: false,
                      decoration: const InputDecoration(
                          labelText: 'Gartenadresse',
                          hintText: 'Strasse Nr, PLZ Ort',
                          contentPadding: EdgeInsets.symmetric(vertical: 4)),
                      onSaved: (value) {
                        _address = value;
                      },
                      onChanged: (value) {
                        _timer?.cancel();
                        _timer = Timer(const Duration(milliseconds: 1000),
                            () => mapInteractions.getLocationOfAddress(value));
                      },
                    ),
                  ],
                ),
              ),
              SubMap(initialPosition: mapInteractions.selectedLocation),
              const SizedBox(height: 20),
              SelectGardenImage(
                deleteFunction: (toDeleteURL) {
                  _toDeleteURL = toDeleteURL;
                  _deleteRequested = true;
                },
                saveFunction: (imageFile) {
                  setState(() {
                    _toSaveImage = imageFile;
                    _saveRequested = true;
                  });
                  Navigator.of(context).pop();
                },
                toSaveImage: _toSaveImage,
                garden: garden,
                displayText: 'Gartenbild hinzufügen',
              ),
              //Show minimap of Garden
            ],
          ),
        ),
      ),
    );
  }
}
