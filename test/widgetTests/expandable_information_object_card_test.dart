import 'package:biodiversity/components/expandable_information_object_card_widget.dart';
import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';
import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

void main() {
  testWidgets('Test fields present', (tester) async {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    final attributes = {
      'name': 'testname',
      'shortDescription': 'Some description...',
      'unit': 'unit...',
      'type': 'dummy',
      'beneficialFor': ['vogel'],
      'goodTogetherWith': ['birds'],
      'dimension': 'dimension..',
      'unusedField': 'xyz'
    };
    final element = BiodiversityMeasure.fromMap(attributes,
        storageProvider: storage, serviceProvider: service);
    expect(element.shortDescription, attributes['shortDescription']);
    await setUpBiodiversityEnvironment(
        tester: tester,
        widget: Scaffold(
          body: ExpandableInformationObjectCard(
            element,
            serviceProvider: MockServiceProvider(storageProvider: storage),
          ),
        ),
        storageProvider: storage);
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    await tester.pump(const Duration(minutes: 1));
    expect(find.textContaining('merken'), findsOneWidget,
        reason: 'merken button was not present');
    expect(find.textContaining('hinzufügen'), findsOneWidget,
        reason: 'hinzufügen button was not present');
    expect(find.text(attributes['name']), findsNWidgets(2),
        reason: 'title of the card is missing');
    expect(find.byIcon(Icons.add), findsNWidgets(2),
        reason: 'Icons.add (hinzufügen) is missing');
    expect(find.byIcon(Icons.favorite), findsNWidgets(2),
        reason: 'Icons.favorite (merken) is missing');
    expect(find.text(attributes['shortDescription']), findsNothing,
        reason: 'shortDescription should only in expanded mode be visible');
    expect(find.textContaining(RegExp(r'.*info.*', caseSensitive: false)),
        findsNothing,
        reason: 'weitere infos should only in expanded mode be visible');
    await tester.tap(find.text(attributes['name']).first);
    await tester.pumpAndSettle(const Duration(minutes: 1));
    await tester.idle();
    expect(find.text(attributes['shortDescription']), findsOneWidget,
        reason: 'shortDescription should be visible when expanded');
    expect(find.textContaining(RegExp(r'.*info.*', caseSensitive: false)),
        findsOneWidget,
        reason: 'weitere infos should be visible when expanded');
  });
}
