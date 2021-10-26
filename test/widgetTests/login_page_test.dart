import 'package:biodiversity/screens/login_page/email_login_page.dart';
import 'package:biodiversity/screens/login_page/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';

void main() {
  testWidgets('Check if all login options are present', (tester) async {
    await setUpBiodiversityEnvironment(tester: tester, widget: LoginPage());
    final emailLogin = find.text('E-mail');
    final googleLogin = find.text('Google');
   // final facebookLogin = find.text('Facebook'); // disabled due to not implemented yet

    expect(emailLogin, findsOneWidget, reason: 'E-mail login option not found');
    expect(googleLogin, findsOneWidget,
        reason: 'Google login option not found');
    // expect(facebookLogin, findsOneWidget,
    //     reason: 'Facebook login option not found'); //Disabled due to not implemented yet
  });

  testWidgets('Test Email login', (tester) async {
    await setUpBiodiversityEnvironment(tester: tester, widget: LoginPage());
    await tester.tap(find.text('E-mail'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing,
        reason: 'LoginPage still loaded, should be EmailLoginPage');
    expect(find.byType(EmailLoginPage), findsOneWidget,
        reason: 'EmailLoginPage not loaded');
  });
}
