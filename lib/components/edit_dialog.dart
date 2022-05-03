import 'package:biodiversity/components/drawer.dart';
import 'package:flutter/material.dart';

/// Simple class to display a save-abort dialog
class EditDialog extends StatelessWidget {
  /// Text which is displayed on the abort button
  final String abort;

  /// Icon which is displayed on the abort button
  final IconData abortIcon;

  /// Text which is displayed on the save button
  final String save;

  /// Icon which is displayed on the save button
  final IconData saveIcon;

  /// title above the page
  final String title;

  /// callback function which is called upon abort
  final Function abortCallback;

  /// callback function which is called upon save
  final Function saveCallback;

  /// callback which is used with the cross at the top of the page
  final Function cancelCallback;

  /// content to display on the page
  final Widget body;

  /// scroll physics for the body
  final bool isScrollable;

  /// Simple class to display a save-abort dialog
  EditDialog(
      {this.abort = 'Abbrechen',
      this.save = 'Speichern',
      this.saveIcon = Icons.save,
      this.abortIcon = Icons.clear,
      @required this.title,
      @required this.abortCallback,
      @required this.saveCallback,
      Function cancelCallback,
      this.isScrollable = true,
      @required this.body,
      Key key})
      : cancelCallback = cancelCallback ?? abortCallback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: MyDrawer(),
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.onSurface),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: cancelCallback),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: isScrollable
                      ? ListView(
                          shrinkWrap: true,
                          children: [
                            body,
                          ],
                        )
                      : body,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      label: Text(abort),
                      icon: Icon(abortIcon),
                      style: ButtonStyle(
                          visualDensity: VisualDensity.adaptivePlatformDensity),
                      onPressed: abortCallback,
                    ),
                    ElevatedButton.icon(
                      label: Text(save),
                      icon: Icon(saveIcon),
                      style: ButtonStyle(
                          visualDensity: VisualDensity.adaptivePlatformDensity),
                      onPressed: saveCallback,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
