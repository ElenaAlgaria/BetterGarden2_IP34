import 'package:biodiversity/services/biodiversity_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_service_provider.dart';
import '../environment/mock_storage_provider.dart';

void main() {
  test('test fetch all data', () async {
    final storage = MockStorageProvider();
    final serviceProvider = MockServiceProvider(storageProvider: storage);
    await storage.database.doc('biodiversityMeasures/testObject').set({
      'name': 'testObject',
      'type': 'test',
    });
    final service = BiodiversityService(
        storageProvider: storage, serviceProvider: serviceProvider);
    expect(service.getBiodiversityObjectList('None'), isA<List>());
    expect(await service.getTypeOfObject('testObject'), equals('test'));
    expect(await service.getTypeOfObject('anotherThing'), equals('unknown'));
  });
}
