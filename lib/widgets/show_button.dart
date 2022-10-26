import 'package:flutter/material.dart';

class ShowButton extends StatelessWidget {
  final Function() pressFunc;
  final String label;
  const ShowButton({
    Key key,
    @required this.pressFunc,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: pressFunc,
      child: Text(label),
    );
  }
}
