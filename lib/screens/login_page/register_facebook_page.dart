import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The page where you can register with your facebook account
class RegisterFacebookPage extends StatefulWidget {
  /// The page where you can register with your facebook account
  RegisterFacebookPage({Key key}) : super(key: key);

  @override
  _RegisterFacebookPageState createState() => _RegisterFacebookPageState();
}

class _RegisterFacebookPageState extends State<RegisterFacebookPage> {
  String _errorText;

  @override
  void initState() {
    super.initState();
    _handleRegistration(context);
  }

  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Registrieren mit Facebook',
      children: [
        const SizedBox(height: 20),
        if (_errorText != null)
          Text(
            _errorText,
            textScaleFactor: 1.2,
            style: const TextStyle(color: Colors.red),
          ),
        if (_errorText != null) const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _handleRegistration(context),
          child: const Text('Registrieren'),
        ),
      ],
    );
  }

  Future<void> _handleRegistration(BuildContext context) async {
    final result = await Provider.of<User>(context, listen: false)
        .registerWithFacebook(context);
    if (result == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyGarden()));
    } else {
      setState(() {
        _errorText = result;
      });
    }
  }
}
