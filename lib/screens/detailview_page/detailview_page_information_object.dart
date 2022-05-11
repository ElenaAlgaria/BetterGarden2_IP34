import 'dart:developer';

import 'package:biodiversity/components/drawer.dart';
import 'package:biodiversity/components/tags/flutter_tags.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/information_list_page/add_element_to_garden_amount_page.dart';
import 'package:biodiversity/screens/information_list_page/delete_element_garden_page.dart';
import 'package:biodiversity/screens/information_list_page/edit_element_to_garden_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the details of a BiodiversityMeasure
class DetailViewPageInformationObject extends StatefulWidget {
  /// The BiodiversityMeasure element which will be displayed
  final InformationObject object;

  /// which page the navigator should go to if no page is on the stack below
  final PageRoute fallbackRoute;

  /// if this flag is set, the buttons hinzufügen and merken will be removed
  final bool hideLikeAndAdd;

  /// if this flag is set, the buttons bearbeiten and löschen will be removed
  final bool showDeleteAndEdit;

  /// if this flag is set, the card is used for species and hinzufügen and merken will be changed to Aktivitätsradius and merken
  final bool isSpecies;

  /// Shows the details of a BiodiversityMeasure
  const DetailViewPageInformationObject(this.object,
      {this.fallbackRoute,
      this.hideLikeAndAdd = false,
      this.isSpecies = false,
      this.showDeleteAndEdit = false,
      Key key})
      : super(key: key);

  @override
  _DetailViewPageInformationObjectState createState() =>
      _DetailViewPageInformationObjectState();
}

class _DetailViewPageInformationObjectState
    extends State<DetailViewPageInformationObject> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Details: ${widget.object.name}',
        softWrap: true,
      )),
      drawer: MyDrawer(),
      body: Column(
        children: [
          ServiceProvider.instance.imageService
              .getImage(widget.object.name, widget.object.type, height: 150),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: Text(
                  '© ' + getCopyrightName(widget.object.name) ?? '',
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: Text(getCaption(widget.object.name) ?? '',
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : Navigator.push(context, widget.fallbackRoute);
            },
            child: Row(
              children: [
                const Icon(Icons.arrow_back),
                const SizedBox(width: 5),
                const Text('Zurück zur Liste'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _headRow(),
                const SizedBox(height: 10),
                MarkdownBody(
                  data: widget.object.description,
                  onTapLink: (text, link, title) => launch(link),
                ),
                const SizedBox(
                  height: 20,
                ),
                _showTags(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            widget.object.name,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        if (!widget.hideLikeAndAdd)
          Consumer<User>(
            builder: (context, user, child) {
              return Row(
                children: [
                  if (!widget.isSpecies)
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddElementToGardenAmountPage(
                                    object: widget.object,
                                  )),
                        );
                      },
                    ),
                  // : const IconButton(
                  //     icon: Icon(
                  //       Icons.add_circle_outline_outlined,
                  //     ),
                  //     onPressed: null,
                  //   ),
                  IconButton(
                    icon: user.doesLikeElement(widget.object.name)
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_border),
                    color: user.doesLikeElement(widget.object.name)
                        ? Colors.red
                        : Colors.black38,
                    onPressed: () {
                      setState(() {
                        user.likeUnlikeElement(widget.object.name);
                      });
                    },
                  ),
                ],
              );
            },
          ),
        if (widget.showDeleteAndEdit)
          Consumer<User>(builder: (context, user, child) {
            if (user == null) {
              return const Text('');
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeleteElementGardenPage(
                                object: widget.object,
                              )),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditElementPage(
                                object: widget.object,
                              )),
                    ),
                  },
                ),
              ],
            );
          }),
      ],
    );
  }

  Widget _showTags() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.object.associationMap.length,
      itemBuilder: (context, category) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.object.associationMap.keys.elementAt(category),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Tags(
              itemCount: widget.object.associationMap.values
                  .elementAt(category)
                  .length,
              spacing: 4,
              runSpacing: -2,
              itemBuilder: (index) {
                final element = widget.object.associationMap.values
                    .elementAt(category)
                    .elementAt(index);
                return ElevatedButton(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewPageInformationObject(
                            element,
                            fallbackRoute: widget.fallbackRoute),
                      ),
                    );
                  },
                  child: Text(
                    element.name,
                  ),
                );
              },
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 20,
        );
      },
    );
  }

  String getCopyrightName(String name) {
    return ServiceProvider.instance.imageService.copyrightInfo.entries
            .firstWhere((element) => element.key.startsWith(name.toLowerCase()),
                orElse: () => null)
            ?.value ??
        '';
  }

  String getCaption(String name) {
    return ServiceProvider.instance.imageService.caption.entries
            .firstWhere((element) => element.key.startsWith(name.toLowerCase()),
                orElse: () => null)
            ?.value ??
        '';
  }
}
