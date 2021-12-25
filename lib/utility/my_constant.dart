import 'package:flutter/material.dart';

class MyConstant {
  String domain = 'https://pea23.com';

  static String valueInvoiceStatus = 'ดำเนินการเสร็จสมบูรณ์';

  static String domainImage = 'https://pea23.com/apipsinsx/dmsxupload/';

//เริ่มงดจ่ายไฟ
  static List<String> statusTextsNonJay = [
    'ขอผ่อนผันครั้งที่ 1',
    'ปลดสายแล้ว',
    'ถอดมิเตอร์แล้ว',
  ];
//ขอผ่อนผันครั้งท่ี่ 1
  static List<String> statusTextsWMST1 = [
    'ขอผ่อนผันครั้งที่ 2',
    'ปลดสายแล้ว',
    'ถอดมิเตอร์แล้ว',
  ];
  //ขอผ่อนผันครั้งท่ี่ 1
  static List<String> statusTextsJay = [
    'ขอผ่อนผันครั้งที่ 2',
    'ปลดสายแล้ว',
    'ถอดมิเตอร์แล้ว',
  ];

  //ขอผ่อนผันครั้งที่ 2
  static List<String> statusTextsWMST2 = [
    'ปลดสายแล้ว',
    'ถอดมิเตอร์แล้ว',
  ];

  //ปลดสายแล้ว
  static List<String> statusTextsFURM = [
    'ต่อสายแล้ว',
  ];
  //ให้ต่อสาย
  static List<String> statusTextsFUCM = [
    'ต่อสายแล้ว',
  ];

  //ถอดมิเตอร์แล้ว
  static List<String> statusTextsWMMR = [
    'ต่อมิเตอร์แล้ว',
  ];

  //ต่อมิเตอร์แล้ว
  static List<String> statusTextsWMST = [
    'ต่อสายแล้ว',
    'ต่อมิเตอร์แล้ว',
  ];

  //ให้ต่อมิเตอร์
  static List<String> statusTextsWMSTT = [
    'ต่อมิเตอร์แล้ว',
  ];

  //คำสั่งให้ถอดมิเตอร์
  static List<String> statusTextsTodd = [
    'ถอดมิเตอร์แล้ว',
  ];

  MyConstant();

  TextStyle h1Style() => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      );

  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );
  TextStyle h3Style() => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );
  TextStyle h4Style() => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  TextStyle h5Style() => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.normal,
      );
}
