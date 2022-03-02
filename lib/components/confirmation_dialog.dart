import 'package:flutter/material.dart';

/// The `title` argument is used for the title of the alert dialog.
/// The `content` argument is used for the content of the alert dialog.
/// The `textOK` argument is used for the text of the 'OK' Button of the alert dialog.
/// The `textCancel` argument is used for the text of the 'Cancel' Button of the alert dialog.
///
/// Returns a [Future<bool>].
Future<bool> confirm(
  BuildContext context, {
  Widget title,
  Widget content,
  Widget textOK,
  Widget textCancel,
}) async {
  final isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title,
        content: (content != null)
            ? content
            : const Text('Bist du sicher, dass du fortfahren willst?'),
        actions: <Widget>[
          TextButton(
            child: textCancel ?? const Text('Abbrechen'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: textOK ?? const Text('Ja'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}
