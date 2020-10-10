import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:background_location/background_location.dart';
import 'package:provider/provider.dart';

class LiveLocationPage extends StatelessWidget {
  const LiveLocationPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
      ),
      body: StreamBuilder<LocationData>(
        stream: Provider.of<BackgroundLocation>(context, listen: false)
            .onLocationChanged,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error occured');
          } else if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return LocationDataWidget(locationData: snapshot.data);
        },
      ),
    );
  }
}

class LocationDataWidget extends StatelessWidget {
  const LocationDataWidget({this.locationData});
  final LocationData locationData;

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(locationData.time.toInt());
    return Container(
      child: Column(children: <Widget>[
        DataEntry(label: 'Datetime', data: '$dateTime'),
        DataEntry(label: 'Latitude', data: '${locationData.latitude}'),
        DataEntry(label: 'Longitude', data: '${locationData.longitude}'),
        DataEntry(label: 'Accuracy', data: '${locationData.accuracy}'),
        DataEntry(label: 'Altitude', data: '${locationData.altitude}'),
        DataEntry(label: 'Speed', data: '${locationData.speed}'),
        DataEntry(
            label: 'Speed Accuracy', data: '${locationData.speedAccuracy}'),
        DataEntry(label: 'Heading', data: '${locationData.heading}'),
      ]),
    );
  }
}

class DataEntry extends StatelessWidget {
  const DataEntry({this.label, this.data});
  final String label;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(data, style: TextStyle(color: Colors.grey))
          ]),
    );
  }
}
