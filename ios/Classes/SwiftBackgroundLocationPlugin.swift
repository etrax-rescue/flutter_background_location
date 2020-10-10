import Flutter
import UIKit
import CoreLocation
import RealmSwift
import Alamofire

public class SwiftBackgroundLocationPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    
    static var instance:SwiftBackgroundLocationPlugin?
    static let serialQueue = DispatchQueue(label: "at.etrax.background_location")
    static var updating:Bool = false
    static var flutterResult:FlutterResult?
    static var permissionsWanted:Bool = false

    var manager:CLLocationManager = CLLocationManager()
    var methodChannel:FlutterMethodChannel?
    var eventChannel:FlutterEventChannel?
    var locationDao:LocationDAO = LocationDAO()
    var locationUpdateDelegate:LocationUpdateDelegate?
    var label = ""
    var url = ""
    var headers: [String: String] = [:]
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        // Starting and configuring the location manager
        //manager = CLLocationManager()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = true
        
        let streamHandler = LocationStreamHandler()
        // Initializing the communication channels
        methodChannel = FlutterMethodChannel(name: "at.etrax.background_location/method", binaryMessenger: registrar.messenger())
        eventChannel = FlutterEventChannel(name: "at.etrax.background_location/event", binaryMessenger: registrar.messenger())
        
        locationUpdateDelegate = streamHandler
        eventChannel!.setStreamHandler(streamHandler)
        
        
        registrar.addMethodCallDelegate(self, channel: methodChannel!)
        registrar.addApplicationDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        serialQueue.sync {
            instance = instance ?? SwiftBackgroundLocationPlugin(registrar: registrar)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Convert the locations to location data
        let locationDataCollection: [LocationData] = locations.map {
            (item: CLLocation) -> LocationData in
            return Converter.locationToLocationData(location: item, label: label)
        }
        
        // Insert the location data into the database
        locationDao.bulkInsert(locations: locationDataCollection)
        
        // Update the location stream
        if let location = locationDataCollection.last {
            locationUpdateDelegate?.locationUpdated(location)
        }
        
        // If requested, send the data to the server
        if(url != "") {
            let session = Alamofire.Session.default
            session.cancelAllRequests() {
                print("cancelled")
            }
            
            if UIApplication.shared.applicationState == .background {
                backgroundUpdateTask = UIApplication.shared.beginBackgroundTask {[weak self] in
                    if let strongSelf = self {
                        UIApplication.shared.endBackgroundTask(strongSelf.backgroundUpdateTask)
                        strongSelf.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
                    }
                }
            }
            
            let stagedForUpload = self.locationDao.getLocationsForUpload(label: self.label)
            let uploadReferences = stagedForUpload.map{ location in ThreadSafeReference(to: location)
            }
            
            let encoder = JSONEncoder()
            let encoded: [[String: Any]] = stagedForUpload.map { location -> [String: Any] in
                let data = try! encoder.encode(location)
                return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                
            }
            
            let body = try! JSONSerialization.data(withJSONObject: encoded, options: [])
            
            var request = URLRequest(url: URL(string: self.url)!)
            request.httpMethod = "POST"
            
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            
            print("starting request")
            session.request(request).validate(statusCode: [201]).responseData {response in
                print("request done")
                switch (response.result) {
                case .success:
                    print("request successfull")
                    self.locationDao.locationsUploaded(locationReferences: uploadReferences)
                case let .failure(error):
                    print("request failure")
                    print(error)
                }
                if(self.backgroundUpdateTask != UIBackgroundTaskIdentifier.invalid) {
                    UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
                    self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        SwiftBackgroundLocationPlugin.serialQueue.sync {
            switch status {
            case .authorizedAlways:
                if(SwiftBackgroundLocationPlugin.permissionsWanted) {
                    SwiftBackgroundLocationPlugin.permissionsWanted = false
                    SwiftBackgroundLocationPlugin.flutterResult!(1)
                }
            default:
                if(SwiftBackgroundLocationPlugin.permissionsWanted) {
                    SwiftBackgroundLocationPlugin.permissionsWanted = false
                    SwiftBackgroundLocationPlugin.flutterResult!(0)
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation();
    }
    
    func requestPermission() {
        if (Bundle.main.infoDictionary?["NSLocationAlwaysUsageDescription"] != nil) {
            manager.requestAlwaysAuthorization()
        } else if (Bundle.main.infoDictionary?["NSLocationAlwaysAndWhenInUseUsageDescription"] != nil) {
            manager.requestAlwaysAuthorization()
        } else {
            print("To use this plugin you have to add either NSLocationAlwaysUsageDescription or NSLocationAlwaysAndWhenInUseUsageDescription to the Info.plist file.")
        }
    }
    
    func isPermissionGranted() -> Bool {
        let granted:Bool
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .restricted, .denied, .notDetermined, .authorizedWhenInUse:
            granted = false
        case .authorizedAlways:
            granted = true
        default:
            granted = false
        }
        return granted
    }
    
    func showLocationServiceAlert() {
        // TODO: localize the message!
        let controller = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController
        let alert = UIAlertController(title: "Location is Disabled", message: "To use location, go to your Settings App > Privacy > Location Services", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        controller.show(alert, sender: self)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "hasPermission":
            if (isPermissionGranted()){
                result(1)
            } else {
                result(0)
            }
        case "requestPermission":
            NSLog("requestPermission")
            if (isPermissionGranted()) {
                result(1)
            } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
                NSLog("notDetermined")
                SwiftBackgroundLocationPlugin.flutterResult = result
                SwiftBackgroundLocationPlugin.permissionsWanted = true
                requestPermission()
            } else {
                result(2)
            }
        case "serviceEnabled":
            if (CLLocationManager.locationServicesEnabled()) {
                result(1)
            } else {
                result(0)
            }
        case "requestService":
            if (CLLocationManager.locationServicesEnabled()) {
                result(1)
            } else {
                showLocationServiceAlert()
                result(0)
            }
        case "startUpdates":
            if(isPermissionGranted() && CLLocationManager.locationServicesEnabled()) {
                let accuracyDict: [Int: Double] = [0: kCLLocationAccuracyKilometer,
                                                   1: kCLLocationAccuracyHundredMeters,
                                                   2: kCLLocationAccuracyNearestTenMeters,
                                                   3: kCLLocationAccuracyBest,
                                                   4: kCLLocationAccuracyBestForNavigation]
                let args = call.arguments as! [String: Any]
                let accuracy = args["accuracy"] as! Int
                manager.desiredAccuracy = accuracyDict[accuracy] ?? kCLLocationAccuracyKilometer
                var distanceFilter = args["distanceFilter"] as! Double
                if (distanceFilter == 0) {
                    distanceFilter = kCLDistanceFilterNone
                }
                manager.distanceFilter = distanceFilter
                
                label = args["label"] as! String
                url = args["url"] as! String
                headers = args["header"] as! [String: String]
                
                manager.startUpdatingLocation()
                SwiftBackgroundLocationPlugin.serialQueue.sync {
                    SwiftBackgroundLocationPlugin.updating = true
                }
                result(1)
            } else {
                result(0)
            }
        case "stopUpdates":
            SwiftBackgroundLocationPlugin.serialQueue.sync {
                if(SwiftBackgroundLocationPlugin.updating) {
                    manager.stopUpdatingLocation()
                    SwiftBackgroundLocationPlugin.updating = false
                }
            }
            result(1)
        case "updatesActive":
            SwiftBackgroundLocationPlugin.serialQueue.sync {
                if(SwiftBackgroundLocationPlugin.updating) {
                    result(1)
                } else {
                    result(0)
                }
            }
        case "getLastLocation":
            let loc = locationDao.getLastLocation()
            if let location = loc {
                result(Converter.locationDataToMap(locationData: location))
            } else {
                result([])
            }
        case "getLocations":
            let args = call.arguments as! [String: Any]
            let labels = args["labels"] as! [String]
            let n = args["n"] as! Int
            var locations: [LocationData] = []
            if(n < 0) {
                locations = locationDao.getLocations(labels: labels)
            } else {
                locations = locationDao.getNLocations(labels: labels, n: n)
            }
            let locationMaps = locations.map {
                Converter.locationDataToMap(locationData: $0)
            }
            result(locationMaps)
        case "deleteLocations":
            let args = call.arguments as! [String: Any]
            let labels = args["labels"] as! [String]
            locationDao.deleteLocations(labels: labels)
            result(1)
        case "clearCache":
            locationDao.deleteAll()
            result(1)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
