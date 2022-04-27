import 'dart:io';
import 'dart:typed_data';

import 'package:biodiversity/components/edit_dialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:image_picker/image_picker.dart' as picker;

/// Picks an Image from either the camera or the gallery and enables the user to edit those
class ImagePickerPage extends StatefulWidget {
  ///Describes the ratio between height and width for the cropped image. By default the ratio is variable
  final double aspectRatio;

  ///URL of the image to replace. To add a new picture without replacing one, use default (null)
  final String originalImageURL;

  ///Function that returns the Image as Uint8List, <br>
  ///the saveImageFunction must: Update the ImageURL in the user/garden Object <br>
  ///AND needs to redirect to the correct page
  ///set a name for the image
  final Function(Uint8List rawImageData) saveImageFunction;

  ///Function that deletes Image at "toDeleteURL", <br>
  ///the deleteImageFunction must set the ImageURL in the user/garden Object to '' (empty string)
  final Function(String toDeleteURL) deleteImageFunction;

  /// Picks an Image from either the camera or the gallery and enables the user to edit those
  ImagePickerPage({
    Key key,
    this.aspectRatio,
    this.originalImageURL,
    @required this.saveImageFunction,
    @required this.deleteImageFunction,
  }) : super(key: key);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  File _imageFile;
  bool _deleteRequested = false;
  bool _hasOriginal = true;
  bool _editMode = false;
  final _picker = picker.ImagePicker();
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (widget.originalImageURL == null || widget.originalImageURL.isEmpty) {
      _hasOriginal = false;
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditDialog(
      abortCallback: () {
        Navigator.of(context).pop();
      },
      saveCallback: (_editMode || _deleteRequested)
          ? () async {
              if (_deleteRequested && !_editMode) {
                widget.deleteImageFunction(widget.originalImageURL);
              } else if (_hasOriginal) {
                widget.saveImageFunction(await _cropImageDataWithNativeLibrary(
                    state: _editorKey.currentState));
                widget.deleteImageFunction(widget.originalImageURL);
              } else {
                widget.saveImageFunction(await _cropImageDataWithNativeLibrary(
                    state: _editorKey.currentState));
              }
            }
          : null,
      title: 'Bild auswählen',
      isScrollable: false,
      body: SizedBox(
        child: Column(
          children: <Widget>[
            if (_hasOriginal && !_editMode)
              OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _editMode = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Bearbeiten')),
            if (_editMode) _EditOptionsButtonBar(),
            // Display EditButtonBar if in editMode
            if (!_hasOriginal &&
                _imageFile ==
                    null) // no Image to display available, use default
              _displayNoImage()
            else if (_hasOriginal &&
                _imageFile == null &&
                !_editMode) // A NetworkImage is available, but editMode is Disabled
              _displayNetworkImage()
            else if (_hasOriginal &&
                _imageFile == null &&
                _editMode) // A NetworkImage is available, and editMode is Enabled
              _editNetworkImage()
            else // A FileImage is available and editMode is Enabled
              _editFileImage(),
            _bottomButtonBar(),
            // Displays three Buttons at the Bottom
          ],
        ),
      ),
    );
  }

  /// Lets the user take a new Picture with their Camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile =
      await _picker.pickImage(source: picker.ImageSource.camera);
    setState(() {
      _imageFile = File(pickedFile.path);
      _editMode = true;
      _deleteRequested = false;
    });
  }

  /// Lets the user choose an Image from their Gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile =
      await _picker.pickImage(source: picker.ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile.path);
      _editMode = true;
      _deleteRequested = false;
    });
  }

  ///Returns an Expanded Widget with A default Image, used as Placeholder if no other available
  Widget _displayNoImage() {
    return Expanded(
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              Theme.of(context).canvasColor.withOpacity(0.3),
              BlendMode.dstATop),
          child: Image(
              color: Theme.of(context).canvasColor.withOpacity(1),
              colorBlendMode: BlendMode.saturation,
              image: const AssetImage('res/Logo_basic.png'))),
    );
  }

  /// Returns an Expanded widget with an Image
  Widget _displayNetworkImage() {
    return Expanded(
      child: Image.network(widget.originalImageURL),
    );
  }

  /// Returns an Expanded widget with an Image to Edit, using a networkImage
  Widget _editNetworkImage() {
    return Expanded(
      child: ExtendedImage.network(
        widget.originalImageURL,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: _editorKey,
        cacheRawData: true,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            cropAspectRatio: widget.aspectRatio,
          );
        },
      ),
    );
  }

  /// Returns an Expanded widget with an Image to Edit, using an Image of type File
  Widget _editFileImage() {
    return Expanded(
      child: ExtendedImage.file(
        _imageFile,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: _editorKey,
        cacheRawData: true,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            cropAspectRatio: widget.aspectRatio,
          );
        },
      ),
    );
  }

  /// Returns a Row With Three Buttons for Editing the Image. Buttons: rotate left, reset, rotate right
  Widget _EditOptionsButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: const Icon(Icons.rotate_left),
            onPressed: () => _editorKey.currentState.rotate(right: false)),
        IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _editorKey.currentState.reset()),
        IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () => _editorKey.currentState.rotate())
      ],
    );
  }

  ///Returns A Wrap that contains three Buttons: Kamera, Entfernen, Galerie
  Widget _bottomButtonBar() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            children: [
              OutlinedButton.icon(
                  onPressed: () async => _pickImageFromCamera(),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Kamera')),
              OutlinedButton.icon(
                  onPressed: !_editMode
                      ? null
                      : () {
                          setState(() {
                            _imageFile = null;
                            _editMode = false;
                            _hasOriginal = false;
                            _deleteRequested = true;
                          });
                        },
                  icon: const Icon(Icons.delete),
                  label: const Text('Entfernen')),
              OutlinedButton.icon(
                  onPressed: () async => _pickImageFromGallery(),
                  icon: const Icon(Icons.photo),
                  label: const Text('Galerie')),
            ],
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _cropImageDataWithNativeLibrary(
      {@required ExtendedImageEditorState state}) async {
    final cropRect = state.getCropRect();
    final action = state.editAction;

    final rotateAngle = action.rotateAngle.toInt();
    final img = state.rawImageData;

    final option = ImageEditorOption();

    if (action.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect));
    }

    if (action.hasRotateAngle) {
      option.addOption(RotateOption(rotateAngle));
    }

    final result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result;
  }
}
