import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import 'package:flutter/material.dart';
import 'package:psinsx/models/insx_model2.dart';
import 'package:psinsx/models/user_model.dart';
import 'package:psinsx/pages/add_information_user.dart';
import 'package:psinsx/pages/dashbord.dart';

import 'package:psinsx/pages/help_page.dart';
import 'package:psinsx/pages/information_user.dart';
import 'package:psinsx/pages/map.dart';
import 'package:psinsx/pages/map2.dart';
import 'package:psinsx/pages/map_dmsx.dart';
import 'package:psinsx/pages/search_page.dart';
import 'package:psinsx/pages/signin_page.dart';
import 'package:psinsx/utility/my_constant.dart';
import 'package:psinsx/utility/sqlite_helper.dart';
import 'package:psinsx/widgets/show_text.dart';

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

  List pages = [
    MyMap2(),
    Mapdmsx(),
    SearchPage(),
    Dashbord(),
  ];

  UserModel userModel;

  bool online = true;

  @override
  void initState() {
    super.initState();
    cratePages();
    readUserInfo();
  }

  void cratePages() {
    if (pages.isNotEmpty) {
      pages.clear();
    }
    pages.add(online ? MyMap2() : MyMap());
    pages.add(Mapdmsx());
    pages.add(SearchPage());
    pages.add(Dashbord());
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
          moveToEditProfile();
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

  void moveToEditProfile() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => AddInformationUser(),
    );
    Navigator.push(context, materialPageRoute).then((value) => readUserInfo());
  }

  Future<Null> signOutProcess() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    //exit(0);
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => SignIn());
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Future<Null> launchURL() async {
    final url = 'https://www.pea23.com/index.php';
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
                title: Text('???????????????????????????????????????'),
                subtitle: Text(
                  '?????????????????????????????????????????????????????????????????????',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationUser()));
                }),
            ListTile(
                leading: Icon(Icons.help),
                title: Text('???????????????????????????'),
                subtitle: Text(
                  '??????????????????????????? ??????????????????????????????',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpPage()));
                }),
            ListTile(
                leading: Icon(Icons.download_rounded),
                title: Text('???????????????????????????'),
                subtitle: Text(
                  '??????????????????????????????????????????????????????,?????????????????????????????????',
                  style: TextStyle(fontSize: 10),
                ),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                  launchURL();
                }),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('??????????????????????????????'),
              subtitle: Text(
                '??????????????????????????????',
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
              title: Text('Version 1.43'),
              subtitle: Text(
                '????????????????????????????????? 6 ????????????????????? 2565',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Center(
          child: Row(
            children: [
              Text(
                '$nameUser',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                online ? ' ?????????????????????' : ' ?????????????????????',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: online ? Colors.green : Colors.red
                ),
              ),
            ],
          ),
        ),
        actions: [
          Switch(
              value: online,
              onChanged: (velue) {
                setState(() {
                  online = velue;
                  cratePages();
                });
              }),
          InkWell(
            onTap: () {
              moveToEditProfile();
            },
            child: CircularProfileAvatar(
              '$userImge',
              borderWidth: 2,
              radius: 28,
              elevation: 5.0,
              cacheImage: true,
              foregroundColor: Colors.brown.withOpacity(0.5),
              imageFit: BoxFit.cover,
            ),
          )
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
              icon: Icon(Icons.notifications_active),
              label: '???????????????????????????',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: '????????????????????????',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '?????????????????????',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '????????????????????????',
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
              '????????????????????????????????????????????????',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
              ),
            ),
            Text(
              '????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????',
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
                      '?????????',
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
                      '??????????????????',
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
