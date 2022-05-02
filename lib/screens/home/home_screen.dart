import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:green_kharkiv/cache/cache.dart';
import 'package:green_kharkiv/screens/map/map_screen.dart';
import 'package:green_kharkiv/register/list_screen.dart';
import 'package:green_kharkiv/constants.dart';
import 'package:green_kharkiv/screens/home/profile.dart';
import 'package:green_kharkiv/screens/home/ScanQrPage.dart';

import 'package:green_kharkiv/main-config.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _HomeScreen();
}

class _HomeScreen extends State<MyHomePage> {

  int _selectedIndex = 0;

  final screens = [
    Maps(),
    Body(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      UserSimplePreferences.setInt('_selectedIndex', index);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: buildAppBar(), //AppBar(title: Text(EnvironmentConfig.APP_NAME)),
        body: screens[_selectedIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: new FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.qr_code_outlined, size: 35),
            onPressed: () => _pushScreen(context, ScanQrPage())
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(EnvironmentConfig.APP_NAME),
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.account_circle),
          iconSize: 35,
          onPressed: () {
            _pushScreen(context, Profile());
          },
        ),

        SizedBox(width: kDefaultPadding / 2)
      ],
    );
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.solidMap),
          label: 'Карта',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.gripHorizontal),
          label: 'Реєстр',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}