import 'package:biodiversity/components/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a page with the logo at the top and the green waves at the bottom.
class LogoAndWavesScreen extends StatelessWidget {
  /// Width of the logo at the top.
  final double logoSize;

  /// Width of the border around the screen.
  final double borderInsets;

  /// The widgets wich should be displayed
  final List<Widget> children;

  /// The title shown in the app bar
  final String title;

  /// the provided children will be displayed beneath the logo
  LogoAndWavesScreen(
      {this.children,
      this.title = '',
      this.logoSize = 180,
      this.borderInsets = 30,
      Key key})
      : super(key: key) {
    if (logoSize > 0) {
      children.insert(
          0,
          Center(
            child: Image.asset(
              'res/Logo_wtext.png',
              width: logoSize,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: MyDrawer(),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraint.maxHeight,
                  minWidth: constraint.maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(borderInsets),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                  SvgPicture.asset(
                    'res/gardenDrawer_color.svg',
                    width: constraint.maxWidth,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
