import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:osumpie/partials/widgets/error_msg.dart';
import 'package:osumpie/partials/widgets/loading_msg.dart';

import '../partials/widgets/node.dart';

class RecipeEditor extends StatefulWidget {
  RecipeEditor({Key key}) : super(key: key);

  @override
  _RecipeEditorState createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor> {
  Future<List<RecipeNode>> initAsync() async {
    File nodesFile = File('test.json');
    List<RecipeNode> nodes;

    if (await nodesFile.exists()) {
      String fileContents = await nodesFile.readAsString();
      Map<String, dynamic> nodeJson = jsonDecode(fileContents);
      nodeJson.forEach((key, value) => nodes.add(RecipeNode.fromJson(value)));
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecipeNode>>(
      future: initAsync(),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null)
          return OsumPieErrorMsg(
            error: snapshot.error ?? 'No recipe? Add recipe block!',
          );
        else if (snapshot.hasData)
          return Stack(
            children: snapshot.data,
          );
        return const OsumPieLoadingMsg(
          loadingMsg: 'Loading receipe...',
        );
      },
    );
  }
}
