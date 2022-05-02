import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/login_page/email_login_page.dart';
import 'package:biodiversity/screens/login_page/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page to send a password reset link
class ForgotPasswordPage extends StatefulWidget {
  /// Page to send a password reset link
  ForgotPasswordPage({Key key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String _email;
  final _emailForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Passwort zurücksetzen',
      children: [
        Form(
          key: _emailForm,
          child: Column(
            children: [
              const Text('Um dein Passwort zurückzusetzen,'
                  ' gib deine Email Adresse unten ein.'),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email adresse'),
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte geben Sie eine Email Adresse ein';
                    //match valid email addresses https://stackoverflow.com/a/16888554
                  } else if (!RegExp(
                          "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$")
                      .hasMatch(value)) {
                    return 'Bitte geben Sie eine gültige Email Adresse ein';
                  } else {
                    return null;
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_emailForm.currentState.validate()) {
                    _emailForm.currentState.save();
                    _handleSubmit();
                  }
                },
                child: const Text('Passwort zurücksetzen'),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final accountExists = await Provider.of<User>(context, listen: false)
        .sendPasswordResetLink(_email);
    if (accountExists) {
      showDialog(
              context: context,
              builder: (context) => _showConfirmationDialog(context, _email))
          .then((value) => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => EmailLoginPage())));
    } else {
      showDialog(context: context, builder: _showEmailNotFoundDialog);
    }
  }

  Widget _showConfirmationDialog(BuildContext context, String email) {
    return AlertDialog(
      title: const Text('Email verschickt'),
      content: Column(
        children: [
          Text('Eine Email wurde an deine Mailadresse $email verschickt.'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schliessen'),
        ),
      ],
    );
  }

  Widget _showEmailNotFoundDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Email nicht gefunden'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Die eingegebene Email adresse passt '
              'zu keinem registrierten account.\nStelle sicher, dass du '
              'die Email adresse richtig geschrieben hast.'
              '\nDeine Eingabe: $_email'),
          const SizedBox(height: 10),
          const Text(
              'Falls du noch kein Account hast, registriere dich bitte zuerst.')
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Schliessen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => RegisterPage())),
          child: const Text('Registrieren'),
        )
      ],
    );
  }
}
