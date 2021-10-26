import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/login_page/forgot_password_page.dart';
import 'package:biodiversity/screens/login_page/register_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays the page where a user can login with an email and password
class EmailLoginPage extends StatelessWidget {
  /// Displays the page where a user can login with an email and password
  EmailLoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Email Login',
      children: [
        EmailForm(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage())),
                child: const Text('Sign-Up')),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage())),
                child: const Text('Passwort vergessen?')),
          ],
        ),
      ],
    );
  }
}

/// Display the email form with the Login button
/// created in order to get the Scaffold
class EmailForm extends StatefulWidget {
  /// Display the email form with the Login button
  EmailForm({Key key}) : super(key: key);

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
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
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'laura.muster@mail.ch',
            ),
          ),
          TextFormField(
            onSaved: (value) => _password = value,
            validator: (value) {
              if (value.isEmpty) {
                return 'Bitte geben Sie ein Passwort ein';
              } else {
                return null;
              }
            },
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Passwort', hintText: 'Ihr Passwort'),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () async {
                // save the fields..
                final form = _formKey.currentState;
                if (form.validate()) {
                  form.save();
                  await _loginWithEmail(context);
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(
                  'Login',
                  textScaleFactor: 1.6,
                ),
              )),
        ],
      ),
    );
  }

  Future _loginWithEmail(BuildContext context) async {
    final errorMessage = await Provider.of<User>(context, listen: false)
        .signInWithEmail(_email, _password);
    if (errorMessage == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyGarden()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage.message),
            if (!errorMessage.isEmailConfirmed)
              ElevatedButton(
                onPressed: () => Provider.of<User>(context, listen: false)
                    .sendEmailConfirmation(_email, _password),
                child: const Text('Bestätigungsmail erneut senden'),
              )
          ],
        ),
      ));
    }
  }
}
