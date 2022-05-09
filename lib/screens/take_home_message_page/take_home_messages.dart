import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/information_object_list_widget.dart';
import 'package:biodiversity/screens/take_home_message_page/take_home_message_general_information_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Page which displays some key messages for the gardeners
class TakeHomeMessagePage extends StatelessWidget {
  /// Page which displays some key messages for the gardeners
  TakeHomeMessagePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wissensgrundlagen'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TakeHomeMessageGeneralInformationPage()),
                );
              },
              icon: const Icon(Icons.help))
        ],
      ),
      drawer: MyDrawer(),
      body: InformationObjectListWidget(
        objects: ServiceProvider.instance.takeHomeMessageService
            .getFullTakeHomeMessageObjectList(),
      ),
    );
  }
}
