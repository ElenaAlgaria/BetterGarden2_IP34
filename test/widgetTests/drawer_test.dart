import 'package:biodiversity/components/drawer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';

void main() {
  testWidgets('check if all options are present in the drawer', (tester) async {
    await setUpBiodiversityEnvironment(tester: tester, widget: MyDrawer());

    expect(find.text('Karte'), findsOneWidget,
        reason: 'Karte is missing on the Drawer');

    expect(find.text('Mein Garten'), findsOneWidget,
        reason: 'Mein Garten is missing on the Drawer');

    expect(find.text('Lebensräume'), findsOneWidget,
        reason: 'Lebensräume is missing on the Drawer');

    expect(find.text('Arten'), findsOneWidget,
        reason: 'Arten is missing on the Drawer');

    expect(find.text('Merkliste'), findsOneWidget,
        reason: 'Merkliste is missing on the Drawer');

    expect(find.text('Wissensgrundlagen'), findsOneWidget,
        reason: 'Take Home Messages is missing on the Drawer');

    expect(find.text('Login'), findsOneWidget,
        reason: 'Login is missing on the Drawer');
  });
}
