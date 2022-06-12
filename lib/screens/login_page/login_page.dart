import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/login_page/email_login_page.dart';
import 'package:biodiversity/screens/login_page/register_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

final ButtonStyle _buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.white),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    textStyle: MaterialStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 22)));

/// The screen where you can select which method you want to use to sign in
class LoginPage extends StatelessWidget {
  /// The screen where you can select which method you want to use to sign in
  LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Login',
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Login mit',
          textScaleFactor: 1.5,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => EmailLoginPage())),
          style: _buttonStyle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(flex: 1, child: Icon(FontAwesomeIcons.envelope)),
              Expanded(
                  flex: 9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('E-mail'),
                    ],
                  )),
            ],
          ),
        ),
        (defaultTargetPlatform == TargetPlatform.iOS)
            ? SignInButton(
                signInFunction:
                    Provider.of<User>(context, listen: false).signInWithApple,
                name: 'Apple',
                icon: FontAwesomeIcons.apple)
            : SignInButton(
                name: 'Google',
                icon: FontAwesomeIcons.google,
                signInFunction:
                    Provider.of<User>(context, listen: false).signInWithGoogle,
              ),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterPage()));
            },
            child: const Text('Registrieren', style: TextStyle(fontSize: 18))),
      ],
    );
  }
}

/// Class to create simple Sign in Buttons.
/// New context needed to work with Snackbar
class SignInButton extends StatelessWidget {
  /// Function which is used to sign in with the corresponding provider
  final Function() signInFunction;

  /// Label wich provider this button represents
  final String name;

  /// Icon of the provider
  final IconData icon;

  /// Creates a ElevatedButton With the provided icon and text
  SignInButton(
      {@required this.signInFunction,
      @required this.name,
      @required this.icon,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: _buttonStyle,
      onPressed: () => _handleSignIn(context, signInFunction: signInFunction),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: Icon(icon)),
          Expanded(
              flex: 9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context,
      {@required Function() signInFunction}) async {
    final result = await signInFunction();
    if (result == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyGarden()));
    } else {
      if (!result.isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Du bist noch nicht registriert mit deinem account.\n'
                'Bitte registriere dich zuerst, bevor du dich anmeldest.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message),
        ));
      }
    }
  }
}
