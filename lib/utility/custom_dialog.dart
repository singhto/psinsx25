import 'package:flutter/material.dart';

class CustomDialog {
  Future<Null> loadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        child: Center(child: CircularProgressIndicator()),
        onWillPop: () async => false,
      ),
    );
  }

}
