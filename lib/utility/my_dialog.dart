import 'package:flutter/material.dart';
import 'package:psinsx/widgets/show_proogress.dart';

class MyDialog {
  final BuildContext context;
  MyDialog({
    @required this.context,
  });

  Future<void> processDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            child: ShowProgress(),
            onWillPop: () async {
              return false;
            }));
  }
}
