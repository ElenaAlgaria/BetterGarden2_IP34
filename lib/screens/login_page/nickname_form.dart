import 'dart:developer' as logging;

import 'package:biodiversity/components/privacy_agreement.dart';
import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart' as biodiversity_user;
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The page where you can insert your data to register with email and password
class NickNameForm extends StatefulWidget {
  ///The page where you can insert your data to register with email and password
  NickNameForm({Key key}) : super(key: key);

  @override
  _NickNameFormState createState() => _NickNameFormState();
}

class _NickNameFormState extends State<NickNameForm> {
  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Wie sollen wir Sie nennen?',
      logoSize: 0,
      children: [
        RegisterForm(),
      ],
    );
  }
}

/// The form which displays the input fields for the registration
class RegisterForm extends StatefulWidget {
  /// The form which displays the input fields for the registration
  RegisterForm({Key key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _nickname;
  bool _readPrivacyAgreement = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nickname'),
            onSaved: (value) => _nickname = value,
            validator: (value) =>
            value.isEmpty ? 'Bitte ein Nickname eingeben' : null,
          ),

          FormField<bool>(
              key: Key(_readPrivacyAgreement.toString()),
              initialValue: _readPrivacyAgreement,
              onSaved: (value) => _readPrivacyAgreement = value,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final _read = await showPrivacyAgreement(context);
                            setState(() {
                              _readPrivacyAgreement = _read;
                            });
                          },
                          child: const Text(
                              'Ich habe das Privacy-Agreement gelesen'),
                        ),
                        Checkbox(
                          value: field.value,
                          onChanged: (value) => field.didChange(value),
                        )
                      ],
                    ),
                    if (field.hasError)
                      Text(
                        field.errorText,
                        style: TextStyle(
                            color: Theme.of(context).errorColor, fontSize: 12),
                      )
                  ],
                );
              },
              validator: (value) =>
              value ? null : 'Bitte lies das Privacy-Agreement'),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: () => _saveNickname(context).then((value) => null),
            child: const Text('Registrieren'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNickname(BuildContext context) async {
    logging.log(_formKey.toString());
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final errorMessage =
      await Provider.of<biodiversity_user.User>(context, listen: false)
          .saveNickname(nickname: _nickname);
      if (errorMessage == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyGarden()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}
