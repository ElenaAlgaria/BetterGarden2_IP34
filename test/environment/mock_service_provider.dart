import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/biodiversity_service.dart';
import 'package:biodiversity/services/garden_service.dart';
import 'package:biodiversity/services/image_service.dart';
import 'package:biodiversity/services/map_marker_service.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:biodiversity/services/species_service.dart';
import 'package:biodiversity/services/take_home_message_service.dart';
import 'package:mockito/mockito.dart';

import 'mock_storage_provider.dart';

class MockServiceProvider extends Mock implements ServiceProvider {
  StorageProvider storageProvider;
  ServiceProvider serviceProvider;

  MockServiceProvider({this.storageProvider}) {
    storageProvider ??= MockStorageProvider();
  }

  @override
  GardenService get gardenService =>
      GardenService(storageProvider: storageProvider);

  @override
  ImageService get imageService =>
      ImageService(storageProvider: storageProvider);

  @override
  BiodiversityService get biodiversityService => BiodiversityService(
      storageProvider: storageProvider, serviceProvider: this);

  @override
  SpeciesService get speciesService =>
      SpeciesService(storageProvider: storageProvider);

  @override
  TakeHomeMessageService get takeHomeMessageService =>
      TakeHomeMessageService(storageProvider: storageProvider);

  @override
  MapMarkerService get mapMarkerService =>
      MapMarkerService(storageProvider: storageProvider);
}
