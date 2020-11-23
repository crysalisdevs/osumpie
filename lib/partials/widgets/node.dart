import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:json_annotation/json_annotation.dart';

// flutter packages pub run build_runner watch --delete-conflicting-outputs

part 'node.g.dart';

/// The Node class that contains the node properties
@JsonSerializable(nullable: false)
class RecipeNode extends StatefulWidget {
  final double top;
  final double left;

  final String title;
  final double width;
  final String author;
  final double height;

  final bool isDisabled;
  final Uri gitUpdathPath;
  final String description;

  final Map<String, dynamic> properties;

  RecipeNode({
    this.top,
    this.left,
    this.title,
    this.width,
    this.author,
    this.height,
    this.isDisabled,
    this.description,
    this.gitUpdathPath,
    this.properties,
  });

  factory RecipeNode.fromJson(Map<String, dynamic> item) => _$RecipeNodeFromJson(item);
  @override
  _RecipeNodeState createState() => _RecipeNodeState();

  Map<String, dynamic> toJson() => _$RecipeNodeToJson(this);
}

class _RecipeNodeState extends State<RecipeNode> {
  GlobalKey _key = GlobalKey();
  double _top;
  double _left;
  double _xOff;
  double _yOff;
  double _width;
  double _height;

  Widget get buildNodeUi => GradientCard(
      gradient: Gradients.deepSpace,
      child: Center(
        child: Text(
          "Hi",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: _key,
      top: _top,
      left: _left,
      width: _width,
      height: _height,
      child: Draggable(
        child: buildNodeUi,
        feedback: SizedBox(
          width: _width + 10,
          height: _height + 10,
          child: buildNodeUi,
        ),
        childWhenDragging: buildNodeUi,
        onDragEnd: (drag) {
          setState(() {
            _top = drag.offset.dy - _yOff;
            _left = drag.offset.dx - _xOff;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_getRenderOffsets);
    _top = widget.top;
    _left = widget.left;
    _width = widget.width;
    _height = widget.height;
    super.initState();
  }

  void _getRenderOffsets(_) {
    final renderBoxWidget = _key.currentContext.findRenderObject() as RenderBox;
    final offset = renderBoxWidget.localToGlobal(Offset.zero);

    _yOff = offset.dy - _top;
    _xOff = offset.dx - _left;
  }
}
