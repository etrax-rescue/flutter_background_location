import CoreLocation

class Converter {
    static func locationToLocationData(location: CLLocation, label: String) -> LocationData {
        let locationData = LocationData()
        locationData.latitude = location.coordinate.latitude
        locationData.longitude = location.coordinate.longitude
        locationData.altitude = location.altitude
        locationData.accuracy = location.horizontalAccuracy
        locationData.time = location.timestamp
        locationData.speed = location.speed
        // I honestly don't know what's wrong with the following line, but I always get the following compiler error message:
        // error: value of type 'CLLocation' has no member 'speedAccuracy'
        //locationData.speedAccuracy = location.speedAccuracy
        locationData.speedAccuracy = -1.0
        locationData.heading = location.course
        locationData.label = label
        return locationData
    }
    
    static func locationDataToMap(locationData: LocationData) -> [String: Any] {
        var locationMap: [String: Any] = [:]
        locationMap["latitude"] = locationData.latitude
        locationMap["longitude"] = locationData.longitude
        locationMap["accuracy"] = locationData.accuracy
        locationMap["altitude"] = locationData.altitude
        locationMap["speed"] = locationData.speed
        locationMap["speed_accuracy"] = locationData.speedAccuracy
        locationMap["heading"] = locationData.heading
        locationMap["time"] = locationData.time.timeIntervalSince1970 * 1000.0
        locationMap["label"] = locationData.label
        return locationMap
    }
    
    static func locationDataToMutableDict(locationData: LocationData) -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict.setValue(locationData.latitude, forKey: "latitude")
        dict.setValue(locationData.longitude, forKey: "longitude")
        dict.setValue(locationData.accuracy, forKey: "accuracy")
        dict.setValue(locationData.altitude, forKey: "altitude")
        dict.setValue(locationData.speed, forKey: "speed")
        dict.setValue(locationData.speedAccuracy, forKey: "speed_accuracy")
        dict.setValue(locationData.heading, forKey: "heading")
        dict.setValue(locationData.time.timeIntervalSince1970 * 1000.0, forKey: "time")
        dict.setValue(locationData.label, forKey: "label")
        return dict
    }
}
