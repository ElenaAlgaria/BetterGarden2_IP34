import 'dart:async';
import 'dart:typed_data';

import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/select_image_for_garden.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/screens/map_page/maps_submap_widget.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// This page handles the edit of an existing garden
class MyGardenEdit extends StatefulWidget {
  /// This page handles the edit of an existing garden
  MyGardenEdit({Key key}) : super(key: key);

  @override
  _MyGardenEditState createState() => _MyGardenEditState();
}

class _MyGardenEditState extends State<MyGardenEdit> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _gartenType = '';
  String _selectedType;
  String _address;
  bool _deleteRequested = false;
  bool _saveRequested = false;
  Uint8List _toSaveImage;

  final _gardenType = [
    'Familiengarten',
    'Hausgarten',
    'Dachgarten',
    'Balkon / Terrase',
    'Gemeinschaftsgarten',
    'Innenhof'
  ];

  @override
  void initState() {
    Provider.of<MapInteractionContainer>(context, listen: false).reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _toDeleteURL;
    Timer _timer;
    final garden = Provider.of<Garden>(context, listen: false);
    final mapInteractions = Provider.of<MapInteractionContainer>(context);
    if (garden.gardenType != null && _gardenType.contains(garden.gardenType)) {
      _selectedType = garden.gardenType;
    }

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
        //update Image & delete old if necessary
        _formKey.currentState.save();
        garden.name = _name;
        garden.street = _address;
        garden.gardenType = _gartenType;
        if (selLoc != null) {
          garden.coordinates = GeoPoint(selLoc.latitude, selLoc.longitude);
        }
        garden.saveGarden();
        Navigator.of(context).pop();
      },
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(garden.name + ' bearbeiten',
                  style: const TextStyle(fontSize: 20.0)),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  initialValue: garden.name,
                  decoration: const InputDecoration(
                      labelText: 'Spitzname Garten',
                      contentPadding: EdgeInsets.symmetric(vertical: 4)),
                  onSaved: (value) => _name = value,
                ),
              ),
              const SizedBox(),

              const Padding(
                padding: EdgeInsets.only(left: 20, bottom: 5.0),
                child: Text('Gartentyp'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedType,
                      items: _gardenType.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      onChanged: (value) => {
                        setState(() {
                          _gartenType = value;
                          _selectedType = value;
                        }),
                      },
                      hint: const Text('Garten auswählen'),
                    ),
                  ),
                ),
              ),

              const SizedBox(),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  key: Key(mapInteractions.lastSelectedAddress),
                  initialValue:
                      mapInteractions.lastSelectedAddress ?? garden.street,
                  decoration: const InputDecoration(
                      labelText: 'Garten Adresse',
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
              ),
              SubMap(
                  initialPosition:
                      garden.getLatLng(), initialPositionWithAddress: garden.getLatLng()),
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
              ),
              //Show minimap of Garden
            ],
          ),
        ),
      ),
    );
  }
}
