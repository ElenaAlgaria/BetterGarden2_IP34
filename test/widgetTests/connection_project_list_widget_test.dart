import 'package:biodiversity/components/connection_project_list_widget.dart';
import 'package:biodiversity/components/expandable_connection_project_card_widget.dart';
import 'package:biodiversity/components/simple_connection_project_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';
import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

void main() {

/*  group('test list content', () {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    for (final obj in [ConnectionProject]) {
      final list = <ConnectionProject>[];
      for (var i = 0; i < 5; i++) {
        if (obj == ConnectionProject) {
          list.add(ConnectionProject.fromMap({'name': 'connection-project$i'},
              storageProvider: storage));
        }
      }
      testWidgets('test if all ConnectionProjects are present on the list',
          (tester) async {
        await setUpBiodiversityEnvironment(
            tester: tester,
            widget: Scaffold(
              body: ConnectionProjectListWidget(
                objects: list,
                serviceProvider: service,
              ),
            ),
            storageProvider: storage);
        expect(
            find.byType(ExpandableConnectionProjectCard, skipOffstage: false),
            findsNWidgets(list.length),
            reason: 'an expandable card was not present in the list');
      });
    }
  });*/

  group('basic test', () {
    final storage = MockStorageProvider();
    final service = MockServiceProvider(storageProvider: storage);
    testWidgets('test empty list', (tester) async {
      for (final b in [false, true]) {
        await setUpBiodiversityEnvironment(
            tester: tester,
            storageProvider: storage,
            widget: Scaffold(
              body: ConnectionProjectListWidget(
                objects: [],
                serviceProvider: service,
                useSimpleCard: b,
              ),
            ));
        expect(find.byType(ExpandableConnectionProjectCard), findsNothing,
            reason: 'should not find card in empty list');
        expect(find.byType(SimpleConnectionProjectCard), findsNothing,
            reason: 'should not find card in empty list');
        expect(find.text('Leider keine Eintr??ge vorhanden'), findsOneWidget,
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
              body: ConnectionProjectListWidget(
                objects: [],
                serviceProvider: service,
                useSimpleCard: b,
              ),
            ));
        expect(find.byType(TextField), findsOneWidget,
            reason: 'search not present');
      }
    });
  });
}
