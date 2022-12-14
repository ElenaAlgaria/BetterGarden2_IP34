import 'package:biodiversity/components/screen_with_logo_and_waves.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Page that handles the registration with apple.
/// The page itself doesn't contain any content
class RegisterApplePage extends StatefulWidget {
  /// Page that handles the registration with apple.
  /// The page itself doesn't contain any content
  RegisterApplePage({Key key}) : super(key: key);

  @override
  _RegisterApplePageState createState() => _RegisterApplePageState();
}

class _RegisterApplePageState extends State<RegisterApplePage> {
  String _errorText;

  @override
  void initState() {
    super.initState();
    _handleRegistration(context);
  }

  @override
  Widget build(BuildContext context) {
    return LogoAndWavesScreen(
      title: 'Registrieren mit Apple',
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
    final registerMessage = await Provider.of<User>(context, listen: false)
        .registerWithApple(context);
    if (registerMessage == null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyGarden()));
    } else {
      setState(() {
        _errorText = 'Currently not implemented';
        // _errorText = registerMessage;
      });
    }
  }
}
