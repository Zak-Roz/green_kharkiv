import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:community_material_icon/community_material_icon.dart';

import 'package:green_kharkiv/cache/cache.dart';
import 'package:green_kharkiv/register/entity/trees.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}

Widget _myListView(BuildContext context) {

  final titles = ['Реакційні зони', 'Дерева', 'Квітники', 'Мафи', 'Оффлайн карти'];

  final icons = [FontAwesomeIcons.image, IcoFontIcons.treeAlt, CommunityMaterialIcons.flower_tulip_outline, Linecons.shop, Icons.map];

  final route = [Zones(), Trees(), Flowers(), Constructions(), OfflineRegionsPage()];

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

void _pushScreen(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}