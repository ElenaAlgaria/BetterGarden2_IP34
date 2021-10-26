import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/image_picker_page.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/account_page/account_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

///Displays a page where the user can change their profile information
class EditProfilePage extends StatefulWidget {
  ///Displays a page where the user can change their profile information
  EditProfilePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _surname;
  String _nickname;
  String _email;
  String _imageURL;
  bool _showNameOnMap;
  bool _showGardenImageOnMap;

  @override
  void initState() {
    final user = Provider.of<User>(context, listen: false);
    _showNameOnMap = user.showNameOnMap;
    _showGardenImageOnMap = user.showGardenImageOnMap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    return EditDialog(
        title: 'Profil bearbeiten',
        abortCallback: () => Navigator.of(context).pop(),
        saveCallback: () {
          _formKey.currentState.save();
          user.updateUserData(
            newName: _name,
            newSurname: _surname,
            newMail: _email,
            newNickname: _nickname,
            doesShowNameOnMap: _showNameOnMap,
            doesShowGardenImageOnMap: _showGardenImageOnMap,
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WhiteRedirectPage(
                      'Die Profilinformationen wurden angepasst',
                      AccountPage())));
        },
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Image.network(user.imageURL,
                    errorBuilder: (context, error, trace) {
                  return const Icon(
                    Icons.person,
                    size: 80,
                  );
                }),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePickerPage(
                        aspectRatio: 1,
                        originalImageURL: user.imageURL,
                        deleteImageFunction: (toDeleteURL) {
                          ServiceProvider.instance.imageService
                              .deleteImage(imageURL: toDeleteURL);
                        },
                        saveImageFunction: (imageFile) async {
                          _imageURL = await ServiceProvider
                              .instance.imageService
                              .uploadImage(imageFile, 'profilepictures',
                                  filename:
                                      '${user.name}_${user.surname}_${const Uuid().v4()}');
                          user.updateUserData(newImageURL: _imageURL);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WhiteRedirectPage(
                                  'Das Profilbild wurde aktualisiert',
                                  AccountPage()),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Profilbild ändern'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: user.name,
                  decoration: const InputDecoration(
                      labelText: 'Vorname',
                      contentPadding: EdgeInsets.symmetric(vertical: 4)),
                  onSaved: (value) => _name = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  initialValue: user.surname,
                  decoration: const InputDecoration(
                      labelText: 'Nachname',
                      contentPadding: EdgeInsets.symmetric(vertical: 4)),
                  onSaved: (value) => _surname = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  initialValue: user.mail,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      contentPadding: EdgeInsets.symmetric(vertical: 4)),
                  onSaved: (value) => _email = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  initialValue: user.nickname,
                  decoration: const InputDecoration(
                      labelText: 'Benutzername',
                      contentPadding: EdgeInsets.symmetric(vertical: 4)),
                  onSaved: (value) => _nickname = value,
                ),
              ),
              SwitchListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: const Text('Benutzername auf Karte anzeigen'),
                  value: _showNameOnMap,
                  onChanged: (value) => {
                        setState(() => {_showNameOnMap = value})
                      }),
              SwitchListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: const Text('Bild des Gartens auf Karte anzeigen'),
                  value: _showGardenImageOnMap,
                  onChanged: (value) => {
                        setState(() => {_showGardenImageOnMap = value})
                      }),
            ],
          ),
        ));
  }
}
