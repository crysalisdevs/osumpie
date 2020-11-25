import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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

class CircleButton extends StatefulWidget {
  final GestureTapCallback onTap;
  final bool isConnected;

  const CircleButton({Key key, this.onTap, this.isConnected}) : super(key: key);

  @override
  _CircleButtonState createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: 15.0,
          height: 15.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueGrey[200]),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _RecipeNodeState extends State<RecipeNode> {
  GlobalKey _key = GlobalKey();
  double _xOff;
  double _yOff;

  Widget get buildNodeUi => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.blueGrey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onDoubleTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleButton(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '@${widget.author}',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 10.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              CircleButton(),
            ],
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
        feedback: Container(
          width: widget.width,
          height: widget.height,
          child: buildNodeUi,
        ),
        childWhenDragging: Container(),
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
