import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/text_field_with_descriptor.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/account_page/account_delete_page.dart';
import 'package:biodiversity/screens/account_page/change_password_page.dart';
import 'package:biodiversity/screens/account_page/edit_profile_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays the page with account information
class AccountPage extends StatefulWidget {
  /// Displays the page with account information
  AccountPage({Key key, ServiceProvider serviceProvider})
      : _service = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  final ServiceProvider _service;

  @override
  _AccountPage createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            color: Theme.of(context).colorScheme.primaryVariant,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: widget._service.imageService.getImageByUrl(
                      user.imageURL,
                      errorWidget: const Icon(Icons.person, size: 60),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        user.name == '' ? user.nickname : user.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      Text(
                        user.mail,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (bc) => [
              PopupMenuItem(
                value: 'EditProfilePage',
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Text('Account bearbeiten')
                  ],
                ),
              ),
              if (user.isRegisteredWithEmail)
                PopupMenuItem(
                  value: 'ChangePasswordPage',
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.lock_open,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Text('Passwort ändern')
                    ],
                  ),
                ),
                PopupMenuItem(
                value: 'DeleteAccountPage',
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Text('Account löschen')
                  ],
                ),
              ),
            ],
            onSelected: _handleTopMenu,
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFieldWithDescriptor(
                      'Name',
                      Text('${user.name}'
                          ' ${user.surname}')),
                  TextFieldWithDescriptor('Email', Text(user.mail)),
                  TextFieldWithDescriptor('Benutzername', Text(user.nickname))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///Handles the decision where to route to
  void _handleTopMenu(String value) {
    switch (value) {
      case 'EditProfilePage':
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage()));
          break;
        }
      case 'ChangePasswordPage':
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChangePasswordPage()));
          break;
        }
      case 'DeleteAccountPage':
      {
        Navigator.push(
          context,
           MaterialPageRoute(
             builder: (context) =>
              MyAccountDelete()));
            break;
      }
    }
  }
}
