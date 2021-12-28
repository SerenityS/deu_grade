import 'dart:convert';

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
// ignore: import_of_legacy_library_into_null_safe
import 'package:requests/requests.dart';

class DEUApi {
  final String year = '2021';
  final String smt = '20';

  Future postSmartAppLogin(id, pw) async {
    String appLoginUrl = 'https://smartdeu.deu.ac.kr/applogin.do';

    var response = await Requests.post(appLoginUrl,
        body: <String, String>{
          'user_id': id,
          'passwd': pw,
        },
        bodyEncoding: RequestBodyEncoding.JSON);
    return jsonDecode(response.content());
  }

  Future postSmartWebLogin(id, pw) async {
    String webLoginUrl = 'https://smartdeu.deu.ac.kr/weblogin.do';

    await Requests.post(
      webLoginUrl,
      body: <String, String>{
        'user_id': id,
        'passwd': pw,
      },
    );
  }

  Future getGradeList() async {
    String url =
        'https://smartdeu.deu.ac.kr/viewProcess/stud/d/DM01_D001.do?year=2021&smt=20&menuCd=300023&spNm=Up_App_Usb0301q_Check&spNm=Up_App_Usb0301q';

    var response = await Requests.get(
      url,
      headers: <String, String>{
        'Accept': '*/*',
      },
    );

    dom.Document document = parser.parse(response.content());

    var gradeDate = document.getElementsByClassName('title');
    var gradeData = document.getElementsByClassName('detail_info column2 dw50');

    var gradeList = [];
    for (var i = 0; i < gradeDate.length; i++) {
      gradeList.add([
        gradeDate[i].text.trim(),
        gradeData[i].getElementsByTagName('dt'),
        gradeData[i].getElementsByTagName('dd')
      ]);
      gradeList[i][1].removeRange(0, 3);
      gradeList[i][2].removeRange(0, 3);
    }
    return gradeList;
  }
}
