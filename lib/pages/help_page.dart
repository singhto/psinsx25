import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:psinsx/models/manual_model.dart';
import 'package:psinsx/utility/my_style.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool loadStatus = true; //โหลด
  bool status = true; //มีข้อมูล
  List<ManualModel> manualModels = [];

  @override
  void initState() {
    super.initState();
    readHelpData();
  }

Future<void> launchYoutubeVideo(String _youtubeUrl) async {
if (_youtubeUrl != null && _youtubeUrl.isNotEmpty) {
  if (await canLaunch(_youtubeUrl)) {
    final bool _nativeAppLaunchSucceeded = await launch(
      _youtubeUrl,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
    if (!_nativeAppLaunchSucceeded) {
      await launch(_youtubeUrl, forceSafariVC: true);
    }
  }
 }
}

  Future<Null> readHelpData() async {
    String url = 'https://pea23.com/apipsinsx/getDataManual.php';
    await Dio().get(url).then((value) {
      setState(() {
        loadStatus = false;
      });

      if (value.toString() != 'null') {
        var result = json.decode(value.data);

        for (var map in result) {
          ManualModel manualModel = ManualModel.fromJson(map);
          setState(() {
            manualModels.add(manualModel);
          });
        }
      } else {
        setState(() {
          status = false;
        });
      }
    });
  }

  Widget showContent() {
    return status
        ? showListHelp()
        : Container(
            child: Center(
              child: Text(
                'ไม่มีข้อมูล',
                style: TextTheme().bodyText1,
              ),
            ),
          );
  }

  Widget showListHelp() => SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  'วีดีโอ : ${manualModels.length} รายการ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: manualModels.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, index) => GestureDetector(
                onTap: ()async => { await launch('${manualModels[index].mLink}')},
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading:
                          Image.network('${manualModels[index].mImageUrl}'),
                      title: Text(
                        manualModels[index].mTopic,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${manualModels[index].mDetail}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ช่วยเหลือ'),
      ),
      body:
          loadStatus ? Center(child: MyStyle().showProgress()) : showContent(),
    );
  }
}
