import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/screens/map_page/project_already_exists_page.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

import '../environment/mock_storage_provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock {}

void main() {
  final storage = MockStorageProvider();

  MockDocumentReference ameise;
  MockDocumentReference gartenRef1;
  MockDocumentReference gartenRef2;
  setUp(() {
    ameise = MockDocumentReference();
    gartenRef1 = MockDocumentReference();
    gartenRef2 = MockDocumentReference();
  });

  final gardenAttributes2 = {
    'reference': gartenRef2,
    'name': 'Ms. Lewis Garden',
    'street': 'via G.G. Nessi 4B',
    'owner': 'Lisa',
    'coordinates': const GeoPoint(46.948916, 7.445423),
    'ownedObjects': {'dummy': 9, 'second dummy': 1},
    'ownedLinkingProjects': ['grasfroschteam']
  };
  final connectionProjectAttributes1 = {
    'description': 'My Project',
    'gardens': [gartenRef1],
    'targetSpecies': ameise
  };
  final garden2 = Garden.fromMap(gardenAttributes2, storageProvider: storage);
  final connectionProject1 = ConnectionProject.fromMap(
      connectionProjectAttributes1,
      storageProvider: storage);

  //final saveConnectionProjectFinder = find.byKey(const Key('saveConnectionProject'));

  final saveConnectionProjectFinder =
      find.widgetWithIcon(CreateProjectPage, Icons.save);

  //debugPrint('Finder: ' + saveConnectionProjectFinder.toString());

  testWidgets('Project already exists page is shown',
      (WidgetTester tester) async {
    await tester.tap(saveConnectionProjectFinder);
    await tester.pumpAndSettle();
    await tester
        .pumpWidget(ProjectAlreadyExistsPage(connectionProject1, garden2));

    expect(find.byType(ProjectAlreadyExistsPage), findsOneWidget);
  });
}
