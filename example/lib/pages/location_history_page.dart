import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:provider/provider.dart';

class LocationHistoryPage extends StatefulWidget {
  @override
  _LocationHistoryPageState createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  List<LocationData> locationList = [];

  void _clear() async {
    await Provider.of<BackgroundLocation>(context, listen: false)
        .clearLocationCache();
    setState(() {
      locationList = [];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLocations();
    Provider.of<BackgroundLocation>(context, listen: false)
        .onLocationChanged
        .listen((event) {
      fetchLocations();
    });
  }

  void fetchLocations() async {
    locationList = await Provider.of<BackgroundLocation>(context, listen: false)
        .getLocations(['']);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location History'),
      ),
      body: locationList.length == 0
          ? Container()
          : ListView.builder(
              itemCount: locationList.length,
              itemBuilder: (_, index) {
                final locationItem = locationList[index];
                return locationItemWidget(locationItem);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _clear();
        },
        label: Text('Clear'),
        icon: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Widget locationItemWidget(LocationData item) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(4),
      child: Text('Lat=${item.latitude.toStringAsFixed(6)}, Lon=${item.longitude.toStringAsFixed(6)}'),
    ),
  );
}
