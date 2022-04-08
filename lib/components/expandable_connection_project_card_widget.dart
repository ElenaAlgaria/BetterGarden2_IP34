import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/project_page/project_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:biodiversity/services/services_library.dart';
import 'package:biodiversity/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// an unspecific expandable card which displays a ConnectionProject
class ExpandableConnectionProjectCard extends StatefulWidget {
  /// which ConnectionProject the cards shows
  final ConnectionProject object;

  /// if this flag is set, the buttons hinzufügen and merken will be removed
  final bool hideLikeAndAdd;

  /// if this flag is set, the buttons hinzufügen und merken will be arranged in a list.
  /// This is useful when Species and BiodiversityElements are mixed in one list
  /// this has no effect if the screen size is too small
  final bool arrangeLikeAndAddAsRow;

  /// if this flag is set, the card is used for species and hinzufügen and merken will be changed to Aktivitätsradius and merken
  final bool isSpecies;

  ///If this flag is set, the button "Beitreten" will be shown. Else, the Button "Vernetzungsprojekt verlassen" will be shown
  final bool joinedProject;

  /// additional Info to be displayed instead of hinzufügen and merken buttons.
  /// the Buttons will be automatically removed if this string is set
  final String additionalInfo;

  final ServiceProvider _serviceProvider;

  /// show a card to the provided ConnectionProject
  ExpandableConnectionProjectCard(this.object,
      {hideLikeAndAdd = false,
      this.additionalInfo,
      this.joinedProject,
      arrangeLikeAndAddAsRow = false,
      ServiceProvider serviceProvider,
      Key key})
      : _serviceProvider = serviceProvider ??= ServiceProvider.instance,
        hideLikeAndAdd = hideLikeAndAdd || additionalInfo != null,
        arrangeLikeAndAddAsRow =
            arrangeLikeAndAddAsRow || additionalInfo != null,
        isSpecies = object is Species,
        super(key: key);

  @override
  _ExpandableConnectionProjectCardState createState() =>
      _ExpandableConnectionProjectCardState();
}

class _ExpandableConnectionProjectCardState
    extends State<ExpandableConnectionProjectCard> {
  bool _expanded = false;
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    String _unit;
    final garden = Provider.of<Garden>(context, listen: false);
    if (widget.object.runtimeType == BiodiversityMeasure) {
      final biodiversityObject = widget.object as BiodiversityMeasure;
      if (biodiversityObject.dimension == 'Fläche') {
        _unit = 'm\u00B2';
      } else if (biodiversityObject.dimension == 'Linie') {
        _unit = 'm';
      } else {
        _unit = 'Stück';
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          color: const Color.fromRGBO(200, 200, 200, 1),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(4)),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _expanded ? 100 : 0,
                child: widget._serviceProvider.imageService.getImage(
                  widget.object.title,
                  widget.object.title,
                )),
          ),
          ExpansionTile(
            onExpansionChanged: (value) {
              setState(() {
                _expanded = value;
              });
            },
            title: AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.object.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  if (!widget.hideLikeAndAdd &&
                      (!widget.arrangeLikeAndAddAsRow || _screenWidth < 400))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!widget.isSpecies)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                            label: const Text('hinzufügen'),
                            onPressed: () {
                              _handle_add_measure_to_garden(context);
                            },
                            style: const ButtonStyle(
                                visualDensity: VisualDensity.compact),
                          ),
                        TextButton.icon(
                          icon: Icon(
                            Icons.favorite,
                            color: Provider.of<User>(context)
                                    .doesLikeElement(widget.object.title)
                                ? Colors.red
                                : Colors.black,
                            size: 20,
                          ),
                          label: const Text('merken'),
                          onPressed: () {
                            _handle_like_button(context);
                          },
                          style: const ButtonStyle(
                              visualDensity: VisualDensity.compact),
                        ),
                      ],
                    ),
                  if (!widget.hideLikeAndAdd &&
                      (widget.arrangeLikeAndAddAsRow && _screenWidth >= 400))
                    Consumer<User>(builder: (context, user, child) {
                      if (user == null) {
                        return const Text('');
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!widget.isSpecies)
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _handle_add_measure_to_garden(context);
                              },
                            ),
                          TextButton.icon(
                            label: const Text('merken'),
                            icon: Icon(
                              Icons.favorite,
                              color: user.doesLikeElement(widget.object.title)
                                  ? Colors.red
                                  : Colors.black38,
                            ),
                            onPressed: () {
                              _handle_like_button(context);
                            },
                          ),
                        ],
                      );
                    }),
                  const SizedBox(width: 4),
                ],
              ),
              // expanded card
              secondChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(widget.object.title,
                        softWrap: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  if (!widget.hideLikeAndAdd)
                    Consumer<User>(builder: (context, user, child) {
                      if (user == null) {
                        return const Text('');
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!widget.isSpecies)
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _handle_add_measure_to_garden(context);
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: user.doesLikeElement(widget.object.title)
                                  ? Colors.red
                                  : Colors.black38,
                            ),
                            onPressed: () {
                              _handle_like_button(context);
                            },
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            // childrenPadding: const EdgeInsets.all(0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 0),
                  ),
                  Text(
                      ServiceProvider.instance.speciesService
                              .getSpeciesByReference(
                                  widget.object.targetSpecies)
                              ?.name ??
                          '',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 0),
                child: Text(
                  widget.object.description,
                  softWrap: true,
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 16, top: 10),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: 'Teilnehmende (' +
                                  widget.object.gardens.length.toString() +
                                  ')',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          flag
                              ? const TextSpan(text: '')
                              : TextSpan(
                                  text: '\n' +
                                      getLinksOfGardensOfProject(
                                              widget.object.gardens)
                                          .join('\n'),
                                  style: const TextStyle(color: Colors.black))
                        ]))),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        flag = !flag;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 30),
                          child: Icon(flag
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 15),
                  child: TextButton(
                    onPressed: () {
                      if (_expanded) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProjectPage(
                                  project: widget.object,
                                  joinedProject: widget.joinedProject)),
                        );
                      }
                    },
                    child: const Text(
                      'Weitere Infos',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  ///returns a list of links of a project, tap on link to see location of garden on map
  List<String> getLinksOfGardensOfProject(
      List<DocumentReference<Object>> gardenRef) {
    List<User> users;
    users = ServiceProvider.instance.userService.getAllUsers();
    var gardens = gardenRef.map(
        (e) => ServiceProvider.instance.gardenService.getGardenByReference(e));
    var allUsers = ServiceProvider.instance.userService.getAllUsers();
    var gardenNames = gardens
        .map((e) =>
            '  •  ' +
            e.name +
            ' von ' +
            (allUsers
                    ?.firstWhere(
                        (user) =>
                            user.gardenReferences?.contains(e.reference) ??
                            false,
                        orElse: () => null)
                    ?.nickname ??
                'Anonymous'))
        .toList();

    // TODO: return every gardenName with a link, with which you access the map with the location of the garden and open the corresponding expandable card
    return gardenNames;
  }

  ///handles the result of a tap on a like "merken" button
  void _handle_like_button(BuildContext context) {
    if (Provider.of<User>(context, listen: false).isLoggedIn) {
      Provider.of<User>(context, listen: false)
          .likeUnlikeElement(widget.object.title);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte melde Dich zuerst an')));
    }
  }

  ///handles the result of a tap on a add "hinzufügen" button
  void _handle_add_measure_to_garden(BuildContext context) {
    if (Provider.of<User>(context, listen: false).isLoggedIn) {
      if (ServiceProvider.instance.gardenService
          .getAllGardensFromUser(Provider.of<User>(context, listen: false))
          .isNotEmpty) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Bitte erstelle zuerst einen Garten')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte melde Dich zuerst an')));
    }
  }
}
