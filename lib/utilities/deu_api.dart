import 'dart:convert';

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DEUApi {
  late SharedPreferences _prefs;

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
    var r = await Requests.get('https://smartdeu.deu.ac.kr/introPage.do');

    dom.Document d = parser.parse(r.content());

    var doc = d.getElementById('frm');
    var yrSmtData = doc?.getElementsByTagName('input');

    var year = yrSmtData![0].attributes['value']!;
    var smt = yrSmtData[1].attributes['value']!;

    String url =
        'https://smartdeu.deu.ac.kr/viewProcess/stud/d/DM01_D001.do?year=$year&smt=$smt&menuCd=300023&spNm=Up_App_Usb0301q_Check&spNm=Up_App_Usb0301q';

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
      gradeList.add([gradeDate[i].text.trim(), gradeData[i].getElementsByTagName('dt'), gradeData[i].getElementsByTagName('dd')]);
      gradeList[i][1].removeRange(0, 3);
      gradeList[i][2].removeRange(0, 3);
    }
    return gradeList;
  }

  Future checkGradeList() async {
    _prefs = await SharedPreferences.getInstance();
    var gradeList = await getGradeList();
    for (var grade in gradeList) {
      var name = grade[0];
      var score = grade[2][4].text;

      var old_score = _prefs.getString(name);
      if (old_score != score) {
        _prefs.setString(name, score);
        print("$name 성적 정보 변경됨");
      }
    }
  }
}
