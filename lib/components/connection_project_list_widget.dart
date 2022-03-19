import 'dart:math' as math;

import 'package:biodiversity/components/expandable_connection_project_card_widget.dart';
import 'package:biodiversity/components/simple_connection_project_card_widget.dart';
import 'package:biodiversity/components/tags/flutter_tags.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/tag_item.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:flutter/material.dart';

/// Creates a List Widget displaying all provided ConnectionProjects
class ConnectionProjectListWidget extends StatefulWidget {
  ///defines if the list uses simple or expandable cards
  final bool useSimpleCard;

  /// if this flag is set, the buttons hinzufügen and merken will be removed
  final bool hideLikeAndAdd;

  /// A list of ConnectionProjects which should be displayed
  final List<ConnectionProject> objects;

  /// if this flag is set, the buttons hinzufügen und merken will be aranged in a list.
  /// This is useful when Species and BiodiversityElements are mixed in one list.
  /// Only used with expandable cards
  final bool arrangeLikeAndAddAsRow;

  final ServiceProvider _serviceProvider;

  ///ScrollPhysics for the list of Info
  final ScrollPhysics physics;

  /// Creates a List Widget displaying all provided ConnectionProjects
  ConnectionProjectListWidget(
      {Key key,
      this.objects,
      this.useSimpleCard = false,
      this.hideLikeAndAdd = false,
      this.arrangeLikeAndAddAsRow = false,
      this.physics = const ScrollPhysics(),
      ServiceProvider serviceProvider})
      : _serviceProvider = serviceProvider ?? ServiceProvider.instance,
        super(key: key);

  @override
  _ConnectionProjectListWidgetState createState() =>
      _ConnectionProjectListWidgetState();
}

class _ConnectionProjectListWidgetState
    extends State<ConnectionProjectListWidget> {
  final _tagStateKey = GlobalKey<TagsState>();
  final List<TagItem> _tagItems = <TagItem>[];
  final editingController = TextEditingController();
  final filterController = TextEditingController();
  final categories = <String>[];
  final categorisedItems = <ConnectionProject>[];
  final filteredItems = <ConnectionProject>[];
  bool scroll_visibility = true;

  @override
  void initState() {
    super.initState();
    categorisedItems.addAll(widget.objects);
    filteredItems.addAll(widget.objects);
  }

  void filterSearchResults(String query) {
    final visibleObjects = <ConnectionProject>[];
    visibleObjects.addAll(categorisedItems);
    if (query.isNotEmpty) {
      final searchResults = <ConnectionProject>[];
      for (final item in visibleObjects) {
        if (item.title.toLowerCase().contains(query.toLowerCase())) {
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
                    children: [],
                  ),
                ),
              ),
            ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: filteredItems == null || filteredItems.isEmpty
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
                            ? SimpleConnectionProjectCard(
                                element,
                                serviceProvider: widget._serviceProvider,
                              )
                            : ExpandableConnectionProjectCard(
                                element,
                                hideLikeAndAdd: widget.hideLikeAndAdd,
                                additionalInfo: element.description,
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
