import 'package:flutter/material.dart';
import 'package:psinsx/utility/my_constant.dart';
import 'package:psinsx/widgets/show_text.dart';

class WaitWork extends StatefulWidget {
  const WaitWork({Key key}) : super(key: key);

  @override
  _WaitWorkState createState() => _WaitWorkState();
}

class _WaitWorkState extends State<WaitWork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wait Work'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShowText(
                text: 'คุณลงชื่ออกจากงานแล้ว นิ',
                textStyle: MyConstant().h2Style(),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/homePage', (route) => false),
                child: Text('ขออนุญาติเข้าแอพอีกครั้ง'),
              ),
            ],
          ),
        ));
  }
}
