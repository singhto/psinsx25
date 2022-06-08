import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:psinsx/models/insx_model.dart';
import 'package:psinsx/models/insx_model2.dart';
import 'package:psinsx/models/insx_sqlite_model.dart';
import 'package:psinsx/pages/insx_edit2.dart';

import 'package:psinsx/utility/my_constant.dart';
import 'package:psinsx/utility/my_style.dart';
import 'package:psinsx/utility/normal_dialog.dart';
import 'package:psinsx/utility/sqlite_helper.dart';

class InsxPageOld extends StatefulWidget {
  InsxPageOld({Key key}) : super(key: key);

  @override
  _InsxPageOldState createState() => _InsxPageOldState();
}

class _InsxPageOldState extends State<InsxPageOld> {
  bool loadStatus = true; //โหลด
  bool status = true; //มีข้อมูล
  List<InsxModel> insxModels = List();
  List<InsxSQLiteModel> insxModel2s = [];
  List<InsxSQLiteModel> filterInsxModel2s = [];
  List<Color> colorIcons = List();
  List<File> files = List();
  String urlImage, search;
  final debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    readInsx();
  }

  void setToOrigin() {
    loadStatus = true;
    status = true;
    insxModels.clear();
    insxModel2s.clear();
    colorIcons.clear();
    files.clear();
  }

  Future<Null> readInsx() async {
    if (insxModel2s.length != 0) {
      setToOrigin();
    }

    await SQLiteHelper().readSQLite().then((value) {
      setState(() {
        loadStatus = false;
      });

      if (value.length != 0) {
        var result = value;

        for (var model in result) {
          if (model.invoice_status != MyConstant.valueInvoiceStatus) {
            InsxSQLiteModel insxModel2 = model;
            setState(() {
              insxModel2s.add(insxModel2);
              colorIcons.add(calculageHues(insxModel2.noti_date));
              files.add(null);
              filterInsxModel2s = insxModel2s;
            });
          }
        }
      } else {
        setState(() {
          status = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: insxModel2s.length == 0 ? Text('ไม่พบข้อมูล'): Text('ข้อมูล ${insxModel2s.length} รายการ'),
      ),
      body:
          loadStatus ? Center(child: MyStyle().showProgress()) : showContent(),
    );
  }

  Widget showContent() {
    return status
        ? showListInsx()
        : Container(
            child: Center(
              child: Text(
                'No Data',
                style: TextTheme().bodyText1,
              ),
            ),
          );
  }

  Color calculageHues(String notidate) {
    List<Color> colors = [Colors.green, Colors.yellow, Colors.blue, Colors.red];
    List<String> strings = notidate.split(" ");
    List<String> dateTimeInts = strings[0].split('-');
    DateTime notiDateTime = DateTime(
      int.parse(dateTimeInts[0]),
      int.parse(dateTimeInts[1]),
      int.parse(dateTimeInts[2]),
    );

    DateTime currentDateTime = DateTime.now();
    int diferDate = currentDateTime.difference(notiDateTime).inDays;
    Color result = colors[0];

    if (diferDate >= 7) {
      result = colors[3];
    } else if (diferDate >= 4) {
      result = colors[2];
    } else if (diferDate >= 2) {
      result = colors[1];
    }
    return result;
  }

  Future<Null> confirmDialog(
      InsxModel2 insxModel2, Color color, int index) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: ListTile(
          leading: Icon(
            Icons.pin_drop,
            size: 36,
            color: color,
          ),
          title: Text(insxModel2.cus_name),
          subtitle: Text(insxModel2.pea_no),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('กรุณาเลือก Camera'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    chooseCamera(index);
                    Navigator.pop(context);
                  }),
              IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget showListInsx() => SingleChildScrollView(
        child: Column(
          children: [
            searchText(),
            Card(
              child: ListTile(
                title: Text(insxModel2s.length == 0
                    ? 'ข้อมูล : ? รายการ'
                    : 'ข้อมูล : ${insxModel2s.length} รายการ'),
              ),
            ),
            ListView.builder(
              itemCount: filterInsxModel2s.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, int index) => GestureDetector(
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => InsxEdit2(
                      insxModel2: filterInsxModel2s[index],
                    ),
                  );
                  Navigator.push(context, route).then(
                    (value) => readInsx(),
                  );
                },

                //=> confirmDialog(insxModel2s[index], colorIcons[index], index),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.pin_drop,
                        size: 26,
                        color: colorIcons[index],
                      ),
                      title: Text(
                        filterInsxModel2s[index].cus_name,
                        style: TextStyle(
                          fontSize: 12,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'วันแจ้งดำเนินการ: ${filterInsxModel2s[index].noti_date} \nสาย : ${filterInsxModel2s[index].write_id}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget searchText() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            child: TextField(
              decoration: InputDecoration(hintText: 'กรอกชื่อที่ค้นหา'),
              onChanged: (value) {
                debouncer.run(() {
                  setState(() {
                    filterInsxModel2s = insxModel2s
                        .where((u) => u.cus_name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                });
              },
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.search,
                size: 36,
              ),
              onPressed: () {}),
        ],
      ),
    );
  }

  Future<Null> chooseCamera(int index) async {
    try {
      var object = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        files[index] = File(object.path);
        uploadImage(files[index], index);
      });
    } catch (e) {}
  }

  Future<Null> uploadImage(File file, int index) async {
    String apiSaveFile = '${MyConstant().domain}/apipsinsx/saveFile.php';

    //TimeOfDay timeOfDay = TimeOfDay.now();
    String fileName =
        'insx${Random().nextInt(1000000)}${insxModel2s[index].ca}.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: fileName);
      FormData data = FormData.fromMap(map);
      await Dio().post(apiSaveFile, data: data).then((value) {
        //print('====>>> $value');
        //print('Success url Image ==>> https://pea23.com/apipsinsx/upload/$fileName');
        urlImage = '${MyConstant().domain}/apipsinsx/upload/$fileName';
        print('=== usrlImage == $urlImage');

        //editDataInsx(insxModel2s[index]);
      });
    } catch (e) {}
  }

  Future<Null> editDataInsx(InsxModel2 insxModel2) async {
    print('id insx == ${insxModel2.id}');

    String url =
        '${MyConstant().domain}/apipsinsx/editDataWhereId.php?isAdd=true&id=${insxModel2.id}&invoice_status=ดำเนินการเสร็จสมบูรณ์&work_image=$urlImage';

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        readInsx();
        print('readInsx==>>> $value');
      } else {
        normalDialog(context, 'ผิดพลาด กรุณาลองใหม่');
      }
    });
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
