import 'dart:core';
import 'dart:developer' as logging;

import 'package:biodiversity/components/privacy_agreement.dart';
import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/login_result.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// The User class holds all information about the User of the app
/// The class is built to be used as a singleton,
/// so only one instance should be used throughout the app.
class User extends ChangeNotifier {
  final StorageProvider _storage;
  Set<String> _gardens;
  Set<DocumentReference> _gardenReferences;
  Set<String> _favoredObjects;
  bool _loggedIn;

  /// The nickname is a name which is used to represent the user anonymously
  String nickname;

  /// The name is the name of the user like Gabriel
  String name;

  /// The surname is the family name of the user like Ineichen
  String surname;

  /// the URL which points to the profile picture
  String imageURL;

  /// email from the user
  String mail;

  /// toggle whether to show the username on the map
  bool showNameOnMap;

  /// toggle whether an image of the garden is visible on the map
  bool showGardenImageOnMap;

  /// reference where the object is stored in the database
  DocumentReference reference;

  /// Provides an empty User object. This should only be used once at App start.
  User.empty({StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance,
        _loggedIn = false,
        _gardens = <String>{},
        _gardenReferences = <DocumentReference>{},
        _favoredObjects = <String>{},
        nickname = '',
        name = '',
        surname = '',
        imageURL = '',
        mail = '',
        showNameOnMap = true,
        showGardenImageOnMap = true {
    if (_storage.auth.currentUser != null) {
      _loggedIn = true;
      loadDetailsFromLoggedInUser();
    }
  }

  /// Loads the details like nickname, liked objects etc. form the database
  /// After the details are loaded, the listeners are notified
  /// Reruns false if the User is not logged in
  /// or the document referenced by `documentPath` was not found.<br>
  /// If the flag informListeners is set, the listeners will be notified.
  Future<bool> loadDetailsFromLoggedInUser(
      {bool informListeners = true}) async {
    if (!_loggedIn) {
      return false;
    }
    final doc = await _storage.database.doc(documentPath).get();
    if (!doc.exists) {
      logging.log('Loading failed, no doc found');
      return false;
    }
    final map = doc.data();
    logging.log('User attributes from database: ${map.toString()}');
    if (map.containsKey('nickname') && map['nickname'] is String) {
      nickname = map['nickname'];
    }
    if (map.containsKey('name') && map['name'] is String) {
      name = map['name'];
    }
    if (map.containsKey('surname') && map['surname'] is String) {
      surname = map['surname'];
    }
    if (map.containsKey('imageURL') && map['imageURL'] is String) {
      imageURL = map['imageURL'];
    }
    if (map.containsKey('gardens') && map['gardens'] is List) {
      _gardens = Set.from(map['gardens']);
    }
    if (map.containsKey('gardenReferences') &&
        map['gardenReferences'] is List) {
      _gardenReferences = Set.from(map['gardenReferences']);
    }
    if (map.containsKey('favoredObjects') && map['favoredObjects'] is List) {
      _favoredObjects = Set.from(map['favoredObjects']);
    }
    if (map.containsKey('mail') && map['mail'] is String) {
      mail = map['mail'];
    }
    if (map.containsKey('showNameOnMap') && map['showNameOnMap'] is bool) {
      showNameOnMap = map['showNameOnMap'];
    }
    if (map.containsKey('showGardenImageOnMap') &&
        map['showGardenImageOnMap'] is bool) {
      showGardenImageOnMap = map['showGardenImageOnMap'];
    }
    logging.log('loaded User: ${toString()}');
    if (informListeners) {
      notifyListeners();
    }
    return true;
  }

  User.fromMap(Map<String, dynamic> map,
      {this.reference, StorageProvider storageProvider})
      : _storage = storageProvider ??= StorageProvider.instance,
        _favoredObjects = map.containsKey('favoredObjects')
            ? Set<String>.from(map['favoredObjects'] as Iterable)
            : null,
        _gardenReferences = map.containsKey('gardenReferences')
            ? Set<DocumentReference>.from(map['gardenReferences'] as Iterable)
            : null,
        _gardens = map.containsKey('gardens')
            ? Set<String>.from(map['gardens'] as Iterable)
            : null,
        imageURL = map.containsKey('imageURL') ? map['imageURL'] as String : '',
        mail = map.containsKey('mail') ? map['mail'] as String : '',
        name = map.containsKey('name') ? map['name'] as String : '',
        nickname = map.containsKey('nickname') ? map['nickname'] as String : '',
        showGardenImageOnMap = map.containsKey('showGardenImageOnMap')
            ? map['showGardenImageOnMap'] as bool
            : '',
        showNameOnMap = map.containsKey('showNameOnMap')
            ? map['showNameOnMap'] as bool
            : '',
        surname = map.containsKey('surname') ? map['surname'] as String : '';

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  ///saves all information from the [User] Class to the database
  ///returns `false` if no user is logged in
  Future<bool> saveUser() async {
    if (!_loggedIn) {
      return false;
    }
    await _storage.database.doc(documentPath).set({
      'nickname': nickname,
      'name': name,
      'surname': surname,
      'mail': mail,
      'imageURL': imageURL,
      'gardens': _gardens.toList(),
      'gardenReferences': _gardenReferences.toList(),
      'favoredObjects': _favoredObjects.toList(),
      'showNameOnMap': showNameOnMap,
      'showGardenImageOnMap': showGardenImageOnMap,
    });
    return true;
  }

  //TODO: _gardens needs to be updated together with garden object

  ///changes any field of the [User].
  ///Afterwards the changes are saved to the database
  ///and the listeners will be informed if the flag [informListeners] is set.
  void updateUserData(
      {String newName,
      String newSurname,
      String newNickname,
      String newMail,
      String newImageURL,
      String newAddress,
      bool doesShowNameOnMap,
      bool doesShowGardenImageOnMap,
      bool informListeners = true}) {
    if (newName != null) name = newName;
    if (newSurname != null) surname = newSurname;
    if (newNickname != null) {
      nickname = newNickname;
      if (_loggedIn) {
        _storage.auth.currentUser.updateDisplayName(nickname);
      }
    }
    if (newImageURL != null) imageURL = newImageURL;
    if (newMail != null) mail = newMail;
    if (doesShowNameOnMap != null) showNameOnMap = doesShowNameOnMap;
    if (doesShowGardenImageOnMap != null) {
      showGardenImageOnMap = doesShowGardenImageOnMap;
    }
    saveUser();
    if (informListeners) {
      notifyListeners();
    }
  }

  /// toggle for a given element.
  /// No checks are made if the element is actually featured in the database
  void likeUnlikeElement(String element) {
    if (_favoredObjects.contains(element)) {
      _favoredObjects.remove(element);
    } else {
      _favoredObjects.add(element);
    }
    notifyListeners();
    saveUser();
  }

  /// returns a [bool] whether the User has liked the given element
  bool doesLikeElement(String element) {
    return _favoredObjects.contains(element);
  }

  /// returns the users favoredObjects
  Set<String> get favoredObjects {
    return _favoredObjects;
  }

  /// returns the users favoredObjects of type HabitatElement
  List<BiodiversityMeasure> get favoredHabitatObjects {
    return ServiceProvider.instance.biodiversityService
        .getFullBiodiversityObjectList()
        .where((element) => _favoredObjects.contains(element.name))
        .toList();
  }

  /// returns the users favoredObjects of type Species
  List<Species> get favoredSpeciesObjects {
    return ServiceProvider.instance.speciesService
        .getFullSpeciesObjectList()
        .where((element) => _favoredObjects.contains(element.name))
        .toList();
  }

  /// is true if the User has confirmed his email address by the sent link
  bool get hasConfirmedEmail =>
      _storage.auth.currentUser != null &&
      _storage.auth.currentUser.emailVerified;

  /// is true if the user is logged in
  bool get isLoggedIn => _loggedIn;

  /// is true if the user is registered with email and password
  bool get isRegisteredWithEmail => isLoggedIn
      ? _storage.auth.currentUser.providerData
          .any((element) => element.providerId == 'password')
      : false;

  /// returns a [String] with the path to the users profile in the database
  String get documentPath => _loggedIn && _storage.auth.currentUser != null
      ? 'users/$userUUID'
      : 'users/anonymous';

  /// returns the UUID of a logged in User
  String get userUUID => _loggedIn ? _storage.auth.currentUser.uid : '';

  /// Adds a garden to the owned garden list
  void addGarden(Garden garden) {
    if (garden == null || garden.name == null || garden.name.isEmpty) {
      throw ArgumentError('Garden must have a name');
    }
    _gardens.add(garden.name);
    _gardenReferences.add(garden.reference);
    saveUser();
  }

  /// Returns a list of all names from owned gardens
  List<String> get gardens => _gardens?.toList();

  List<DocumentReference> get gardenReferences => _gardenReferences?.toList();

  /// signs the user out, saves all data to the database.
  /// Afterwards all fields are reset to empty fields.
  /// The listeners will be notified
  Future<void> signOut({bool save = true}) async {
    if (_loggedIn) {
      if (save) {
        await saveUser();
      }
      _storage.auth.signOut();
    }
    nickname = '';
    name = '';
    surname = '';
    imageURL = '';
    mail = '';
    _gardens = <String>{};
    _gardenReferences = <DocumentReference>{};
    _favoredObjects = <String>{};
    _loggedIn = false;
    showNameOnMap = true;
    showGardenImageOnMap = true;
    notifyListeners();
  }

  @override
  String toString() {
    return '{Nickname: $nickname, Name: $name, Surname: $surname}';
  }

  /// Signs the user in with a google account.<br>
  /// The selection which User should be used will appear as a pop up
  /// In case of success returns `null`, otherwise a [LoginResult] object
  /// with the message set and additionally the flag isPrivacyAgreementAccepted
  /// set to false if the user isn't registered
  Future<LoginResult> signInWithGoogle() async {
    if (isLoggedIn) {
      return null;
    }
    _storage.googleSignIn.signOut();
    final googleAccount = await _storage.googleSignIn.signIn();
    if (googleAccount == null) {
      return LoginResult('Anmeldung abgebrochen.');
    }
    final token = await googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(idToken: token.idToken);

    final result = await _signInWithCredential(
        credential: credential,
        email: googleAccount.email,
        signOutCallback: _storage.googleSignIn.signOut);
    return result;
  }

  /// Signs the user in with a Facebook account.<br>
  /// In case of success returns `null`, otherwise a [LoginResult] object
  /// with the message set and additionally the flag `isPrivacyAgreementAccepted`
  /// set to false if the user isn't registered
  Future<LoginResult> signInWithFacebook({bool register = false}) async {
    if (isLoggedIn) {
      return null;
    }
    fb_auth.LoginResult token;
    try {
      token = await _storage.facebookAuth.login(
          loginBehavior: fb_auth.LoginBehavior.dialogOnly,
          permissions: ['email']);
      if (token.status == fb_auth.LoginStatus.cancelled ||
          token.status == fb_auth.LoginStatus.failed) {
        return LoginResult('Anmeldung abgebrochen');
      }
    } on PlatformException {
      return LoginResult('Anmeldung abgebrochen');
    }
    final data = await _storage.facebookAuth.getUserData(fields: 'email');
    if (!data.containsKey('email')) {
      _storage.facebookAuth.logOut();
      return LoginResult(
          'Name oder Email konnte nicht von Facebook abgerufen werden');
    }
    final credential = FacebookAuthProvider.credential(token.accessToken.token);
    final result = await _signInWithCredential(
        credential: credential,
        email: data['email'],
        signOutCallback: _storage.googleSignIn.signOut);
    return result;
  }

  ///Signs the user in with the provided Email and password
  ///if an error occurs returns a [LoginResult] object
  ///with a message as string and a flag isEmailConfirmed which indicates
  ///if the user has already confirmed his email address
  ///<br> if no error occurs null is returned.
  Future<LoginResult> signInWithEmail(String email, String password) async {
    if (!isLoggedIn) {
      try {
        await _storage.auth
            .signInWithEmailAndPassword(email: email, password: password);
        if (_storage.auth.currentUser.emailVerified != null &&
            !_storage.auth.currentUser.emailVerified) {
          _storage.auth.signOut();
          return LoginResult('Bitte bestätigen Sie zuerst ihre Email Adresse',
              isEmailConfirmed: false);
        }
        _loggedIn = true;
        await loadDetailsFromLoggedInUser();
        if (mail.isEmpty && email.isNotEmpty) {
          updateUserData(newMail: email);
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'invalid-email') {
          return LoginResult('Die eingegebene Email Adresse ist ungültig.');
        } else if (error.code == 'user-disabled') {
          return LoginResult('Ihr Konto wurde gesperrt. '
              'Bitte wenden Sie sich an den Support.');
        } else {
          return LoginResult('Die Email Adresse oder das Passwort ist falsch');
        }
      }
    }
    return null;
  }

  /// Signs the user in with the provided Apple account
  Future<LoginResult> signInWithApple() async {
    //TODO: Implement signInWithApple
    return null;
  }

  Future<LoginResult> _signInWithCredential(
      {@required OAuthCredential credential,
      @required String email,
      @required Function() signOutCallback}) async {
    try {
      final signInMethods =
          await _storage.auth.fetchSignInMethodsForEmail(email);
      if (signInMethods == null || signInMethods.isEmpty) {
        signOutCallback();
        return LoginResult('Bitte registrieren Sie sich zuerst.',
            isRegistered: false, isEmailConfirmed: false);
      } else if (!signInMethods.contains(credential.providerId)) {
        signOutCallback();
        return LoginResult('Sie haben sich bisher nicht mit einem '
            '${credential.providerId} account registriert.<br>');
      }
      await _storage.auth.signInWithCredential(credential);
      _loggedIn = true;
      await loadDetailsFromLoggedInUser();
      if (mail.isEmpty && email.isNotEmpty) {
        updateUserData(newMail: email);
      }
    } on FirebaseAuthException catch (error) {
      signOutCallback();
      if (error.code == 'account-exists-with-different-credential') {
        return LoginResult('Sie haben sich bereits mit einem anderen Account'
            'registriert.');
      } else if (error.code == 'invalid-email') {
        // This should not be possible,
        // since the email is fetched from the provider account
        return LoginResult('Deine Email adresse ist ungültig');
      } else if (error.code == 'invalid-credentials') {
        return LoginResult(
            'Ein Fehler ist aufgetreten beim Abrufen deiner Logindaten.');
      }
    } catch (e) {
      return LoginResult('Ein Fehler ist aufgetreten. Versuche es erneut');
    }
  }

  ///Displays the google account selection popup and the privacy agreement.<br>
  ///Afterwards the user is signed in automatically
  Future<String> registerWithGoogle(BuildContext context) async {
    if (isLoggedIn) {
      return null;
    }
    final googleAccount = await _storage.googleSignIn.signIn();
    if (googleAccount == null) {
      return 'Registrierung abgebrochen';
    }
    final token = await googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(idToken: token.idToken);
    final result = await _registerWithCredential(
      credential: credential,
      context: context,
      email: googleAccount.email,
      displayName: googleAccount.displayName,
      signOutCallback: _storage.googleSignIn.signOut,
    );
    return result;
  }

  /// Registers a user with the provided email address and password.
  /// An email will be sent to confirm the users email address.<br>
  /// The User is not logged in afterwards.
  /// Sign in is only possible after the user has confirmed his email address.
  /// <br>returns an error Message which can be displayed if something
  /// goes wrong. Or null if everything is fine.
  Future<String> registerWithEmail(String email, String password,
      {String nickname, String name, String surname}) async {
    try {
      final cred = await _storage.auth
          .createUserWithEmailAndPassword(email: email, password: password);
      cred.user.updateDisplayName(nickname);
      updateUserData(newName: name, newSurname: surname, newNickname: nickname);
      cred.user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        return 'Die eingegebene Email Adresse ist ungültig.';
      } else if (error.code == 'email-already-in-use') {
        return 'Die angegebene Email Adresse wird bereits verwendet.';
      } else if (error.code == 'weak-password') {
        return 'Das angegebene Passwort ist zu schwach. '
            'Ihr Passwort sollte mindestens 6 Zeichen lang sein '
            'und Zahlen sowie Gross- und Kleinbuchstaben beinhalten.';
      } else {
        return 'Something went wrong.';
      }
    }
    return null;
  }

  Future<String> saveNickname(
      {String nickname, String name, String surname}) async {
    updateUserData(newName: name, newSurname: surname, newNickname: nickname);

    return null;
  }

  /// Registers a user with a facebook account.
  /// returns null if everything worked fine.
  /// If something goes wrong, the returned String will explain what went wrong.
  Future<String> registerWithFacebook(BuildContext context) async {
    if (isLoggedIn) {
      return null;
    }
    fb_auth.LoginResult token;
    try {
      token = await _storage.facebookAuth.login(
          loginBehavior: fb_auth.LoginBehavior.dialogOnly,
          permissions: ['email']);
      if (token.status == fb_auth.LoginStatus.cancelled ||
          token.status == fb_auth.LoginStatus.failed) {
        return 'Registrierung abgebrochen';
      }
    } on PlatformException {
      return 'Registrierung abgebrochen';
    }
    final data = await _storage.facebookAuth.getUserData(fields: 'name, email');
    if (!data.containsKey('name') || !data.containsKey('email')) {
      return 'Name oder Email konnte nicht von Facebook abgerufen werden';
    }
    final credential = FacebookAuthProvider.credential(token.accessToken.token);
    final result = await _registerWithCredential(
        context: context,
        credential: credential,
        displayName: data['name'],
        email: data['email'],
        signOutCallback: _storage.facebookAuth.logOut);
    return result;
  }

  /// Signs the user in with the provided Apple account
  Future<LoginResult> registerWithApple(BuildContext context) async {
    //TODO: Implement registerWithApple
    return null;
  }

  /// signs in a user with the provided credential and loads the User details.
  /// <br>returns null if the registration is successful.
  Future<String> _registerWithCredential(
      {@required OAuthCredential credential,
      @required String displayName,
      @required String email,
      @required Function() signOutCallback,
      @required BuildContext context}) async {
    final isNotRegistered =
        !(await getSignInMethods(email)).contains(credential.providerId);
    if (isNotRegistered && !await showPrivacyAgreement(context)) {
      signOutCallback();
      return 'Damit du ein Konto erstellen kannst, '
          'musst du das Privacy agreement annehmen.';
    }
    try {
      final authUser = await _storage.auth.signInWithCredential(credential);
      authUser.user.updateDisplayName(displayName);
      authUser.user.updateEmail(email);
      updateUserData(
          newNickname: displayName, informListeners: false, newMail: mail);
      _loggedIn = true;
      await loadDetailsFromLoggedInUser();
      return null;
    } on FirebaseAuthException catch (error) {
      signOutCallback();
      return error.message;
    }
  }

  /// sends the mail to confirm the email address again
  Future<String> sendEmailConfirmation(String email, String password) async {
    try {
      await _storage.auth
          .signInWithEmailAndPassword(email: email, password: password);
      await _storage.auth.currentUser.sendEmailVerification();
      _storage.auth.signOut();
    } on FirebaseAuthException {
      return 'Something went wrong';
    }
    return null;
  }

  /// Sends a password reset link to the provided email.
  Future<bool> sendPasswordResetLink(String email) async {
    final methods = await getSignInMethods(email);
    if (methods.contains('password')) {
      _storage.auth.sendPasswordResetEmail(email: email);
      return true;
    }
    return false;
  }

  /// returns a list of possible sign in methods for the provided email
  Future<List<String>> getSignInMethods(String email) async {
    try {
      var list = await _storage.auth.fetchSignInMethodsForEmail(email);
      return list ??= [];
    } on FirebaseAuthException {
      return [];
    }
  }

  /// change password, can only be used if the user is registered with email and password
  Future<String> changePassword(
      {@required String oldPassword, @required String newPassword}) async {
    if (!isRegisteredWithEmail) {
      return null;
    }
    try {
      await _storage.auth
          .signInWithEmailAndPassword(email: mail, password: oldPassword);
      await _storage.auth.currentUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == 'weak-password') {
        return 'Das neue Passwort ist zu schwach';
      }
      if (exception.code == 'wrong-password') {
        return 'Das alte Password ist falsch';
      } else {
        return 'Etwas ist schiefgelaufen';
      }
    }
    return null;
  }

  /// Remove a garden from the owned gardens
  void deleteGarden(Garden garden) {
    _gardens.remove(garden.name);
    _gardenReferences.remove(garden.reference);
    saveUser();
    notifyListeners();
  }

  ///Remove a user account.
  Future<String> deleteAccount() async {
    try {
      await _storage.database.doc(documentPath).delete();
      await _storage.auth.currentUser.delete();
      return 'Der Account wurde erfolgreich entfernt';
    } on FirebaseAuthException {
      return 'Etwas ist schiefgelaufen';
    }
  }

  /// ensures all providers the user is signed up with are authenticated
  Future<String> reauthenticate() async {
    final token = await _storage.auth.currentUser.getIdToken();
    final providers = _storage.auth.currentUser.providerData;
    var credential;
    for (final info in providers) {
      if (info.providerId == GoogleAuthProvider.PROVIDER_ID) {
        final googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final googleAuth = await googleUser.authentication;

        // Create a new credential
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else if (info.providerId == FacebookAuthProvider.PROVIDER_ID) {
        credential = FacebookAuthProvider.credential(
            token); // TODO might need some fixes once facebook login is available
      } else {
        return 'Dein Anmelde Provider wurde nicht gefunden';
      }
      try {
        await _storage.auth.currentUser
            .reauthenticateWithCredential(credential);
      } on FirebaseAuthException {
        return 'Etwas ist schiefgelaufen';
      }
    }
    return null;
  }

  /// ensures the user is authenticated with his email address and password.
  /// Only usable with email Provider<br>
  /// throws: StateError if the user is not registered with email;
  Future<String> reauthenticate_with_email(String password) async {
    if (!isRegisteredWithEmail) {
      throw StateError(
          'function can only be used with a user which is registered with email and password.');
    }
    if (password == '' || password == null) {
      return 'Bitte gib ein Passwort ein';
    }
    final credential =
        EmailAuthProvider.credential(email: mail, password: password);
    try {
      await FirebaseAuth.instance.currentUser
          .reauthenticateWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Das Passwort ist falsch';
      } else {
        return 'Etwas ist schiefgelaufen';
      }
    }
  }

  ///Remove a user account.
  Future<String> deleteAccountEmail() async {
    try {
      await _storage.database.doc(documentPath).delete();
      await FirebaseAuth.instance.currentUser.delete();
      return 'Der Account wurde erfolgreich entfernt';
    } on FirebaseAuthException {
      return 'Etwas is schiefgelaufen';
    }
  }
}
