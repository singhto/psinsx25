import 'package:flutter/material.dart';

import 'package:psinsx/models/dmsx_model.dart';

class DetaliMoney extends StatefulWidget {
  final List<Dmsxmodel> dmsxModels;
  const DetaliMoney({
    Key key,
    @required this.dmsxModels,
  }) : super(key: key);

  @override
  State<DetaliMoney> createState() => _DetaliMoneyState();
}

class _DetaliMoneyState extends State<DetaliMoney> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
