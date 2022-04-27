import 'package:flutter/material.dart';

class GlobalModel {
  const GlobalModel({
    this.platform,
    this.textDirection,
  });

  final TargetPlatform platform;
  final TextDirection textDirection;

  GlobalModel copyWith({
    TargetPlatform platform,
    TextDirection textDirection,
  }) {
    return GlobalModel(
      platform: platform ?? this.platform,
      textDirection: textDirection ?? this.textDirection,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GlobalModel &&
      platform == other.platform &&
      textDirection == other.textDirection;

  @override
  int get hashCode => hashValues(platform, textDirection);

  static GlobalModel of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    return scope.modelBindingState.currentModel;
  }

  static void update(BuildContext context, GlobalModel newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    scope.modelBindingState.updateModel(newModel);
  }
}

class _ModelBindingScope extends InheritedWidget {
  _ModelBindingScope({
    Key key,
    @required this.modelBindingState,
    Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

class ModelBinding extends StatefulWidget {
  ModelBinding({
    Key key,
    this.initialModel = const GlobalModel(),
    this.child,
  })  : assert(initialModel != null),
        super(key: key);

  final GlobalModel initialModel;
  final Widget child;

  @override
  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  GlobalModel currentModel;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  void updateModel(GlobalModel newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
