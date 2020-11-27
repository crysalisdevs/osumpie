import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

import '../../globals.dart';

part 'node_widget.g.dart';

// Circle widget used in the node block
class CircleButton extends StatefulWidget {
  final bool isConnected;
  final GestureTapCallback onTap;

  const CircleButton({Key key, this.isConnected, this.onTap}) : super(key: key);

  @override
  _CircleButtonState createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool isSelected = false;

  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => isSelected = !isSelected);
            widget.onTap();
          },
          child: Container(
            width: 15.0,
            height: 15.0,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.white,
              border: Border.all(color: Colors.blueGrey[200]),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    isSelected = widget.isConnected ?? false;
  }
}

// The line widget used to connect node blocks
class NodeConnectionLines extends CustomPainter {
  final List<double> p1, p2;

  NodeConnectionLines(this.p1, this.p2);

  @override
  void paint(Canvas canvas, Size size) {
    final _p1 = Offset(p1[0], p1[1]);
    final _p2 = Offset(p2[0], p2[1]);
    final _paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas.drawLine(_p1, _p2, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// The node block
@JsonSerializable(nullable: false)
// TODO: make node stateless
//ignore: must_be_immutable
class NodeBlock extends StatefulWidget {
  double top, left, height, width;
  String title, author, description, myUuid, leftUuid, rightUuid;
  Map<String, dynamic> properties;

  NodeBlock({
    @required this.top,
    @required this.left,
    @required this.title,
    @required this.author,
    @required this.width,
    @required this.height,
    @required this.leftUuid,
    @required this.description,
    @required this.myUuid,
    @required this.properties,
    @required this.rightUuid,
  });

  factory NodeBlock.fromJson(Map<String, dynamic> item) => _$NodeBlockFromJson(item);
  Map<String, dynamic> toJson() => _$NodeBlockToJson(this);

  @override
  _NodeBlockState createState() => _NodeBlockState();
}

class _NodeBlockState extends State<NodeBlock> {
  GlobalKey _key = GlobalKey();
  double _xOff, _yOff;

  bool isConnectedLeft = false;
  bool isConnectedRight = false;

  // Node Editor
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
              CircleButton(
                isConnected: isConnectedLeft,
                onTap: () => selectedForLines.add(widget),
              ),
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
              CircleButton(
                isConnected: isConnectedRight,
                onTap: () => selectedForLines.add(widget),
              ),
            ],
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) => Positioned(
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
          onDragEnd: (drag) => setState(() {
            widget.top = drag.offset.dy - _yOff;
            widget.left = drag.offset.dx - _xOff;
          }),
        ),
      );

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