import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/constants.dart';
import '../utilities/deu_api.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SharedPreferences _prefs;

  bool _rememberMe = false;
  bool _autoLogin = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final _pwFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  _loadPref() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('remember') == true) {
      setState(
        () {
          _idController.text = _prefs.getString('id')!;
          _pwController.text = _prefs.getString('pw')!;
          _rememberMe = _prefs.getBool('remember')!;
        },
      );
    }
    if (_prefs.getBool('autoLogin') == true) {
      setState(
        () {
          _autoLogin = _prefs.getBool('autoLogin')!;
        },
      );
      await getLogin();
    }
  }

  _savePref() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('id', _idController.text);
    await _prefs.setString('pw', _pwController.text);
    await _prefs.setBool('remember', _rememberMe);
    await _prefs.setBool('autoLogin', _autoLogin);
  }

  Widget _buildIDTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '학번',
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _idController,
            keyboardType: TextInputType.number,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_pwFocusNode),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.perm_identity_outlined,
                color: Colors.white,
              ),
              hintText: '학번',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '비밀번호',
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _pwController,
            onEditingComplete: getLogin,
            obscureText: true,
            focusNode: _pwFocusNode,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: '비밀번호',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return SizedBox(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.blue,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          const Text(
            '로그인 정보 저장',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoLoginCheckbox() {
    return SizedBox(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _autoLogin,
              checkColor: Colors.blue,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _autoLogin = value!;
                });
              },
            ),
          ),
          const Text(
            '자동 로그인',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: getLogin,
        padding: const EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: const Text(
          '로그인',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwFocusNode.dispose();

    super.dispose();
  }

  Future getLogin() async {
    String id = _idController.text;
    String pw = _pwController.text;

    var appLoginResult = await DEUApi().postSmartAppLogin(id, pw);
    if (appLoginResult['SUCCESS_YN'] == 'Y') {
      _savePref();
      await DEUApi().postSmartWebLogin(id, pw);
      Fluttertoast.showToast(
        msg:
            "로그인 성공! - ${appLoginResult['USER_ID']} ${appLoginResult['USER_NM']}",
        toastLength: Toast.LENGTH_SHORT,
      );
      Get.offAllNamed('/score', arguments: [id, pw]);
    } else {
      Fluttertoast.showToast(
        msg: "로그인 실패!\n학번과 비밀번호를 확인해주세요.",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 100.0,
                      ),
                      const Text(
                        'Login to DEU',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildIDTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildRememberMeCheckbox(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      _buildAutoLoginCheckbox(),
                      _buildLoginBtn(),
                      const SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
