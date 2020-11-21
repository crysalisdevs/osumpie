import 'package:flutter/material.dart';

/// Display loading msg [loadingMsg] as widget
class OsumPieLoadingMsg extends StatelessWidget {
  final String loadingMsg;
  const OsumPieLoadingMsg({Key key, this.loadingMsg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: loadingMsg == null ? Text("Loading...") : Text(loadingMsg),
        )
      ],
    );
  }
}
