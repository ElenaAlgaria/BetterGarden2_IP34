import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

class MockFacebookUser {
  String name;
  String password;
  String email;
  final String uuid;
  bool signedIn;

  MockFacebookUser(this.name, this.password, this.email)
      : uuid = const Uuid().v1(),
        signedIn = false;
}

/// Mocks a FacebookAuth instance with a single User provided at construction
class MockFacebookAuth extends Mock implements FacebookAuth {
  /// mock User
  MockFacebookUser mockUser =
      MockFacebookUser('tester', '123456', 'tester@test.com');

  /// provide the mocked User which will be used to perform all actions
  MockFacebookAuth({mockUser});

  AccessToken _getAccessToken({
    List<String> permissions = const ['email', 'public_profile'],
  }) {
    return AccessToken(
        grantedPermissions: permissions,
        userId: mockUser.uuid,
        token: 'MOCK_TOKEN',
        lastRefresh: DateTime.now(),
        declinedPermissions: [],
        expires: DateTime.now().add(const Duration(days: 30)),
        applicationId: '',
        isExpired: false);
  }

  LoginResult _getLoginResult(String message,
      {LoginStatus status = LoginStatus.success, List<String> permissions}) {
    if (status != LoginStatus.success) {
      return LoginResult(status: status, message: message);
    }
    return LoginResult(
        status: status,
        message: message,
        accessToken: permissions.isEmpty
            ? _getAccessToken()
            : _getAccessToken(permissions: permissions));
  }

  @override
  Future<LoginResult> login(
      {List<String> permissions = const ['email', 'public_profile'],
      LoginBehavior loginBehavior = LoginBehavior.dialogOnly,
      bool failLogin}) {
    if (failLogin) {
      return Future.value(
          _getLoginResult('Login abort', status: LoginStatus.cancelled));
    }
    mockUser.signedIn = true;
    return Future.value(
        _getLoginResult('login success', permissions: permissions));
  }

  @override
  Future<Function> logOut() {
    mockUser.signedIn = false;
    return null;
  }

  @override
  Future<Map<String, dynamic>> getUserData(
      {String fields = 'name,email,picture.width(200)'}) {
    return Future.value({});
  }

  @override
  Future<LoginResult> expressLogin() {
    return Future.value(_getLoginResult('express success'));
  }
}
