import 'package:flutter/material.dart';

/// Displays a title with a line as separator
class TextFieldWithDescriptor extends StatelessWidget {
  /// Title above the line
  final String descriptor;

  /// Widget below the line
  final Widget content;

  /// Displays a title with a line as separator
  /// Descriptor is the title above the line, content the thing below
  TextFieldWithDescriptor(this.descriptor, this.content, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Transform.translate(
            offset: const Offset(0.0, 8.0),
            child: Text(
              descriptor,
              style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
            ),
          ),
          const Divider(),
          Transform.translate(
            offset: const Offset(0.0, -8.0),
            child: content,
          ),
        ],
      ),
    );
  }
}
