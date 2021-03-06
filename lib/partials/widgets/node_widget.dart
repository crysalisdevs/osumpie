import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:json_annotation/json_annotation.dart';

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
      ..color = Colors.grey
      ..strokeWidth = 4;
    canvas.drawLine(_p1, _p2, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// The node block
// TODO: make node stateless

@JsonSerializable(nullable: false)
//ignore: must_be_immutable
class NodeBlock extends StatefulWidget {
  double top, left, height, width;
  String title, author, description, myUuid, rightUuid;
  Map<String, dynamic> properties;

  @JsonKey(ignore: true)
  void Function() renderLinesCallback, saveReceipeFileCallback;

  @JsonKey(ignore: true)
  List<NodeBlock> nodeBlocks;

  @JsonKey(ignore: true)
  bool lockEditorPan;

  @JsonKey(ignore: true)
  StateSetter setStateRoot;

  NodeBlock({
    @required this.top,
    @required this.left,
    @required this.title,
    @required this.author,
    @required this.width,
    @required this.height,
    @required this.description,
    @required this.myUuid,
    @required this.properties,
    @required this.rightUuid,
    @required this.nodeBlocks,
    @required this.renderLinesCallback,
    @required this.saveReceipeFileCallback,
    @required this.lockEditorPan,
    @required this.setStateRoot,
  });

  factory NodeBlock.fromJson(Map<String, dynamic> item, void Function() renderLinesCallback, List<NodeBlock> nodeBlocks,
      void Function() saveReceipeFileCallback, bool lockEditorPan, StateSetter setStateRoot) {
    NodeBlock generated = _$NodeBlockFromJson(item);
    generated.renderLinesCallback = renderLinesCallback;
    generated.nodeBlocks = nodeBlocks;
    generated.saveReceipeFileCallback = saveReceipeFileCallback;
    generated.lockEditorPan = lockEditorPan;
    generated.setStateRoot = setStateRoot;
    return generated;
  }
  Map<String, dynamic> toJson() => _$NodeBlockToJson(this);

  @override
  _NodeBlockState createState() => _NodeBlockState();
}

class _NodeBlockState extends State<NodeBlock> {
  bool isConnectedLeft = false, isConnectedRight = false;

  // Node Editor
  Widget get buildNodeUi => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.blueGrey[50],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleButton(
            isConnected: isConnectedLeft,
            onTap: () {
              widget.nodeBlocks.add(widget);
              widget.renderLinesCallback();
            },
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
            onTap: () {
              widget.nodeBlocks.add(widget);
              widget.renderLinesCallback();
            },
          ),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      width: widget.width,
      height: widget.height,
      child: MouseRegion(
        cursor: widget.lockEditorPan ? SystemMouseCursors.click : SystemMouseCursors.grabbing,
        child: GestureDetector(
          // onVerticalDragUpdate: (details) => setState(() => widget.top += details.delta.dy),
          // onHorizontalDragUpdate: (details) => setState(() => widget.left += details.delta.dx),
          // onHorizontalDragEnd: (details) => widget.renderLinesCallback(),
          // onVerticalDragEnd: (details) => widget.renderLinesCallback(),
          onTapDown: (_) => widget.setStateRoot(() => widget.lockEditorPan = true),
          onPanUpdate: (details) => setState(() {
            widget.left += details.delta.dx;
            widget.top += details.delta.dy;
          }),
          onPanEnd: (details) {
            widget.renderLinesCallback();
            widget.setStateRoot(() => widget.lockEditorPan = false);
          },
          child: buildNodeUi,
        ),
      ),
    );
  }
}
