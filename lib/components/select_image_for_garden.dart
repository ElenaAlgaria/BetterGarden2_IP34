import 'dart:typed_data';

import 'package:biodiversity/components/image_picker_page.dart';
import 'package:biodiversity/models/garden.dart';
import 'package:flutter/material.dart';

/// Display Current garden image as button, that leads to changing the garden Image
class SelectGardenImage extends StatefulWidget {
  /// Display Current garden image as button, that leads to changing the garden Image
  SelectGardenImage(
      {Key key,
      @required this.garden,
      @required this.deleteFunction,
      @required this.saveFunction,
      @required this.toSaveImage,
      this.displayText = 'Titelfoto wechseln'})
      : super(key: key);

  ///describes the garden for which the image is being edited
  final Garden garden;

  /// the function that is called to delete the originalimage
  final Function(String toDeleteURL) deleteFunction;

  /// the function that is called to acquire the new imageData
  final Function(Uint8List rawImageData) saveFunction;

  /// The image that will be saved upon saveCallback. used to Display
  final Uint8List toSaveImage;

  /// Text which will be displayed if no picture is selected
  final String displayText;

  @override
  _SelectGardenImageState createState() => _SelectGardenImageState();
}

class _SelectGardenImageState extends State<SelectGardenImage> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePickerPage(
              originalImageURL: widget.garden.imageURL,
              deleteImageFunction: widget.deleteFunction,
              saveImageFunction: widget.saveFunction,
            ),
          ),
        );
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                Theme.of(context).canvasColor.withOpacity(0.25),
                BlendMode.dstATop),
            child: getDisplayedImage(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                color: Colors.black,
              ),
              Text(
                widget.displayText,
                style: const TextStyle(color: Colors.black),
                textScaleFactor: 1.5,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getDisplayedImage() {
    if (widget.toSaveImage == null &&
        (widget.garden.imageURL == null || widget.garden.imageURL.isEmpty)) {
      return Image(
          color: Theme.of(context).canvasColor.withOpacity(1),
          colorBlendMode: BlendMode.saturation,
          image: const AssetImage('res/Logo_basic.png'));
    } else if (widget.toSaveImage != null) {
      return Image.memory(widget.toSaveImage);
    } else {
      return Image.network(widget.garden.imageURL,
          errorBuilder: (context, _, __) => Image(
              color: Theme.of(context).canvasColor.withOpacity(1),
              colorBlendMode: BlendMode.saturation,
              image: const AssetImage('res/Logo_basic.png')));
    }
  }
}
