import 'package:flutter/widgets.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:json_annotation/json_annotation.dart';

// flutter packages pub run build_runner watch --delete-conflicting-outputs

part 'node.g.dart';

/// The Node class that contains the node properties
@JsonSerializable(nullable: false)
class RecipeNode extends StatefulWidget {
  final double top;
  final double left;
  final double right;
  final double bottom;
  final double width;
  final double height;

  final String title;
  final String description;
  final Map<String, dynamic> parameters;

  static List<RecipeNode> nodes = [];

  RecipeNode({
    @required this.top,
    @required this.left,
    @required this.right,
    @required this.bottom,
    @required this.width,
    @required this.height,
    @required this.title,
    @required this.description,
    @required this.parameters,
  }) {
    nodes.add(this);
  }

  factory RecipeNode.fromJson(Map<String, dynamic> item) => _$RecipeNodeFromJson(item);
  Map<String, dynamic> toJson() => _$RecipeNodeToJson(this);
  @override
  _RecipeNodeState createState() => _RecipeNodeState();
}

class _RecipeNodeState extends State<RecipeNode> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      bottom: widget.bottom,
      width: widget.width,
      height: widget.height,
      child: GradientCard(
        child: Column(
          children: [Text(widget.title)],
        ),
      ),
    );
  }
}
