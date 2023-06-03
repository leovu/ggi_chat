import 'package:flutter/material.dart';
import 'package:ggi_chat/ggi_chat.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const OverlaySupport.global(
    child: MaterialApp(
      supportedLocales: [Locale('en', 'US')],
      locale: Locale('en','US'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // ViewerLocalizationsDelegate.delegate,
      ],
      title: 'Navigation Basics',
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _userNameController.text = '+84372099835';
        _passwordController.text = '123456';
        _domainController.text = 'http://dev.api.ggigroup.org/';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Username'
                    ),
                    controller: _userNameController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Password'
                    ),
                    controller: _passwordController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Domain'
                    ),
                    controller: _domainController,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: InkWell(
                onTap: () async {
                  if(_userNameController.value.text == '') {
                    return;
                  }
                  if(_passwordController.value.text == '') {
                    return;
                  }
                  if(_domainController.value.text == '') {
                    return;
                  }
                  GgiChat.open(context,_userNameController.value.text, _passwordController.value.text,
                      'parent', 'assets/icon-app.png', const Locale('vi', 'VN'), domain: _domainController.value.text,
                      chatDomain: 'http://dev.ws.ggigroup.org/');
                },
                child: Container(
                    height: 40.0,
                    width: 80.0,
                    color: Colors.blue,
                    child: const Center(child: Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)))),
          ),
        ],
      ),
    );
  }
}
