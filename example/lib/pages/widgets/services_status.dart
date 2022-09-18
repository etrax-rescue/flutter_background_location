import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:provider/provider.dart';

class ServicesStatusWidget extends StatefulWidget {
  const ServicesStatusWidget({Key? key}) : super(key: key);

  @override
  _ServicesStatusState createState() => _ServicesStatusState();
}

class _ServicesStatusState extends State<ServicesStatusWidget> {
  bool _serviceEnabled = false;

  Future<void> _checkService() async {
    final bool serviceEnabledResult =
        await Provider.of<BackgroundLocation>(context, listen: false)
            .serviceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabledResult;
    });
  }

  Future<void> _requestService() async {
    if (!_serviceEnabled) {
      final bool serviceRequestedResult =
          await Provider.of<BackgroundLocation>(context, listen: false)
              .requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Service enabled: $_serviceEnabled',
            style: Theme.of(context).textTheme.bodyText1),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 42),
              child: ElevatedButton(
                child: const Text('Check'),
                onPressed: _checkService,
              ),
            ),
            ElevatedButton(
              child: const Text('Request'),
              onPressed: _serviceEnabled == true ? null : _requestService,
            )
          ],
        )
      ],
    );
  }
}
