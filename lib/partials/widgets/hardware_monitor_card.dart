import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

class HardwareStatusCard extends StatefulWidget {
  HardwareStatusCard({Key key}) : super(key: key);

  @override
  _HardwareStatusCardState createState() => _HardwareStatusCardState();
}

class _HardwareStatusCardState extends State<HardwareStatusCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
     height: 200,
      child: GradientCard(
        gradient: Gradients.ali,
        shadowColor: Gradients.tameer.colors.last.withOpacity(0.25),
        elevation: 8,
        child: Text("Hi?"),
      ),
    );
  }
}
