import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashbord extends StatefulWidget {
  Dashbord({Key key}) : super(key: key);

  @override
  _DashbordState createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  String nameUser;

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('staffname');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 174, 5, 240),
                child: const Text("He'd have you all unravel at the"),
              ),
               Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 29, 200, 66),
                child: Column(
                  children: [
                    Icon(Icons.book, size: 100,),
                    Text('คู่มือ'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 195, 55, 78),
                child: Column(
                  children: [
                    Icon(Icons.notifications_active, size: 100,),
                    Text('งานแจ้งเตือน'),
                  ],
                ),
              ),
               Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 76, 64, 33),
                child: Column(
                  children: [
                    Icon(Icons.person, size: 100,),
                    Text('ข้อมูลส่วนตัว'),
                  ],
                ),
              ),
               Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 248, 193, 54),
                child: Column(
                  children: [
                    Icon(Icons.money_off, size: 100,),
                    Text('รายได้'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Color.fromARGB(255, 177, 47, 220),
                child: Column(
                  children: [
                    Icon(Icons.settings, size: 100,),
                    Text('Veision 1.41'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
