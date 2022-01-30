import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import 'package:flutter/material.dart';
import 'package:psinsx/models/insx_model2.dart';
import 'package:psinsx/models/user_model.dart';
import 'package:psinsx/pages/add_information_user.dart';

import 'package:psinsx/pages/help_page.dart';
import 'package:psinsx/pages/information_user.dart';
import 'package:psinsx/pages/map.dart';
import 'package:psinsx/pages/map_dmsx.dart';
import 'package:psinsx/pages/oil_page.dart';
import 'package:psinsx/pages/pea_report.dart';
import 'package:psinsx/pages/perpay.dart';
import 'package:psinsx/pages/search_page.dart';
import 'package:psinsx/pages/signin_page.dart';
import 'package:psinsx/utility/sqlite_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  //HomePage({Key key}) : super(key: key);
  bool statusINSx; // false => Non Back frome edit INSx
  HomePage({Key key, this.statusINSx}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nameUser, userEmail, userImge, userId;
  bool status;

  Widget currentWidget = MyMap();
  int selectedIndex = 0;
  List<InsxModel2> insxModel2s = [];

  List pages = [MyMap(), Mapdmsx(), SearchPage(), PeaReport()];

  UserModel userModel;

  @override
  void initState() {
    super.initState();
    readUserInfo();
  }

  Future<Null> readUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      nameUser = preferences.getString('staffname');
      userEmail = preferences.getString('user_email');
      userImge = preferences.getString('user_img');
      userId = preferences.getString('id');
    });
  }

  Widget showDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bird.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      currentAccountPicture: GestureDetector(
        onTap: () {
          MaterialPageRoute materialPageRoute = MaterialPageRoute(
            builder: (context) => AddInformationUser(),
          );
          Navigator.push(context, materialPageRoute)
              .then((value) => readUserInfo());
        },
        child: CircularProfileAvatar(
          '$userImge',
          borderWidth: 4.0,
        ),
      ),
      accountName: Text('$nameUser'),
      accountEmail: Text('$userEmail'),
    );
  }

  Future<Null> signOutProcess() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    //exit(0);
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => SignIn());
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Future<Null> launchURL() async {
    final url = 'https://www.pea23.com';
    await launch(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Unable to open URL $url');
      // throw 'Could not launch $url';
    }
  }

  Future<Null> deleteAllData() async {
    await SQLiteHelper().deleteAllData().then((value) => signOutProcess());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            showDrawerHeader(),
            ListTile(
                leading: Icon(Icons.person_pin),
                title: Text('ข้อมูลส่วนตัว'),
                subtitle: Text(
                  'ข้อมูลส่วนตัวของพนักงาน',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationUser()));
                }),
            ListTile(
                leading: Icon(Icons.download_rounded),
                title: Text('ดึงข้อมูล'),
                subtitle: Text(
                  'เปิดเว็ปไซต์บริษัท,แหล่งข้อมูล',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  print('object');
                  Navigator.pop(context);
                  launchURL();
                }),
            ListTile(
                leading: Icon(Icons.money),
                title: Text('เบิกล่วงหน้า'),
                subtitle: Text(
                  'ระบบเบิกล่วงหน้า',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => PerPay()));
                }),
            ListTile(
                leading: Icon(Icons.money),
                title: Text('เบิกน้ำมัน'),
                subtitle: Text(
                  'ระบบเบิกค่าน้ำมัน',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => OilPage()));
                }),
            ListTile(
                leading: Icon(Icons.help),
                title: Text('ช่วยเหลือ'),
                subtitle: Text(
                  'ช่วยเหลือ คู่มือต่าง',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpPage()));
                }),
            ListTile(
                leading: Icon(Icons.work_off),
                title: Text('เลิกงาน'),
                subtitle: Text(
                  'ลงเวลาเลิกงาน',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/outTime');
                
                }),
            // ListTile(
            //     leading: Icon(Icons.add_comment),
            //     title: Text('งดจ่ายไฟ'),
            //     subtitle: Text(
            //       'งานงดจ่ายไฟในระบบ Dmsx',
            //       style: TextStyle(fontSize: 10),
            //     ),
            //     trailing: Icon(Icons.arrow_right),
            //     onTap: () {
            //       Navigator.pop(context);
            //       Navigator.of(context).push(
            //           MaterialPageRoute(builder: (context) => DmsxPage()));
            //     }),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('ออกจากระบบ'),
              subtitle: Text(
                'ออกจากระบบ',
                style: TextStyle(fontSize: 10),
              ),
              onTap: () {
                //signOutProcess();
                //deleteAllData();
                confirmDialog();
              },
            ),
            Divider(),
            ListTile(
              title: Text('Version 1.38'),
              subtitle: Text(
                'อัพเดทเมื่อ 13 มกราคม 2565',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Center(
          child: Text(
            'สวัสดี $nameUser',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.red[100],
              ),
              onPressed: () {})
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff6a1b9a),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xffce93d8),
          showUnselectedLabels: true,
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Insx',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Dmsx',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'ประวัติ&พิกัด',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image),
              label: 'เช็คภาพ',
            ),
          ]),
    );
  }

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Column(
          children: [
            Text(
              'ยืนยันออกจากระบบ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
              ),
            ),
            Text(
              'เมื่อกดยื่นยันข้อมูลจะถูกลบออกจากเครื่อง',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.normal,
              ),
            ),
          ],
        ),
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ปิด',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      deleteAllData();
                      signOutProcess();
                    },
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
