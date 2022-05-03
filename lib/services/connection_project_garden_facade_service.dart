import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/services_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A service which loads manages interactions of gardens and connectionprojects
class ConnectionProjectGardenFacadeService extends ChangeNotifier {
  /// init the service, should only be used once
  ConnectionProjectGardenFacadeService({StorageProvider storageProvider});

  @override
  void dispose() {
    super.dispose();
  }

  bool isGardenInRangeOfConnectionProject(
      Garden garden, ConnectionProject connectionProject) {
    var radius = ServiceProvider.instance.speciesService
        .getSpeciesByReference(connectionProject.targetSpecies)
        .radius;
    return connectionProject.gardens.any((element) {
      var currentGarden =
          ServiceProvider.instance.gardenService.getGardenByReference(element);
      if (currentGarden == null) return false;
      return currentGarden.isInRange(garden, radius);
    });
  }

  void deleteAllGardensFromUser(User user) {
    ServiceProvider.instance.gardenService
        .getAllGardensFromUser(user)
        .forEach((element) => fullyDeleteGarden(element));
  }

  void fullyDeleteGarden(Garden garden) {
    ServiceProvider.instance.gardenService.deleteGarden(garden);
    ServiceProvider.instance.userService
        .getAllUsers()
        .where((element) => element.gardenReferences.contains(garden.reference))
        ?.forEach((element) => element.deleteGarden(garden));
    deleteGardenFromAllConnectionProjects(garden);
  }

  List<Garden> getAllGardensOfConnectionProject(
      ConnectionProject connectionProject) {
    return connectionProject.gardens.map((element) =>
        ServiceProvider.instance.gardenService.getGardenByReference(element));
  }

  void deleteGardenFromAllConnectionProjects(Garden garden) {
    var projectsToDelete = <ConnectionProject>[];
    getAllConnectionProjectsOfGarden(garden)?.forEach((element) {
      element.removeGarden(garden.reference);
      if (element.gardens.isEmpty) {
        projectsToDelete.add(element);
      }
    });
    projectsToDelete.forEach((element) => ServiceProvider
        .instance.connectionProjectService
        .deleteConnectionProject(element));
  }

  List<ConnectionProject> getAllConnectionProjectsOfGarden(Garden garden) {
    return ServiceProvider.instance.connectionProjectService
        .getAllConnectionProjects()
        .where((element) => element.gardens.contains(garden.reference))
        ?.toList();
  }
}
