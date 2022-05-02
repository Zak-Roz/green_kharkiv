import 'package:flutter/material.dart';
import 'package:green_kharkiv/constants.dart';
import 'package:green_kharkiv/const/translit_name.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:green_kharkiv/main-config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:green_kharkiv/register/entity/detail_street.dart';

late dynamic streetFurniture;
late dynamic streetFurnitureFull;
late DioCacheManager _dioCacheManager;
Widget? _appBarTitle;



class Constructions extends StatefulWidget {
  @override
  _ConstructionsPageState createState() => new _ConstructionsPageState();
}

class _ConstructionsPageState extends State<Constructions> {
  Icon _searchIcon = new Icon(Icons.search);
  final TextEditingController _filter = new TextEditingController();
  dynamic filteredData = [];
  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    _dioCacheManager = DioCacheManager(CacheConfig());
    Options _cacheOptions = buildCacheOptions(Duration(days: 10), forceRefresh: true);
    Dio _dio = Dio();
    _dio.interceptors.add(_dioCacheManager.interceptor);
    const String apiUrlPub = EnvironmentConfig.HOST_PUB;
    final urlStreetFurniture = '$apiUrlPub/api-user/vs.crm.data.api?path=eco_fund.ef_street_furniture&limit=100';
    final responseSpace = await _dio.get(
      urlStreetFurniture,
      options: _cacheOptions,
    );
    streetFurnitureFull = Map<String, dynamic>.from(responseSpace.data);
    streetFurniture = List<Map<String, dynamic>>.from(streetFurnitureFull["rows"]);
    return streetFurniture;
  }

  _ConstructionsPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          filteredData = streetFurniture;
        });
      } else {
        setState(() {
          filteredData = streetFurniture.where((el) => el["efsf_name"].toString().toLowerCase().contains('${_filter.text}'.toLowerCase())).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, projectSnap) {
          if (projectSnap.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: _appBarTitle == null ? new Text('Елементи благоустрою (${streetFurnitureFull["stat"]["count"]})') : _appBarTitle,
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    icon: _searchIcon,
                    iconSize: 35,
                    onPressed: () => _searchPressed(),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    iconSize: 35,
                    onPressed: () {},
                  ),
                  SizedBox(width: kDefaultPadding / 2)
                ],
              ),
              body: BodyLayout(context), // Text(json.encode(space))
            );
          } else if (projectSnap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${projectSnap.error}'),
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
  getAllData() {
    filteredData = streetFurniture;
    return filteredData.length;
  }

  Widget BodyLayout(BuildContext context) => ListView.builder(
    itemCount: filteredData.length == 0 ? getAllData() : filteredData.length,
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
                  leading: CachedNetworkImage(
                    width: 85,
                    imageUrl: filteredData[index]['efsf_image'] == null
                        ? filteredData[index]['photo_list'] == null
                        ? 'https://skillz4kidzmartialarts.com/wp-content/uploads/2017/04/default-image.jpg'
                        : filteredData[index]['photo_list'][0].contains('/files/upload')
                        ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['photo_list'][0]}"
                        : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['photo_list'][0]}"
                        : filteredData[index]['efsf_image'].contains('/files/upload')
                        ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['efsf_image']}"
                        : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['efsf_image']}",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    cacheManager: CacheManager(
                        Config(
                          filteredData[index]['efsf_image'] == null
                              ? filteredData[index]['photo_list'] == null
                              ? 'https://skillz4kidzmartialarts.com/wp-content/uploads/2017/04/default-image.jpg'
                              : filteredData[index]['photo_list'][0].contains('/files/upload')
                              ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['photo_list'][0]}"
                              : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['photo_list'][0]}"
                              : filteredData[index]['efsf_image'].contains('/files/upload')
                              ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['efsf_image']}"
                              : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['efsf_image']}",
                          stalePeriod: const Duration(days: 3),
                          //one week cache period
                        )
                    ),
                  ),
                  title: Text(filteredData[index]['efsf_name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                      Text('${filteredData[index]['geom']['coordinates'][1]} * ${filteredData[index]['geom']['coordinates'][0]}'),
                      const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                      RichText(
                        text: TextSpan(
                          // Here is the explicit parent TextStyle
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: '${NameConfig.NAME["efsf_respons"]}: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: '${filteredData[index]['efsf_respons']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Text('${spaces[index]['geom']['coordinates'][1]} * ${spaces[index]['geom']['coordinates'][0]}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailFurniture(data: streetFurnitureFull, id: filteredData[index]["id"])),
                  ),
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
                    // padding: EdgeInsets.fromLTRB(6, 1, 1, 1),
                    child: Center(
                      child: Text(
                        '${streetFurniture[index]['invent_number']}', // 'M00055'
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    )
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

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        _appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
            // prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        _appBarTitle = new Text('Елементи благоустрою (${streetFurnitureFull["stat"]["count"]})');
        _filter.clear();
      }
    });
  }
}

