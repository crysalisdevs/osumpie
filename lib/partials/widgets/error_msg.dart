import 'package:flutter/material.dart';

/// Display error msg [error] as widget
class OsumPieErrorMsg extends StatelessWidget {
  final Object error;

  const OsumPieErrorMsg({Key key, @required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 35.0),
            const Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text(
                "Error occured!",
                style: TextStyle(fontSize: 35.0),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
