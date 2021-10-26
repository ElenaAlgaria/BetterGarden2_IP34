import 'dart:math' as math;

import 'package:biodiversity/components/expandable_information_object_card_widget.dart';
import 'package:biodiversity/components/simple_information_object_card_widget.dart';
import 'package:biodiversity/components/tags/flutter_tags.dart';
import 'package:biodiversity/models/information_object.dart';
import 'package:biodiversity/models/tag_item.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Creates a List Widget displaying all provided InformationObjects
class InformationObjectListWidget extends StatefulWidget {
  ///defines if the list uses simple or expandable cards
  final bool useSimpleCard;

  /// if this flag is set, the buttons hinzufügen and merken will be removed
  final bool hideLikeAndAdd;

  /// if this flag is set, the buttons bearbeiten and löschen will be removed
  final bool showDeleteAndEdit;

  /// A list of InformationObjects which should be displayed
  final List<InformationObject> objects;

  /// if this flag is set, the buttons hinzufügen und merken will be aranged in a list.
  /// This is useful when Species and BiodiversityElements are mixed in one list.
  /// Only used with expandable cards
  final bool arrangeLikeAndAddAsRow;

  final ServiceProvider _serviceProvider;

  ///ScrollPhysics for the list of Info
  final ScrollPhysics physics;

  /// Creates a List Widget displaying all provided InformationObjects
  InformationObjectListWidget(
      {Key key,
      this.objects,
      this.showDeleteAndEdit = false,
      this.useSimpleCard = false,
      this.hideLikeAndAdd = false,
      this.arrangeLikeAndAddAsRow = false,
      this.physics = const ScrollPhysics(),
      ServiceProvider serviceProvider})
      : _serviceProvider = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  @override
  _InformationObjectListWidgetState createState() =>
      _InformationObjectListWidgetState();
}

class _InformationObjectListWidgetState
    extends State<InformationObjectListWidget> {
  final _tagStateKey = GlobalKey<TagsState>();
  final List<TagItem> _tagItems = <TagItem>[];
  final editingController = TextEditingController();
  final filterController = TextEditingController();
  final categories = <String>[];
  final categorisedItems = <InformationObject>[];
  final filteredItems = <InformationObject>[];
  bool scroll_visibility = true;

  @override
  void initState() {
    super.initState();
    categorisedItems.addAll(widget.objects);
    filteredItems.addAll(widget.objects);
    for (final item in widget.objects) {
      if (!categories.contains(item.type)) {
        categories.add(item.type);
      }
    }
    for (final s in categories) {
      _tagItems.add(TagItem(s, false));
    }
  }

  void filterClassResults() {
    final activeItems = _tagStateKey.currentState.getAllActiveItems;
    if (activeItems != null && activeItems.isNotEmpty) {
      final filterResults = <InformationObject>[];
      for (final item in widget.objects) {
        for (final activeTag in activeItems) {
          if (item.type.contains(activeTag)) {
            filterResults.add(item);
          }
        }
      }
      setState(() {
        categorisedItems.clear();
        categorisedItems.addAll(filterResults);
      });
    } else {
      setState(() {
        categorisedItems.clear();
        categorisedItems.addAll(widget.objects);
      });
    }

    filterSearchResults('');
  }

  void filterSearchResults(String query) {
    final visibleObjects = <InformationObject>[];
    visibleObjects.addAll(categorisedItems);
    if (query.isNotEmpty) {
      final searchResults = <InformationObject>[];
      for (final item in visibleObjects) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(item);
        }
      }
      setState(() {
        filteredItems.clear();
        filteredItems.addAll(searchResults);
      });
    } else {
      setState(() {
        filteredItems.clear();
        filteredItems.addAll(categorisedItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  controller: editingController,
                  decoration: const InputDecoration(
                      labelText: 'Suchen',
                      hintText: 'Suchen',
                      prefixIcon: Icon(Icons.search),
                      border: UnderlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)))),
                ),
              ],
            ),
          ),
          if (categories.length > 1)
            Visibility(
              visible: scroll_visibility,
              replacement: IconButton(
                onPressed: () {
                  setState(() {
                    scroll_visibility = true;
                  });
                },
                iconSize: 20,
                icon: Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tags(
                        key: _tagStateKey,
                        itemCount: _tagItems.length,
                        alignment: WrapAlignment.start,
                        runSpacing: 6,
                        horizontalScroll: false,
                        heightHorizontalScroll: 40,
                        itemBuilder: (index) {
                          final item = _tagItems[index];

                          return ItemTags(
                            key: Key(index.toString()),
                            index: index,
                            title: item.title,
                            active: item.active,
                            textStyle: const TextStyle(
                              fontSize: 14,
                            ),
                            textActiveColor: Colors.black,
                            elevation: 3,
                            textOverflow: TextOverflow.fade,
                            combine: ItemTagsCombine.withTextBefore,
                            onPressed: (item) {
                              filterClassResults();
                            },
                            activeColor: Colors.grey[300],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          );
                        },
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              _tagStateKey.currentState.setAllItemsActive();
                              filterClassResults();
                            },
                            child: const Text('Alles selektieren'),
                          ),
                          TextButton(
                            onPressed: () {
                              _tagStateKey.currentState.setAllItemsInactive();
                              filterClassResults();
                            },
                            child: const Text('Selektion aufheben'),
                          ),
                          IconButton(
                            alignment: Alignment.bottomCenter,
                            onPressed: () {
                              setState(() {
                                scroll_visibility = false;
                              });
                            },
                            iconSize: 20,
                            icon: Transform.rotate(
                              angle: 90 * math.pi / 180,
                              child: const Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Leider keine Einträge vorhanden',
                            textScaleFactor: 2,
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.emoji_nature,
                            size: 80,
                          )
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: widget.physics,
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final element = filteredItems.elementAt(index);
                        return widget.useSimpleCard
                            ? SimpleInformationObjectCard(
                                element,
                                additionalInfo: element.additionalInfo,
                                serviceProvider: widget._serviceProvider,
                              )
                            : ExpandableInformationObjectCard(
                          element,
                                hideLikeAndAdd: widget.hideLikeAndAdd,
                                additionalInfo: element.additionalInfo,
                                showDeleteAndEdit: widget.showDeleteAndEdit,
                                serviceProvider: widget._serviceProvider,
                                arrangeLikeAndAddAsRow:
                                    widget.arrangeLikeAndAddAsRow,
                              );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 5);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
