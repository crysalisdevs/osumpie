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
  Map<String, dynamic> toJson() => _$RecipeNodeToJson(this);

  @override
  _RecipeNodeState createState() => _RecipeNodeState();
}

class _RecipeNodeState extends State<RecipeNode> {
  GlobalKey _key = GlobalKey();
  double top, left;
  double xOff, yOff;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: _key,
      top: top,
      left: left,
      child: Draggable(
        child: Icon(Icons.input),
        feedback: Icon(Icons.input),
        childWhenDragging: Container(),
        onDragEnd: (drag) {
          setState(() {
            top = drag.offset.dy - yOff;
            left = drag.offset.dx - xOff;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    top = widget.top;
    left = widget.left;
    super.initState();
  }

  void _afterLayout(_) => _getRenderOffsets();

  void _getRenderOffsets() {
    final RenderBox renderBoxWidget = _key.currentContext.findRenderObject();
    final offset = renderBoxWidget.localToGlobal(Offset.zero);

    yOff = offset.dy - top;
    xOff = offset.dx - left;
  }
}
