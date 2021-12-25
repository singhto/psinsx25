import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:psinsx/models/dmsx_model.dart';
import 'package:psinsx/pages/dmsx_list_page.dart';
import 'package:psinsx/utility/my_constant.dart';
import 'package:psinsx/utility/my_utility.dart';
import 'package:psinsx/widgets/show_proogress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class Mapdmsx extends StatefulWidget {
  @override
  _MapdmsxState createState() => _MapdmsxState();
}

class _MapdmsxState extends State<Mapdmsx> {
  Completer<GoogleMap> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.813808171680567, 100.96669116372476),
    zoom: 6,
  );

  bool load = true;
  Map<MarkerId, Marker> markers = {};
  LatLng startMapLatLng;

  String statusText;
  List<String> titleStatuss = [];

  bool checkAmountImagebol = true; //true show เลือกรูป

  List<Dmsxmodel> dmsxModels = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataApi();
  }

  void procressAddMarker(Dmsxmodel dmsxmodel) {
    double hueDouble;

    switch (dmsxmodel.statusTxt) {
      case 'งดจ่ายไม่ได้':
        hueDouble = 0;
        break;
      case 'สั่งระงับการปฏิบัติงาน':
        hueDouble = 250;
        break;
      case 'สั่งระงับ (ชำระเงินระหว่างขอผ่อนผัน':
        hueDouble = 250;
        break;
      case 'รับทราบคำสั่งระงับ':
        hueDouble = 250;
        break;
      case 'ขอผ่อนผันครั้งที่ 1':
        hueDouble = 0;
        break;
      case 'ขอผ่อนผันครั้งที่ 2':
        hueDouble = 0;
        break;
      case 'ปลดสายแล้ว':
        hueDouble = 0;
        break;
      case 'ถอดมิเตอร์แล้ว':
        hueDouble = 0;
        break;
      case 'ให้ต่อสาย':
        hueDouble = 300;
        break;
      case 'ให้ต่อมิเตอร์':
        hueDouble = 300;
        break;
      case 'ต่อสายแล้ว':
        hueDouble = 60;
        break;
      case 'ต่อมิเตอร์แล้ว':
        hueDouble = 60;
        break;

      default:
        hueDouble = 120;
        break;
    }

    print('## hueDouble == $hueDouble');

    MarkerId markerId = MarkerId(dmsxmodel.id);
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(hueDouble),
      infoWindow: InfoWindow(
        onTap: () {
          processAddImage(dmsxmodel);
          if (dmsxmodel.images.isNotEmpty) {
            checkAmountImage(dmsxmodel.images);
          }
        },
        title: '${dmsxmodel.employeeId}',
        snippet: 'PEA : ${dmsxmodel.peaNo}',
      ),
      markerId: markerId,
      position: LatLng(
        double.parse(dmsxmodel.lat.trim()),
        double.parse(
          dmsxmodel.lng.trim(),
        ),
      ),
    );
    markers[markerId] = marker;
  }

  Future<void> readDataApi() async {
    print('#### readDataApi Work');

    if (markers.isNotEmpty) {
      markers.clear();
    }

    await MyUtility().findUserId().then(
      (value) async {
        if (dmsxModels.isNotEmpty) {
          dmsxModels.clear();
        }
        String path =
            'https://pea23.com/apipsinsx/getDmsxWherUser.php?isAdd=true&user_id=$value';

        await Dio().get(path).then(
          (value) {
            for (var item in json.decode(value.data)) {
              Dmsxmodel dmsxmodel = Dmsxmodel.fromMap(item);
              dmsxModels.add(dmsxmodel);
              print('#id == ${dmsxmodel.id}');

              setState(
                () {
                  procressAddMarker(dmsxmodel);
                  load = false;
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? Container(
              child: Center(
                child: Text(
                  'ไม่มีข้อมูล',
                  style: TextTheme().bodyText1,
                ),
              ),
            )
          : Stack(
              children: [
                buildMap(),
                buildControl(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: () {
            print('object');
            launchURL();
          },
          child: Icon(Icons.download)),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //backgroundColor: Colors.purple,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
      ),
    );
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

  Widget buildControl() => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DmsxListPage(dmsxModels: dmsxModels),
            ),
          ).then((value) => readDataApi()),
          child: Container(
            width: 60,
            height: 70,
            child: Card(
              color: Colors.purple.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list_alt),
                      Text(
                        markers.length.toString(),
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  GoogleMap buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete();
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: Set<Marker>.of(markers.values),
    );
  }

  Future<void> processAddImage(Dmsxmodel dmsxmodel) async {
    print('# image ${dmsxmodel.images}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ชื่อ-สกุล: ${dmsxmodel.cusName}',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
              Text(
                'สถานะล่าสุด: ${dmsxmodel.statusTxt}',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              Text(
                'สาย: ${dmsxmodel.line}',
                style: TextStyle(fontSize: 10),
              ),
              Text(
                'ca: ${dmsxmodel.ca}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'PEA : ${dmsxmodel.peaNo}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'ที่อยู่ : ${dmsxmodel.address}',
                style: TextStyle(fontSize: 12),
              ),
              dmsxmodel.images.isEmpty ? SizedBox() : showListImages(dmsxmodel),
            ],
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     // Navigator.pop(context);
          //     // processTakePhoto(
          //     //     dmsxmodel: dmsxmodel, source: ImageSource.camera);
          //      Fluttertoast.showToast(msg: 'กรุณาแนบไฟล์');
          //   },
          //   child: Text('ถ่ายรูป'),
          // ),
          checkAmountImagebol
              ? TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    processTakePhoto(
                        dmsxmodel: dmsxmodel, source: ImageSource.gallery);
                  },
                  child: Text('เลือกรูป'),
                )
              : SizedBox(),
          TextButton(
            onPressed: () {
              checkAmountImagebol = true;
              Navigator.pop(context);
            },
            child: Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget createListStatus(StateSetter mySetState) {
    List<Widget> widgets = [];

    for (var item in titleStatuss) {
      widgets.add(RadioListTile(
        title: Text(
          item,
          style: TextStyle(fontSize: 14),
        ),
        value: item,
        groupValue: statusText,
        onChanged: (value) {
          mySetState(() {
            statusText = value;
            print('statusText = $statusText');
          });
          setState(() {
            showUpload = true;
          });
        },
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  bool showUpload = false; // false Non Show Button Upload

  Future<void> processTakePhoto(
      {Dmsxmodel dmsxmodel, ImageSource source}) async {
    try {
      var re = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
      );

      File file = File(re.files.single.path);
      print('dmsx filePath = ${file.path}');

      switch (dmsxmodel.statusTxt.trim()) {
        case 'เริ่มงดจ่ายไฟ':
          titleStatuss = MyConstant.statusTextsNonJay;
          break;
        case 'ขอผ่อนผันครั้งที่ 1':
          titleStatuss = MyConstant.statusTextsWMST1;
          break;
        case 'ขอผ่อนผันครั้งที่ 2':
          titleStatuss = MyConstant.statusTextsWMST2;
          break;
        case 'ปลดสายแล้ว':
          titleStatuss = MyConstant.statusTextsFURM;
          break;
        case 'ถอดมิเตอร์แล้ว':
          titleStatuss = MyConstant.statusTextsWMMR;
          break;
        case 'ให้ต่อสาย':
          titleStatuss = MyConstant.statusTextsFUCM;
          break;
        case 'ให้ต่อมิเตอร์':
          titleStatuss = MyConstant.statusTextsWMSTT;
          break;

        case 'คำสั่งให้ถอดมิเตอร์':
          titleStatuss = MyConstant.statusTextsTodd;
          break;

        default:
          titleStatuss = MyConstant.statusTextsJay;
          break;
      }

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ชื่อ-สกุล: ${dmsxmodel.cusName}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'PEA: ${dmsxmodel.peaNo}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'สถานะล่าสุด: ${dmsxmodel.statusTxt}',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(file),
                  createListStatus(setState),
                ],
              ),
            ),
            actions: [
              showUpload ? buttonUpImage(context, file, dmsxmodel) : SizedBox(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
            ],
          );
        }),
      );
    } catch (e) {}
  }

  Widget buttonUpImage(BuildContext context, File file, Dmsxmodel dmsxmodel) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
        String nameWithoutExtension = path.basenameWithoutExtension(file.path);
        var name = nameWithoutExtension.split("_");
        var code = name[0].substring(4, name[0].length);
        print('dmsx name[0] = ${name[0]}');
        print('dmsx code = $code');

        if (code != dmsxmodel.ca && code != dmsxmodel.peaNo) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('รูปภาพไม่ถูกต้อง'),
              content: const Text('กรุณาตรวจสอบไฟล์ภาพอีกครั้ง'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'ปิด'),
                  child: const Text('ปิด'),
                ),
              ],
            ),
          );
        } else {
          String nameFile = path.basename(file.path);
          print('dmsx nameFile = $nameFile');

          String pathUpload =
              'https://pea23.com/apipsinsx/saveImageCustomer.php';

          Map<String, dynamic> map = {};
          map['file'] =
              await MultipartFile.fromFile(file.path, filename: nameFile);
          FormData data = FormData.fromMap(map);
          await Dio().post(pathUpload, data: data).then((value) async {
            print('# === value for upload ==>> $value');
            List<String> images = [];

            if (dmsxmodel.images.isEmpty) {
              images.add(nameFile);
            } else {
              String string = dmsxmodel.images;
              string = string.substring(1, string.length - 1);
              images = string.split(',');
              int index = 0;
              for (var item in images) {
                images[index] = item.trim();
                index++;
              }
              images.add(nameFile);
            }

            String readNumber = 'ดำเนินการแล้ว';

            if (dmsxmodel.readNumber.isEmpty) {
              readNumber = 'ดำเนินการแล้ว';
            } else {
              readNumber = 'ต่อกลับแล้ว';
            }

            String apiEditImages =
                'https://pea23.com/apipsinsx/editDmsxWhereId.php?isAdd=true&id=${dmsxmodel.id}&images=${images.toString()}&status_txt=$statusText&readNumber=$readNumber';

            await Dio().get(apiEditImages).then((value) {
              print('value update == $value');
              readDataApi();
            });
          });
        }
      },
      child: Text('อัพโหลด'),
    );
  }

  Widget showListImages(Dmsxmodel dmsxmodel) {
    print('##### image ==> ${dmsxmodel.images}');
    List<Widget> widgets = [];

    String string = dmsxmodel.images;
    string = string.substring(1, string.length - 1);
    List<String> strings = string.split(',');
    print('### strings ==> $strings');

    for (var item in strings) {
      widgets.add(
        Container(
          height: 180,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: CachedNetworkImage(
                imageUrl: '${MyConstant.domainImage}${item.trim()}',
                //fit: BoxFit.cover,
                placeholder: (context, url) => ShowProgress(),
                errorWidget: (context, url, error) => SizedBox(),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: widgets,
    );
  }

  void checkAmountImage(String images) {
    String string = images;
    string = string.substring(1, string.length - 1);
    List<String> strings = string.split(',');
    if (strings.length >= 2) {
      setState(() {
        checkAmountImagebol = false;
      });
    }
    print('### checkAmountImagebol ล่าสุด ==> $checkAmountImagebol');
  }
}
