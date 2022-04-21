import 'package:flutter/material.dart';
import 'package:green_kharkiv/constants.dart';

final images = [
  'https://www.tilelook.com/system/tile_picture/resource/13786494/thumb_Colors_ocra_lucido.png',
  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRh2u9kdoOV2Sbq8GTm1TnTK4FTZygnPVGHqg&usqp=CAU'
];
// 'https://www.colors.lol/assets/images/colors.jpg',
// 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdtBo65ml5bwFNInFSpC50u8GuOUyo-A_mgg&usqp=CAU'
final icons = [Icons.image, Icons.track_changes, Icons.flag, Icons.shop];

class Constructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мафи (${images.length})'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 35,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            iconSize: 35,
            onPressed: () {},
          ),
          SizedBox(width: kDefaultPadding / 2)
        ],
      ),
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

Widget buildImageInteractionCard(BuildContext context) => ListView.builder(
      itemCount: images.length,
      itemBuilder: (BuildContext, index) {
        return Card(
          margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
          child: Center(
            child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 100,
                  child: ListTile(
                    // leading: Icon(icons[index]),
                    leading: Image.network(images[index], width: 85),
                    // leading: Image(
                    //   image: NetworkImage(images[index]),
                    //   height: 90,
                    // ),
                    // leading: Padding(
                    //   padding: const EdgeInsets.all(0.0),
                    //
                    //   // Image.network(src)
                    //   child: Image.network(images[index]),
                    // ),
                    title: Text('Three-line ListTile'),
                    subtitle: Text('12.0147852 * 25.3698520'),
                    // onTap: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DetailsScreen(
                    //       product: products[index],
                    //     ),
                    //   )),
                    // trailing: Icon(Icons.more_vert),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 32,
                  child: Container(
                    width: 53,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    padding: EdgeInsets.fromLTRB(6, 1, 1, 1),
                    child: Text(
                      'M00055',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      shrinkWrap: true,
      padding: EdgeInsets.all(5),
      scrollDirection: Axis.vertical,
    );
