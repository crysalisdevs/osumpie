import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

// flutter packages pub run build_runner watch --delete-conflicting-outputs

part 'node.g.dart';

/// The Node class that contains the node properties
@JsonSerializable(nullable: false)
class RecipeNode extends StatefulWidget {
  double top;
  double left;

  String title;
  double width;
  String author;
  double height;

  bool isDisabled;
  Uri gitUpdathPath;
  String description;

  String connectToUuid;

  Map<String, dynamic> properties;

  RecipeNode({
    @required this.top,
    @required this.left,
    @required this.title,
    @required this.width,
    @required this.author,
    @required this.height,
    @required this.isDisabled,
    @required this.description,
    @required this.gitUpdathPath,
    @required this.properties,
    this.connectToUuid,
  });

  factory RecipeNode.fromJson(Map<String, dynamic> item) => _$RecipeNodeFromJson(item);
  Map<String, dynamic> toJson() => _$RecipeNodeToJson(this);

  @override
  _RecipeNodeState createState() => _RecipeNodeState();
}

class _RecipeNodeState extends State<RecipeNode> {
  GlobalKey _key = GlobalKey();
  double _xOff;
  double _yOff;

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
      top: widget.top,
      left: widget.left,
      width: widget.width,
      height: widget.height,
      child: Draggable(
        child: buildNodeUi,
        feedback: SizedBox(
          width: widget.width + 10,
          height: widget.height + 10,
          child: buildNodeUi,
        ),
        childWhenDragging: buildNodeUi,
        onDragEnd: (drag) {
          setState(() {
            widget.top = drag.offset.dy - _yOff;
            widget.left = drag.offset.dx - _xOff;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_getRenderOffsets);
    super.initState();
  }

  void _getRenderOffsets(_) {
    final renderBoxWidget = _key.currentContext.findRenderObject() as RenderBox;
    final offset = renderBoxWidget.localToGlobal(Offset.zero);

    _yOff = offset.dy - widget.top;
    _xOff = offset.dx - widget.left;
  }
}
