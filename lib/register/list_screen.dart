import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:community_material_icon/community_material_icon.dart';

import 'package:green_kharkiv/register/entity/flowers.dart';
import 'package:green_kharkiv/register/entity/zones.dart';
import 'package:green_kharkiv/register/entity/constructions.dart';
import 'package:green_kharkiv/register/entity/cache/offline_regions.dart';

class Body extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Body> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return BodyLayout();
  }
}

class BodyLayout extends StatelessWidget {

  Widget _myListView(BuildContext context) {
    final titles = ['Зони відпочинку', 'Зелені насадження', 'Елементи благоустрою', 'Оффлайн карти'];

    final icons = [FontAwesomeIcons.image, CommunityMaterialIcons.flower_tulip_outline, Linecons.shop, Icons.map];

    final route = [Zones(), Flowers(), Constructions(), OfflineRegionsPage()];

    return ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: ListTile(
            leading: Icon(icons[index]),
            title: Text(titles[index]),
            // contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            // minLeadingWidth: 0,
            onTap: () {
              _pushScreen(context, route[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}



void _pushScreen(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}