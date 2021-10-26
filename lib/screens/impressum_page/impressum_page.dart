import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/models/storage_provider.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the impressum
class ImpressumPage extends StatelessWidget {
  /// Displays the impressum
  ImpressumPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impressum')),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            FutureBuilder(
              future: StorageProvider.instance
                  .getTextFromFileStorage('impressum/impressum.md'),
              builder: (context, text) {
                if (text.hasData) {
                  return MarkdownBody(
                    data: text.data,
                    onTapLink: (_, url, __) => launch(url),
                  );
                } else {
                  return const Center(child: Text('Loading'));
                }
              },
            ),
            const SizedBox(height: 40),
            FutureBuilder(
                future: ServiceProvider.instance.imageService
                    .getListOfImageURLs(name: 'impressum'),
                builder: (context, urls) {
                  if (urls.hasData) {
                    final images = <Widget>[];
                    for (final url in urls.data) {
                      images.add(ServiceProvider.instance.imageService
                          .getImageByUrl(url, width: 100, height: 100));
                    }
                    return Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: images,
                    );
                  } else {
                    return const Center(child: Text('Loading'));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
