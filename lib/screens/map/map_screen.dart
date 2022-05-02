import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:green_kharkiv/main-config.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/services.dart';

import 'package:fluttericon/linecons_icons.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:green_kharkiv/register/entity/detail_space.dart';
import 'package:green_kharkiv/register/entity/detail_street.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => FullMapState(); // _Map();
}

class FullMapState extends State<Maps> {
  late MapboxMapController mapController;
  List<SymbolOptions> markers = [
    // SymbolOptions(
    //   geometry: LatLng(49.984358, 36.232845),
    //   iconImage: "assets/images/circle.png",
    //   iconSize: 0.08,
    //   draggable: true,
    // ),
  ];
  int index_location = -1;
  int index_marker = -1;
  var isLight = true;
  var mapboxStyle = MapboxStyles.MAPBOX_STREETS;
  late Widget listMapbox;
  late DioCacheManager _dioCacheManager;
  late dynamic spaceFull;
  late dynamic space;
  late dynamic streetFurniture;
  late dynamic streetFurnitureFull;
  var spaceIds = { "Germany" : "Berlin" };
  var streetFurnitureIds = { "Germany" : "Berlin" };

  @override
  void initState() {
    getJsonListItem();
    listMapbox = MapboxMap(
      styleString: mapboxStyle,
      // onMapClick: (dynamic point, LatLng coordinates) {
      //   print("1 $coordinates");
      // },
      onMapLongClick: (dynamic point, LatLng coordinates) {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text("${coordinates.latitude},${coordinates.longitude}"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(label: 'COPY', onPressed: () => Clipboard.setData(ClipboardData(text: "${coordinates.latitude},${coordinates.longitude}"))),
          ),
        );
      },
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: EnvironmentConfig.CENTER,
        zoom: 10.0,
      ),
    );
  }

  getJsonListItem() async {
    _dioCacheManager = DioCacheManager(CacheConfig());
    Options _cacheOptions = buildCacheOptions(Duration(hours: 12), forceRefresh: true);
    Dio _dio = Dio();
    _dio.interceptors.add(_dioCacheManager.interceptor);
    const String apiUrlPub = EnvironmentConfig.HOST_PUB;
    final urlSpace = '$apiUrlPub/api-user/vs.crm.data.api?path=eco_fund.ef_green_space&limit=100';
    // TODO
    final urlRecreationalZone = '$apiUrlPub/api-user/vs.crm.data.api?path=eco_fund.ef_recreational_zone&limit=100';
    final urlStreetFurniture = '$apiUrlPub/api-user/vs.crm.data.api?path=eco_fund.ef_street_furniture&limit=100';
    final responseSpace = await _dio.get(
        urlSpace,
        options: _cacheOptions,
    );
    final responseStreetFurniture = await _dio.get(
        urlStreetFurniture,
        options: _cacheOptions,
    );
    setState(() {
      spaceFull = Map<String, dynamic>.from(responseSpace.data);
      space = List<Map<String, dynamic>>.from(spaceFull["rows"]);
      streetFurnitureFull = Map<String, dynamic>.from(responseStreetFurniture.data);
      streetFurniture = List<Map<String, dynamic>>.from(streetFurnitureFull["rows"]);
      spaceIds.clear();
      streetFurnitureIds.clear();
      var i = 0;
      for(var item in space) {
        print('111111111111111111111111111111{"${i}": "${item["id"]}"}');
        spaceIds.addAll({"${i++}": "${item["id"]}"});
        markers.add(
            SymbolOptions(
              geometry: LatLng(item["geom"]["coordinates"][1], item["geom"]["coordinates"][0]),
              iconImage: "assets/images/rhombus.png",
              iconSize: 0.1,
            )
        );
      }
      for(var item in streetFurniture) {
        print('2222222222222222222222222222222222{"${i}": "${item["id"]}"}');
        streetFurnitureIds.addAll({"${i++}": "${item["id"]}"});
        markers.add(
            SymbolOptions(
              geometry: LatLng(item["geom"]["coordinates"][1], item["geom"]["coordinates"][0]),
              iconImage: "assets/images/square.png",
              iconSize: 0.15,
            )
        );
      }
    });
    mapController.addSymbols(markers);
    mapController.onSymbolTapped.add(onSymbolTapped);
  }

  onSymbolTapped(Symbol symbol) async {
    try {
      LatLng latLng = await mapController.getSymbolLatLng(symbol);
      print("spaceIds $spaceIds");
      print("streetFurnitureIds $streetFurnitureIds");
      dynamic item = space.where((el) => el["id"] == spaceIds[symbol.id]).toList();
      if (item.length != 0) {
        item = item[0];
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text('${item["efgs_name"]} (${latLng.latitude}, ${latLng.longitude})'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(label: 'OPEN', onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailSpace(data: spaceFull, id: spaceIds[symbol.id])),
            )),
          ),
        );
      }
      dynamic items = streetFurniture.where((el) => el["id"] == streetFurnitureIds[symbol.id]).toList();
      if (items.length != 0) {
        items = items[0];
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text('${items["efsf_name"]} (${latLng.latitude}, ${latLng.longitude})'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(label: 'OPEN', onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      DetailFurniture(data: streetFurnitureFull,
                          id: streetFurnitureIds[symbol.id])),
                )),
            // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      }
    } catch(err) {
      print("CATCH ID -> ${symbol.id}");
    }
  }

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  getCurrentLocation() async {
    // if (index_location > 0) {
    //   layers.removeAt(index_location);
    //   layers.removeAt(index_location - 1);
    // }
    // const _points = {
    //   "type": "FeatureCollection",
    //   "features": [
    //     {
    //       "type": "Feature",
    //       "id": 2,
    //       "properties": {
    //         "type": "restaurant",
    //       },
    //       "geometry": {
    //         "type": "Point",
    //         "coordinates": [0.985118, 0.230145]
    //       }
    //     },
    //     {
    //       "type": "Feature",
    //       "id": 3,
    //       "properties": {
    //         "type": "airport",
    //       },
    //       "geometry": {
    //         "type": "Point",
    //         "coordinates": [151.215730044667879, -33.874616048776858]
    //       }
    //     },
    //     {
    //       "type": "Feature",
    //       "id": 4,
    //       "properties": {
    //         "type": "bakery",
    //       },
    //       "geometry": {
    //         "type": "Point",
    //         "coordinates": [151.228803547973598, -33.892188026142584]
    //       }
    //     },
    //     {
    //       "type": "Feature",
    //       "id": 5,
    //       "properties": {
    //         "type": "college",
    //       },
    //       "geometry": {
    //         "type": "Point",
    //         "coordinates": [151.186470299174118, -33.902781145804774]
    //       }
    //     }
    //   ]
    // };
    // await mapController?.setGeoJsonSource("points", _points);

    // await mapController?.addGeoJsonSource("points", _points);
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() async {
      LatLng _location =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _location,
            zoom: 18.0,
          ),
        ),
      );
      // await _latLngList
      //     .map((point) => mapController?.addCircle(
      //   CircleOptions(
      //     circleRadius: 6.5,
      //     circleColor: '#006992',
      //     circleOpacity: 0.8,
      //     geometry: point,
      //     draggable: true,
      //   ),
      // ));
      await mapController.clearCircles();
      await mapController.addCircle(
        CircleOptions(
          circleRadius: 6.5,
          circleColor: '#006992',
          circleOpacity: 0.8,
          geometry: _location,
          draggable: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // floatingActionButton: _createMapFloatingActionButton(context),
        floatingActionButton:
            Stack(alignment: Alignment.bottomRight, children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 1.0, 10),
            child: FloatingActionButton(
              child: Icon(Icons.layers_outlined), // Icons.swap_horiz),
              onPressed: () => setState(() {
                mapboxStyle = mapboxStyle == MapboxStyles.SATELLITE_STREETS ? MapboxStyles.MAPBOX_STREETS : MapboxStyles.SATELLITE_STREETS;
                        listMapbox = MapboxMap(
                          accessToken: EnvironmentConfig.ACCESS_TOKEN,
                          styleString: mapboxStyle,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(EnvironmentConfig.LATITUDE,
                                EnvironmentConfig.LONGITUDE),
                            zoom: 10.0,
                          ),
                        );
                      }
                  // onPressed: () => setState(
                  //       () => isLight = !isLight,
                  // ),
                  ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16.0, 40.0, 1.0, 0.0),
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: _createLayers(context),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 108.0, 1.0, 80.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: _createMapFloatingActionButton(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 68.0, 1.0, 150.0),
            child: FloatingActionButton(
              child: Icon(Icons.location_searching),
              onPressed: getCurrentLocation,
              //   onPressed: () => {},
            ),
          ),
        ]),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: FloatingActionButton(
        //     child: Icon(Icons.swap_horiz),
        //     onPressed: () => setState(
        //           () => isLight = !isLight,
        //     ),
        //   ),
        // ),
        body: Stack(children: <Widget>[
          listMapbox,
          // MapboxMap(
          //   styleString: isLight ? MapboxStyles.MAPBOX_STREETS : MapboxStyles.DARK,
          //   onMapCreated: _onMapCreated,
          //   initialCameraPosition: const CameraPosition(
          //         target: LatLng(EnvironmentConfig.LATITUDE, EnvironmentConfig.LONGITUDE),
          //         zoom: 10.0,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: _createLayers(context),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16.0, 86.0, 16.0, 16.0),
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: _createMapFloatingActionButton(context),
          //   ),
          // ),
        ]));
  }

  Widget _createMapFloatingActionButton(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      openCloseDial: isDialOpen,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      children: [
        SpeedDialChild(
          child: Icon(IcoFontIcons.treeAlt),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Зелені зони',
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(CommunityMaterialIcons.flower_tulip_outline),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Зелені насадження',
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(Linecons.shop),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Елементи благоустрою',
          onTap: () {},
        ),
        // SpeedDialChild(
        //     child: Icon(Icons.layers),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Шари',
        //     onTap: () {
        //       // globalVars.layersList.length == 0? null:showTopLayersList();
        //     }),
        // SpeedDialChild(
        //     child: Icon(Icons.layers),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Шари',
        //     onTap: () {
        //       globalVars.layersList.length == 0? null:showTopLayersList();
        //     }
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.location_searching),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Місце розташування',
        //     onTap: getCurrentLocation),
        // SpeedDialChild(
        //   child: Icon(Icons.place),
        //   foregroundColor: Colors.white,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   label: 'Виміряти відстань',
        //   onTap: () => print('DISTANCE'),
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.add),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Додати елемент',
        //     onTap: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen()));
        //     }
        // ),
      ],
    );
  }
/*
  Widget _createLayers(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);
    return SpeedDial(
      icon: Icons.layers,
      activeIcon: Icons.close,
      spacing: 3,
      openCloseDial: isDialOpen,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      direction: SpeedDialDirection.down,
      children: [
        SpeedDialChild(
          child: Icon(IcoFontIcons.treeAlt),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'SATELLITE_STREETS',
          onTap: () => setState(
            () => {
              mapboxStyle = MapboxStyles.SATELLITE_STREETS,
              listMapbox = MapboxMap(
                styleString: mapboxStyle,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                      EnvironmentConfig.LATITUDE, EnvironmentConfig.LONGITUDE),
                  zoom: 10.0,
                ),
              ),
            },
          ),
        ),
        SpeedDialChild(
          child: Icon(CommunityMaterialIcons.flower_tulip_outline),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'MAPBOX_STREETS',
          onTap: () => setState(
            () => {
              mapboxStyle = MapboxStyles.MAPBOX_STREETS,
              listMapbox = MapboxMap(
                styleString: mapboxStyle,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                      EnvironmentConfig.LATITUDE, EnvironmentConfig.LONGITUDE),
                  zoom: 10.0,
                ),
              ),
            },
          ),
        ),
        // SpeedDialChild(
        //   child: Icon(Icons.layers),
        //   foregroundColor: Colors.white,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   label: 'OUTDOORS',
        //   onTap: () => setState(
        //     () => {
        //       mapboxStyle = MapboxStyles.OUTDOORS,
        //       listMapbox = MapboxMap(
        //         styleString: mapboxStyle,
        //         onMapCreated: _onMapCreated,
        //         initialCameraPosition: const CameraPosition(
        //           target: LatLng(
        //               EnvironmentConfig.LATITUDE, EnvironmentConfig.LONGITUDE),
        //           zoom: 10.0,
        //         ),
        //       ),
        //     },
        //   ),
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.layers),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Шари',
        //     onTap: () {
        //       globalVars.layersList.length == 0? null:showTopLayersList();
        //     }
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.location_searching),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Місце розташування',
        //     onTap: getCurrentLocation),
        // SpeedDialChild(
        //   child: Icon(Icons.place),
        //   foregroundColor: Colors.white,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   label: 'Виміряти відстань',
        //   onTap: () => print('DISTANCE'),
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.add),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Додати елемент',
        //     onTap: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen()));
        //     }
        // ),
      ],
    );
  }
*/
}

/*
class _Map extends State<Map> {
  final PopupController _popupController = PopupController();
  LatLng _current_location = LatLng(0, 0);
  int index_location = -1;
  int index_marker = -1;
  MapController _mapController = MapController();
  List<LatLng> _latLngList = [
    LatLng(49.988158, 36.237185),
    LatLng(49.981158, 36.231115),
    LatLng(49.982158, 36.239145),
    LatLng(49.983158, 36.238145),
    LatLng(49.984158, 36.237145),
    LatLng(49.985158, 36.236145),
    LatLng(49.986158, 36.235145),
    LatLng(49.987158, 36.234145),
    LatLng(49.988158, 36.233145),
    LatLng(49.989158, 36.232145),
    LatLng(49.980158, 36.231145),
    LatLng(49.985118, 36.230145),
    LatLng(0.985118, 0.230145),
  ];
  List<Marker> markers = [];
  List<Marker> _markers = [];
  List<LayerOptions> layers = [
    TileLayerOptions(
        minZoom: 1,
        maxZoom: 18,
        backgroundColor: Colors.black,
        // errorImage: ,
        urlTemplate:
            "https://api.mapbox.com/styles/v1/testuserzr/ckxzxrvx0348k14l5754o1ok5/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGVzdHVzZXJ6ciIsImEiOiJja3h6eDEwNGQydG0xMnZvMGpzaTlhbzd2In0.nj3rPIg-Pu0s2AukMlFW7w"
        //urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //subdomains: ['a', 'b', 'c'],
        ),
    // MarkerLayerOptions(
    //   markers: markers,
    // ),
    // CircleLayerOptions(circles: [
    //   CircleMarker(
    //     point: LatLng(12.0,12.0),
    //     color: Colors.blue.withOpacity(0.3),
    //     borderStrokeWidth: 2.5,
    //     borderColor: Colors.blue,
    //     radius: 50,
    //   )
    // ]),
    // MarkerClusterLayerOptions(
    //   maxClusterRadius: 190,
    //   disableClusteringAtZoom: 16,
    //   size: Size(50, 50),
    //   fitBoundsOptions: FitBoundsOptions(
    //     padding: EdgeInsets.all(50),
    //   ),
    //   markers: _markers,
    //   polygonOptions: PolygonOptions(
    //       borderColor: Colors.blueAccent,
    //       color: Colors.black12,
    //       borderStrokeWidth: 3),
    //   popupOptions: PopupOptions(
    //       popupController: _popupController,
    //       popupBuilder: (_, marker) => Container(
    //         color: Colors.amberAccent,
    //         child: Text('Popup'),
    //       )),
    //   builder: (context, markers) {
    //     return Container(
    //       alignment: Alignment.center,
    //       decoration:
    //       BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    //       child: Text('${markers.length}'),
    //     );
    //   },
    // ),
  ];

  @override
  void initState() {
    // markers.add(Marker(
    //   width: 25.0,
    //   height: 25.0,
    //   point: _current_location,
    //   builder: (context) => Container(
    //     child: IconButton(
    //       icon: Icon(Icons.circle),
    //       color: Colors.blueGrey,
    //       onPressed: () {
    //         print('Current location');
    //       },
    //       iconSize: 10.0,
    //     ),
    //   ),
    // ));
    _markers = _latLngList
        .map((point) => Marker(
              point: point,
              width: 60,
              height: 60,
              builder: (context) => Icon(
                Icons.stop, //(square), lens (circle), details (triangle)
                size: 30,
                color: Colors.blueAccent,
              ),
            ))
        .toList();
    layers.add(MarkerClusterLayerOptions(
      maxClusterRadius: 190,
      disableClusteringAtZoom: 16,
      size: Size(50, 50),
      fitBoundsOptions: FitBoundsOptions(
        padding: EdgeInsets.all(50),
      ),
      markers: _markers,
      polygonOptions: PolygonOptions(
          borderColor: Colors.blueAccent,
          color: Colors.black12,
          borderStrokeWidth: 3),
      popupOptions: PopupOptions(
          popupController: _popupController,
          popupBuilder: (_, marker) => Container(
                color: Colors.amberAccent,
                child: Text('Popup'),
              )),
      builder: (context, markers) {
        return Container(
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          child: Text('${markers.length}'),
        );
      },
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onLongPress: (TapPosition, LatLng) {
            addPin(LatLng);
            print('$LatLng');
          },
          center:
              LatLng(EnvironmentConfig.LATITUDE, EnvironmentConfig.LONGITUDE),
          bounds: LatLngBounds.fromPoints(_latLngList),
          zoom: 7,
          maxZoom: 18,
          minZoom: 2,
          plugins: [
            MarkerClusterPlugin(),
          ],
          //onTap: (_) => _popupController.hidePopupsOnlyFor(),
        ),
        layers: layers,
      ),
      floatingActionButton: _createMapFloatingActionButton(context),
    );
  }

  addPin(LatLng latlng) {
    setState(() {
      markers.add(Marker(
        width: 30.0,
        height: 30.0,
        point: latlng,
        builder: (ctx) => Container(
          child: Icon(Icons.place),
        ),
      ));
    });
  }

  Widget _createMapFloatingActionButton(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      openCloseDial: isDialOpen,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      children: [
        SpeedDialChild(
          child: Icon(IcoFontIcons.treeAlt),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Дерева',
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(CommunityMaterialIcons.flower_tulip_outline),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Квітники',
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(Linecons.shop),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Мафи',
          onTap: () {},
        ),
        // SpeedDialChild(
        //     child: Icon(Icons.layers),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Шари',
        //     onTap: () {
        //       globalVars.layersList.length == 0? null:showTopLayersList();
        //     }
        // ),
        SpeedDialChild(
            child: Icon(Icons.location_searching),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Місце розташування',
            onTap: getCurrentLocation),
        // SpeedDialChild(
        //   child: Icon(Icons.place),
        //   foregroundColor: Colors.white,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   label: 'Виміряти відстань',
        //   onTap: () => print('DISTANCE'),
        // ),
        // SpeedDialChild(
        //     child: Icon(Icons.add),
        //     foregroundColor: Colors.white,
        //     backgroundColor: Theme.of(context).primaryColor,
        //     label: 'Додати елемент',
        //     onTap: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen()));
        //     }
        // ),
      ],
    );
  }

  getCurrentLocation() async {
    if (index_location > 0) {
      layers.removeAt(index_location);
      layers.removeAt(index_location - 1);
    }
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _current_location =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      if (markers.isNotEmpty) {
        markers.clear();
        print(markers.length);
      }
      markers.add(Marker(
        width: 25.0,
        height: 25.0,
        point: _current_location,
        builder: (context) => Container(
          child: IconButton(
            icon: Icon(Icons.circle),
            color: Colors.blue,
            onPressed: () {
              _mapController.move(_current_location, 18.0);
            },
            iconSize: 10.0,
          ),
        ),
      ));
      layers.add(MarkerLayerOptions(
        markers: markers,
      ));
      layers.add(CircleLayerOptions(circles: [
        CircleMarker(
          point: _current_location,
          color: Colors.blue.withOpacity(0.3),
          borderStrokeWidth: 2.5,
          borderColor: Colors.blue,
          radius: 20,
        )
      ]));
      index_location = layers.length - 1;
      _mapController.move(LatLng(_locationData.latitude!, _locationData.longitude!), 19.0);
    });
  }
}
*/
