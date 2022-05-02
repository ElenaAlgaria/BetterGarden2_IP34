import 'package:biodiversity/components/edit_dialog.dart';
import 'package:biodiversity/components/white_redirect_page.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/account_page/account_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Displays a page where the user can change their Password
class ChangePasswordPage extends StatefulWidget {
  ///Displays a page where the user can change their Password
  ChangePasswordPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordPage();
}

class _ChangePasswordPage extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _curPassword;
  String _firstPassword;
  String _secondPassword;

  @override
  Widget build(BuildContext context) {
    return EditDialog(
      title: 'Passwort ändern',
      abortCallback: () => Navigator.of(context).pop(),
      saveCallback: () async {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          if (_firstPassword != _secondPassword) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Die neuen Passwörter stimmen nicht überein')));
          } else {
            final _responseAnswer =
                await Provider.of<User>(context, listen: false).changePassword(
                    oldPassword: _curPassword, newPassword: _firstPassword);
            if (_responseAnswer == null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WhiteRedirectPage(
                          'Das neue Passwort wurde gesetzt', AccountPage())));
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$_responseAnswer')));
            }
          }
        }
      },
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                onSaved: (value) => _curPassword = value,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte gib ein Passwort ein';
                  } else {
                    return null;
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Aktuelles Passwort',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                onSaved: (value) => _firstPassword = value,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte gib ein Passwort ein';
                  } else {
                    return null;
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                onSaved: (value) => _secondPassword = value,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Bitte gib ein Passwort ein';
                  } else {
                    return null;
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort wiederholen',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
