import 'package:biodiversity/models/biodiversity_measure.dart';
import 'package:biodiversity/models/connection_project.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/species.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:biodiversity/services/services_library.dart';
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

  /// additional Info to be displayed instead of hinzufügen and merken buttons.
  /// the Buttons will be automatically removed if this string is set
  final String additionalInfo;

  final ServiceProvider _serviceProvider;

  /// show a card to the provided ConnectionProject
  ExpandableConnectionProjectCard(this.object,
      {hideLikeAndAdd = false,
        this.additionalInfo,
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
            childrenPadding: const EdgeInsets.all(15),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 10),
                child: Text(
                  widget.object.description,
                  softWrap: true,
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5, top: 20),
                  ),
                  Text(ServiceProvider.instance.speciesService
                      .getSpeciesByReference(widget.object.targetSpecies)
                      ?.name ?? ''),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
