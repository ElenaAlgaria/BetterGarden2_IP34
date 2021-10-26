import 'package:biodiversity/components/expandable_information_object_card_widget.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/components/simple_information_object_card_widget.dart';
import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/take_home_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';
import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

void main() {
  group('test list content', () {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    for (final obj in [BiodiversityMeasure, Species, TakeHomeMessage]) {
      final list = <InformationObject>[];
      // do not increase, since the list is constructed with a Listview.builder
      // the Listview.builder does build offstage widget on demand which makes testing complicated
      for (var i = 0; i < 5; i++) {
        if (obj == BiodiversityMeasure) {
          list.add(BiodiversityMeasure.fromMap({'name': 'biodiversity$i'},
              storageProvider: storage, serviceProvider: service));
        } else if (obj == Species) {
          list.add(Species.fromMap({'name': 'species$i'},
              serviceProvider: service, storageProvider: storage));
        } else {
          list.add(TakeHomeMessage.fromMap({'title': 'take-home-message$i'},
              storageProvider: storage));
        }
      }
      testWidgets('test if all InformationObjects are present on list',
          (tester) async {
        await setUpBiodiversityEnvironment(
            tester: tester,
            widget: Scaffold(
              body: InformationObjectListWidget(
                objects: list,
                serviceProvider: service,
              ),
            ),
            storageProvider: storage);
        expect(
            find.byType(ExpandableInformationObjectCard, skipOffstage: false),
            findsNWidgets(list.length),
            reason: 'an expendable card was not present in the list');
      });

      testWidgets('test with simpleCards', (tester) async {
        await setUpBiodiversityEnvironment(
            tester: tester,
            widget: Scaffold(
              body: InformationObjectListWidget(
                objects: list,
                serviceProvider: service,
                useSimpleCard: true,
              ),
            ),
            storageProvider: storage);
        expect(find.byType(SimpleInformationObjectCard, skipOffstage: false),
            findsNWidgets(list.length),
            reason: 'a simple card was not present in the list');
      });

      testWidgets('test hidden like button', (tester) async {
        await setUpBiodiversityEnvironment(
            tester: tester,
            widget: Scaffold(
              body: InformationObjectListWidget(
                objects: list,
                serviceProvider: service,
                hideLikeAndAdd: true,
              ),
            ),
            storageProvider: storage);
        expect(
            find.byType(ExpandableInformationObjectCard, skipOffstage: false),
            findsNWidgets(list.length),
            reason: 'an item was not present in the list');
        expect(find.textContaining('hinzufügen'), findsNothing);
        expect(find.textContaining('merken'), findsNothing);
      });
    }
  });
  group('basic test', () {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    testWidgets('test empty list', (tester) async {
      for (final b in [false, true]) {
        await setUpBiodiversityEnvironment(
            tester: tester,
            storageProvider: storage,
            widget: Scaffold(
              body: InformationObjectListWidget(
                objects: [],
                serviceProvider: service,
                useSimpleCard: b,
              ),
            ));
        expect(find.byType(ExpandableInformationObjectCard), findsNothing,
            reason: 'should not find card in empty list');
        expect(find.byType(SimpleInformationObjectCard), findsNothing,
            reason: 'should not find card in empty list');
        expect(find.text('Leider keine Einträge vorhanden'), findsOneWidget,
            reason:
                'Message missing which tells the user that there is no card');
      }
    });
    testWidgets('test if search is present', (tester) async {
      for (final b in [false, true]) {
        await setUpBiodiversityEnvironment(
            tester: tester,
            storageProvider: storage,
            widget: Scaffold(
              body: InformationObjectListWidget(
                objects: [],
                serviceProvider: service,
                useSimpleCard: b,
              ),
            ));
        expect(find.byType(TextField), findsOneWidget,
            reason: 'search not present');
      }
    });

    testWidgets('test filter tags', (tester) async {
      for (final type in [BiodiversityMeasure, Species, TakeHomeMessage]) {
        final list = <InformationObject>[];
        // do not increase, since the list is constructed with a Listview.builder
        // the Listview.builder does build offstage widget on demand which makes testing complicated
        for (var i = 0; i < 5; i++) {
          if (type == BiodiversityMeasure) {
            list.add(BiodiversityMeasure.fromMap(
                {'name': 'biodiversity$i', 'type': 'filerTag$i'},
                storageProvider: storage, serviceProvider: service));
          } else {
            list.add(Species.fromMap(
                {'name': 'species$i', 'class': 'filterTag$i'},
                serviceProvider: service, storageProvider: storage));
          }
        }
        for (final b in [false, true]) {
          await setUpBiodiversityEnvironment(
              tester: tester,
              storageProvider: storage,
              widget: Scaffold(
                body: InformationObjectListWidget(
                  objects: list,
                  serviceProvider: service,
                  useSimpleCard: b,
                ),
              ));
          expect(find.textContaining('filerTag'), findsNWidgets(list.length),
              reason: 'every distinct class should generate a filter tag');
        }
      }
    });
  });
}
