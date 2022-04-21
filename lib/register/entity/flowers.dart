import 'package:flutter/material.dart';
import 'package:green_kharkiv/constants.dart';

final titles = ['asd', 'das', 'erwef'];

class Flowers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Квітники (${titles.length})'),
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
      // appBar: AppBar(title: Text('Квітники')),
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
    ListView.builder(itemCount: titles.length, itemBuilder: (context, index) {
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Ink.image(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1327&q=80',
                  ),
                  child: InkWell(
                    onTap: () {},
                  ),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Text(
                    'Cats rule the world! ${titles[index]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'The cat is the only domesticated species in the family Felidae and is often referred to as the domestic cat to distinguish it from the wild members of the family.',
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      );
    });