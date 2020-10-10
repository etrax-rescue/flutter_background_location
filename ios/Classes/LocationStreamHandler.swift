import Flutter

class LocationStreamHandler: NSObject, FlutterStreamHandler, LocationUpdateDelegate {
    private var _eventSink: FlutterEventSink?
    private var locationDao = LocationDAO()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        let loc = locationDao.getLastLocation()
        
        if let location = loc {
            _eventSink?(Converter.locationDataToMap(locationData: location))
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    func locationUpdated(_ location: LocationData) {
        let locationMap = Converter.locationDataToMap(locationData: location)
        _eventSink?(locationMap)
    }
}
