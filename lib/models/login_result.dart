/// Container for the return of a sign in or a registration process
class LoginResult {
  /// Flag if the email is confirmed. Only used with email registration
  bool isEmailConfirmed;

  /// Flag if the user has accepted the privacy agreement
  bool isRegistered;

  /// Error message if the process failed.
  String message;

  /// Container for the return of a sign in or a registration process
  LoginResult(this.message,
      {this.isEmailConfirmed = true, this.isRegistered = true});
}
