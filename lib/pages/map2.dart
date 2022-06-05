import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:psinsx/models/insx_model2.dart';
import 'package:psinsx/pages/insx_edit.dart';
import 'package:psinsx/pages/insx_page.dart';
import 'package:psinsx/utility/custom_dialog.dart';
import 'package:psinsx/utility/my_style.dart';
import 'package:psinsx/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMap2 extends StatefulWidget {
  @override
  _MyMap2State createState() => _MyMap2State();
}

class _MyMap2State extends State<MyMap2> {
  double lat, lng;
  LatLng startMapLatLng;
  List<InsxModel2> insxModel2s = [];
  List<InsxModel2> insxModelForEdits = [];

  bool statusProcessEdit = false;

  @override
  void initState() {
    super.initState();
    findLatLng();
  }

  Future<Null> myReadAPI() async {
    insxModel2s.clear();
    insxModelForEdits.clear();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String workername = preferences.getString('staffname');

    String url =
        'https://www.pea23.com/apipsinsx/getInsxWhereUser.php?isAdd=true&worker_name=$workername';

    await Dio().get(url).then((value) async {
      if (value.toString() != 'null') {
        for (var item in json.decode(value.data)) {
          InsxModel2 model2 = InsxModel2.fromMap(item);
          insxModel2s.add(model2);
        }
        myAllMarker();
        setState(() {});
      }
    });
  }

  Set<Marker> myAllMarker() {
    List<Marker> markers = [];
    List<double> hues = [80.0, 60.0, 150.0, 20.0];

    Marker userMarker = Marker(
        markerId: MarkerId('idUser'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'คุณอยู่ที่นี่'),
        icon: BitmapDescriptor.defaultMarkerWithHue(300));

    for (var item in insxModel2s) {
      Marker marker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(
            calculageHues(item.noti_date)),
        markerId: MarkerId('id${item.id}'),
        position: LatLng(double.parse(item.lat), double.parse(item.lng)),
        infoWindow: InfoWindow(
          title: item.cus_name,
          snippet: '${item.write_id} PEA:${item.pea_no}',
          onTap: () {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => InsxEdit(
                insxModel2: item,
                fromMap: true,
              ),
            );
            Navigator.push(context, route).then(
              (value) {
                print('##4june Back Form insx');
                myReadAPI();
              },
            );
          },
        ),
      );
      markers.add(marker);
    }
    return markers.toSet();
  }

  double calculageHues(String notidate) {
    List<double> hues = [80.0, 60.0, 200.0, 20.0];
    List<String> strings = notidate.split(" ");
    List<String> dateTimeInts = strings[0].split('-');
    DateTime notiDateTime = DateTime(
      int.parse(dateTimeInts[0]),
      int.parse(dateTimeInts[1]),
      int.parse(dateTimeInts[2]),
    );

    DateTime currentDateTime = DateTime.now();
    int diferDate = currentDateTime.difference(notiDateTime).inDays;
    double result = hues[0];

    if (diferDate >= 7) {
      result = hues[3];
    } else if (diferDate >= 3) {
      result = hues[2];
    } else if (diferDate >= 1) {
      result = hues[1];
    }
    return result;
  }

  Future<Null> findLatLng() async {
    bool enableServiceLocation = await Geolocator.isLocationServiceEnabled();

    if (enableServiceLocation) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          lat = 16.753188;
          lng = 101.203616;
          startMapLatLng = LatLng(16.753188, 101.203616);
          myReadAPI();
        });
      } else if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission().then((value) async {
          if (value == LocationPermission.deniedForever) {
            setState(() {
              lat = 16.753188;
              lng = 101.203616;
              startMapLatLng = LatLng(16.753188, 101.203616);
              myReadAPI();
            });
          } else {
            // find Lat, lng
            var position = await findPosition();
            setState(() {
              lat = position.latitude;
              lng = position.longitude;
              startMapLatLng = LatLng(lat, lng);
              myReadAPI();
            });
          }
        });
      } else {
        // find Lat, lng
        var position = await findPosition();
        setState(() {
          lat = position.latitude;
          lng = position.longitude;
          startMapLatLng = LatLng(lat, lng);
          myReadAPI();
        });
      }
    } else {
      normalDialog(context, 'โปรดให้สิทธิแผนที่ก่อน');
      setState(() {
        lat = 16.753188;
        lng = 101.203616;
        startMapLatLng = LatLng(16.753188, 101.203616);
        myReadAPI();
      });
    }
  }

  Future<Position> findPosition() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lat == null ? MyStyle().showProgress() : buildGoogleMap(),
    );
  }

  int timeEdit = 0;

  Future<Null> editDataInsx2(InsxModel2 insxModel2) async {
    String url =
        'https://www.pea23.com/apipsinsx/editDataWhereInvoiceNo.php?isAdd=true&invoice_no=${insxModel2.invoice_no}';

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
      } else {
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด กรุณาลองใหม่');
      }
    });
  }

  Widget pinGreen() {
    return GestureDetector(
      onTap: () {
        return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsxPage(
                insxModel2s: insxModel2s,
              ),
            )).then((value) {
          InsxModel2 insxModel2 = value;
          print('##4june การกลับจาก insxPage ${insxModel2.cus_name} ');
        });
      },
      child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.list_alt_rounded,
                size: 30,
                color: Colors.grey[800],
              ),
              Text(
                '${insxModel2s.length}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          color: Colors.red[100]),
    );
  }

  Widget buildGoogleMap() {
    return Scaffold(
      body: Stack(
        children: [
          buildMainMap(),
          Positioned(
            top: 8,
            left: 10,
            child: pinGreen(),
          ),

          statusProcessEdit ? showProcessEdit() : SizedBox(),
        ],
      ),
      bottomNavigationBar: new BottomAppBar(
        color: Colors.white,
        child: new Row(),
      ),
    );
  }

  Widget showProcessEdit() => Center(
        child: Card(
          color: Colors.black,
          child: Container(
            width: 200,
            height: 150,
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(
                  'กำลังอัพโหลด เหลือ $timeEdit รายการ',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );

  GoogleMap buildMainMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: startMapLatLng,
        zoom: 8,
      ),
      onMapCreated: (controller) {},
      markers: myAllMarker(),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
    );
  }
}
