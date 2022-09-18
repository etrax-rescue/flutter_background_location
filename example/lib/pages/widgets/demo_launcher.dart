import 'package:flutter/material.dart';
import '../location_history_page.dart';

import '../live_location_page.dart';

class DemoLauncherWidget extends StatelessWidget {
  const DemoLauncherWidget() : super();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Demos:',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text('Live Location'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                    builder: (context) => LiveLocationPage()),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text('Location History'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                    builder: (context) => LocationHistoryPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
