import 'package:flutter/material.dart';
import 'package:green_kharkiv/constants.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:green_kharkiv/main-config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:green_kharkiv/register/entity/detail_space.dart';

late dynamic spaces;
late dynamic spacesFull;
late DioCacheManager _dioCacheManager;
Widget? _appBarTitle;

class Flowers extends StatefulWidget {
  @override
  _FlowersPageState createState() => new _FlowersPageState();
}

class _FlowersPageState extends State<Flowers> {
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
    final urlSpace = '$apiUrlPub/api-user/vs.crm.data.api?path=eco_fund.ef_green_space';
    final responseSpace = await _dio.get(
      urlSpace,
      options: _cacheOptions,
    );
    spacesFull = Map<String, dynamic>.from(responseSpace.data);
    spaces = List<Map<String, dynamic>>.from(spacesFull["rows"]);
    return spaces;
  }

  _FlowersPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          filteredData = spaces;
        });
      } else {
        setState(() {
          filteredData = spaces.where((el) => el["efgs_name"].toString().toLowerCase().contains('${_filter.text}'.toLowerCase())).toList();
        });
      }
    });
  }

  @override
  Widget build(context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, projectSnap) {
          if (projectSnap.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: _appBarTitle == null ? new Text('Зелені насадження (${spacesFull["stat"]["count"]})') : _appBarTitle,
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
                    onPressed: () {
                      showFilterDialog(context);
                    },
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
  var mainColor = Color(0xff1B3954);
  var textColor = Color(0xff727272);
  var accentColor = Color(0xff16ADE1);
  var whiteText = Color(0xffF5F5F5);
  String? _sortValue;
  String _ascValue = "ASC";

  Future<void> showFilterDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext build) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(
                    "Filter",
                    style: TextStyle(color: mainColor),
                  )),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 12, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort,
                              color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text("Sort by"),
                                items: <String>[
                                  "Name",
                                  "Age",
                                  "Date",
                                ].map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: textColor, fontSize: 16)),
                                  );
                                }).toList(),
                                value: _sortValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _sortValue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8, right: 10),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.sort_by_alpha,
                              color: Color(0xff808080),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                items: <String>[
                                  "ASC",
                                  "DESC",
                                ].map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: textColor, fontSize: 16)),
                                  );
                                }).toList(),
                                value: _ascValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _ascValue = newValue.toString();
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  getAllData() {
    filteredData = spaces;
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
                    imageUrl: filteredData[index]['efgs_image'] == null
                        ? filteredData[index]['photo_list'] == null
                        ? 'https://skillz4kidzmartialarts.com/wp-content/uploads/2017/04/default-image.jpg'
                        : filteredData[index]['photo_list'][0].contains('/files/upload')
                        ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['photo_list'][0]}"
                        : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['photo_list'][0]}"
                        : filteredData[index]['efgs_image'].contains('/files/upload')
                        ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['efgs_image']}"
                        : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['efgs_image']}",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    cacheManager: CacheManager(
                        Config(
                          filteredData[index]['efgs_image'] == null
                              ? filteredData[index]['photo_list'] == null
                              ? 'https://skillz4kidzmartialarts.com/wp-content/uploads/2017/04/default-image.jpg'
                              : filteredData[index]['photo_list'][0].contains('/files/upload')
                              ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['photo_list'][0]}"
                              : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['photo_list'][0]}"
                              : filteredData[index]['efgs_image'].contains('/files/upload')
                              ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['efgs_image']}"
                              : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['efgs_image']}",
                          stalePeriod: const Duration(days: 3),
                          //one week cache period
                        )
                    ),
                  ),
                  // Image.network(
                  //     filteredData[index]['efgs_image'] == null
                  //         ? 'https://skillz4kidzmartialarts.com/wp-content/uploads/2017/04/default-image.jpg'
                  //         : filteredData[index]['efgs_image'].contains('/files/upload')
                  //         ? "${EnvironmentConfig.HOST_PUB}${filteredData[index]['efgs_image']}"
                  //         : "${EnvironmentConfig.HOST_PUB}/files/${filteredData[index]['efgs_image']}",
                  //     width: 85),
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
                  title: Text(filteredData[index]['efgs_name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                      Text('${filteredData[index]['geom']['coordinates'][1]} * ${filteredData[index]['geom']['coordinates'][0]}'),
                      const Padding(padding: EdgeInsets.only(bottom: 10.0)),
                      Container(
                        color: filteredData[index]['efgs_status'] == 1
                            ? Colors.green : filteredData[index]['efgs_status'] == 2 ?
                        Colors.yellow : Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Text(
                          filteredData[index]['efgs_status'] == 1
                              ? 'Добрий' : filteredData[index]['efgs_status'] == 2 ?
                          'Задовільний' : 'Не задовільний',
                          style: new TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  // Text('${filteredData[index]['geom']['coordinates'][1]} * ${filteredData[index]['geom']['coordinates'][0]}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailSpace(data: spacesFull, id: filteredData[index]["id"])),
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
                        '${filteredData[index]['efgs_barcode']}', // 'M00055'
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
        _appBarTitle = new Text('Зелені насадження (${spacesFull["stat"]["count"]})');
        _filter.clear();
      }
    });
  }
}

// class BodyLayout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return buildImageInteractionCard(context);
//   }
// }


