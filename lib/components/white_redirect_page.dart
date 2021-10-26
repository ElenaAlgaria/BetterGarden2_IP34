import 'package:flutter/material.dart';

/// A white page that displays text and then redirects to a new page
class WhiteRedirectPage extends StatelessWidget {
  /// The text which will be displayed
  final String text;

  /// the Page which you will be redirected to after the timeout
  final Widget route;

  /// The duration of the timeout
  final int duration;

  /// A white page that displays text and then redirects to a new page
  WhiteRedirectPage(this.text, this.route, {Key key, this.duration = 2500})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: duration)).then((value) =>
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => route)));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: Text(
          text,
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
          textAlign: TextAlign.center,
        )),
      ),
    );
  }
}
