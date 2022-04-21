import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:green_kharkiv/main.dart';

import 'offline_region_map.dart';

final LatLngBounds kharkivBounds = LatLngBounds(
  southwest: const LatLng(49.8802, 36.065),
  northeast: const LatLng(50.112, 36.4745),
);

final LatLngBounds poltavaBounds = LatLngBounds(
  southwest: const LatLng(49.5275, 34.4337),
  northeast: const LatLng(49.6876, 34.7021),
);

final List<OfflineRegionDefinition> regionDefinitions = [
  OfflineRegionDefinition(
    bounds: kharkivBounds,
    minZoom: 8.0,
    maxZoom: 17.0,
    mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
  ),
  OfflineRegionDefinition(
    bounds: poltavaBounds,
    minZoom: 8.0,
    maxZoom: 17.0,
    mapStyleUrl: MapboxStyles.MAPBOX_STREETS,
  ),
];

final List<String> regionNames = ['Kharkiv', 'Poltava'];

class OfflineRegionListItem {
  OfflineRegionListItem({
    required this.offlineRegionDefinition,
    required this.downloadedId,
    required this.isDownloading,
    required this.name,
    required this.estimatedTiles,
  });

  final OfflineRegionDefinition offlineRegionDefinition;
  final int? downloadedId;
  final bool isDownloading;
  final String name;
  final int estimatedTiles;

  OfflineRegionListItem copyWith({
    int? downloadedId,
    bool? isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegionDefinition: offlineRegionDefinition,
        name: name,
        estimatedTiles: estimatedTiles,
        downloadedId: downloadedId,
        isDownloading: isDownloading ?? this.isDownloading,
      );

  bool get isDownloaded => downloadedId != null;
}

final List<OfflineRegionListItem> allRegions = [
  OfflineRegionListItem(
    offlineRegionDefinition: regionDefinitions[0],
    downloadedId: null,
    isDownloading: false,
    name: regionNames[0],
    estimatedTiles: 6789,
  ),
  OfflineRegionListItem(
    offlineRegionDefinition: regionDefinitions[1],
    downloadedId: null,
    isDownloading: false,
    name: regionNames[1],
    estimatedTiles: 3102,
  ),
];

class OfflineRegionsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Regions'),
      ),
      body: OfflineRegionBody(),
    );
  }
}

class OfflineRegionBody extends StatefulWidget {
  const OfflineRegionBody();

  @override
  _OfflineRegionsBodyState createState() => _OfflineRegionsBodyState();
}

class _OfflineRegionsBodyState extends State<OfflineRegionBody> {
  List<OfflineRegionListItem> _items = [];

  @override
  void initState() {
    super.initState();
    _updateListOfRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => Card(
            margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: ListTile(
              leading: IconButton(
                icon: Icon(Icons.map),
                onPressed: () => _goToMap(_items[index]),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _items[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Est. tiles: ${_items[index].estimatedTiles}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              trailing: _items[index].isDownloading
                  ? Container(
                child: CircularProgressIndicator(),
                height: 16,
                width: 16,
              )
                  : IconButton(
                icon: Icon(
                  _items[index].isDownloaded
                      ? Icons.delete
                      : Icons.file_download,
                ),
                onPressed: _items[index].isDownloaded
                    ? () => _deleteRegion(_items[index], index)
                    : () => _downloadRegion(_items[index], index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateListOfRegions() async {
    List<OfflineRegion> offlineRegions =
    await getListOfRegions(accessToken: MyApp.ACCESS_TOKEN);
    List<OfflineRegionListItem> regionItems = [];
    for (var item in allRegions) {
      final offlineRegion = offlineRegions.firstWhereOrNull(
              (offlineRegion) => offlineRegion.metadata['name'] == item.name);
      if (offlineRegion != null) {
        regionItems.add(item.copyWith(downloadedId: offlineRegion.id));
      } else {
        regionItems.add(item);
      }
    }
    setState(() {
      _items.clear();
      _items.addAll(regionItems);
    });
  }

  void _downloadRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    try {
      final downloadingRegion = await downloadOfflineRegion(
        item.offlineRegionDefinition,
        metadata: {
          'name': regionNames[index],
        },
        accessToken: MyApp.ACCESS_TOKEN,
      );
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: downloadingRegion.id,
            ));
      });
    } on Exception catch (_) {
      setState(() {
        _items.removeAt(index);
        _items.insert(
            index,
            item.copyWith(
              isDownloading: false,
              downloadedId: null,
            ));
      });
      return;
    }
  }

  void _deleteRegion(OfflineRegionListItem item, int index) async {
    setState(() {
      _items.removeAt(index);
      _items.insert(index, item.copyWith(isDownloading: true));
    });

    await deleteOfflineRegion(
      item.downloadedId!,
      accessToken: MyApp.ACCESS_TOKEN,
    );

    setState(() {
      _items.removeAt(index);
      _items.insert(
          index,
          item.copyWith(
            isDownloading: false,
            downloadedId: null,
          ));
    });
  }

  _goToMap(OfflineRegionListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OfflineRegionMap(item),
      ),
    );
  }
}
