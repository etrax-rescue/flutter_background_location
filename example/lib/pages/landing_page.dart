import 'package:background_location_example/pages/widgets/services_status.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'widgets/permission_status.dart';
import 'widgets/demo_launcher.dart';
import 'widgets/start_stop_fab.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _showInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Demo Application'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Created by Julius Piso'),
                InkWell(
                  child: Text(
                    'https://github.com/yozoon/flutter_background_location',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () async => await launch(
                      'https://github.com/yozoon/flutter_background_location'),
                ),
                const Text(
                    'based on Flutter location plugin by Guillaume Bernos'),
                InkWell(
                  child: Text(
                    'https://github.com/Lyokone/flutterlocation',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () async => await launch(
                      'https://github.com/Lyokone/flutterlocation'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Location Demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: const <Widget>[
              PermissionStatusWidget(),
              Divider(height: 32),
              ServicesStatusWidget(),
              Divider(height: 32),
              DemoLauncherWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: StartStopFAB(),
    );
  }
}
