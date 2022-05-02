import 'package:flutter/material.dart';
import 'package:green_kharkiv/constants.dart';
import 'package:green_kharkiv/const/translit_name.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:green_kharkiv/main-config.dart';

final titles = ['asd', 'das', 'erwef'];
late List<String> listOfUrls= [];
late dynamic keys;
late dynamic json;
late dynamic meta;

class DetailFurniture extends StatelessWidget {
  final dynamic data;
  final dynamic id;
  DetailFurniture({ Key? key, this.data, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    meta = data["meta"]["columns"];
    json = data["rows"].where((el) => el["id"] == id).toList()[0];
    keys = json.keys;
    listOfUrls.clear();
    if(json["photo_list"] != null) {
      listOfUrls = fillPathToPhoto(List<String>.from(json["photo_list"]));
    }
    if(json["efsf_image"] != null) {
      listOfUrls.add(json["efsf_image"].contains('/files/upload')
          ? "${EnvironmentConfig.HOST_PUB}${json["efsf_image"]}"
          : "${EnvironmentConfig.HOST_PUB}/files/${json["efsf_image"]}");
    }
    print('sjadgfkjhasdkjshafkjds $json');
    return Scaffold(
      appBar: AppBar(
        title: Text('${json['efsf_name']}'),
        elevation: 0,
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.search),
          //   iconSize: 35,
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: Icon(Icons.filter_list),
          //   iconSize: 35,
          //   onPressed: () {},
          // ),
          SizedBox(width: kDefaultPadding / 2)
        ],
      ),
      // appBar: AppBar(title: Text('Дерева (${titles.length})')),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildImageInteractionCard(context);
  }
}


Widget buildImageInteractionCard(BuildContext context) =>
    Container(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          children: jsonData(),
        )
    );

jsonData() {
  List<Widget> children = [];
  if (listOfUrls.length != 0) {
    children.add(Padding(padding: EdgeInsets.only(bottom: 2.0)));
    children.add(GalleryImage(imageUrls: listOfUrls));
  }
  for (var kv in keys) {
    var name = meta.where((el) => el["name"] == kv).toList();
    if (name.length == 0) continue;
    name = name[0]["title"];
    if (name == null) name = NameConfig.NAME['${kv}'];
    if (name == '') continue;
    var value = json['${kv}'] == null ? NameConfig.NAME['null'] : json['${kv}'];
    children.add(Padding(padding: EdgeInsets.only(bottom: 5.0)));
    children.add(RichText(
      text: TextSpan(
        // Here is the explicit parent TextStyle
        style: new TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
        children: <TextSpan>[
          new TextSpan(text: '${name}: ', style: new TextStyle(fontWeight: FontWeight.bold)),
          new TextSpan(text: '${value}'),
        ],
      ),
    ));
  }
  return children;
}

fillPathToPhoto(List<String> img) {
  List<String> fillImg = img.map((el) => el.contains('/files/upload')
      ? "${EnvironmentConfig.HOST_PUB}${el}"
      : "${EnvironmentConfig.HOST_PUB}/files/${el}").toList();
  return fillImg;
}