import 'package:flutter/material.dart';

import 'package:background_location/background_location.dart';
import 'package:provider/provider.dart';

class StartStopFAB extends StatefulWidget {
  @override
  _StartStopFABState createState() => _StartStopFABState();
}

class _StartStopFABState extends State<StartStopFAB> {
  IconData icon = Icons.play_arrow;
  bool updatesActive = false;
  String label = 'Start';

  @override
  void initState() {
    super.initState();
    init();
  }

  void updateState(bool active) {
    if (active) {
      setState(() {
        updatesActive = true;
        icon = Icons.stop;
        label = 'Stop';
      });
    } else {
      setState(() {
        updatesActive = false;
        icon = Icons.play_arrow;
        label = 'Start';
      });
    }
  }

  void init() async {
    bool active = await Provider.of<BackgroundLocation>(context, listen: false)
        .updatesActive();
    updateState(active);
  }

  Future<void> _startUpdates() async {
    final bool success =
        await Provider.of<BackgroundLocation>(context, listen: false)
            .startUpdates(
                notificationTitle: 'Location tracking active',
                notificationBody: 'This is a demo text',
                notificationClickable: true);
    if (success) {
      updateState(true);
    } else {
      if (await Provider.of<BackgroundLocation>(context, listen: false)
              .hasPermission() !=
          PermissionStatus.granted) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission is not yet granted.'),
          ),
        );
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled.'),
          ),
        );
      }
    }
  }

  Future<void> _stopUpdates() async {
    Provider.of<BackgroundLocation>(context, listen: false).stopUpdates();
    updateState(false);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(label),
      onPressed: () {
        if (updatesActive) {
          _stopUpdates();
        } else {
          _startUpdates();
        }
      },
      icon: Icon(icon),
      backgroundColor: Colors.green,
    );
  }
}
