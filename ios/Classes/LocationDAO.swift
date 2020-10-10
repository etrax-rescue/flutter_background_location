import Foundation
import RealmSwift

public class LocationDAO {
    var realm: Realm?
    init() {
        realm = try! Realm()
    }
    
    func updateLocations(locationReferences: [ThreadSafeReference<LocationData>]) {
        autoreleasepool {
            do {
                let localRealm = try Realm()
                for reference in locationReferences {
                    guard let location = localRealm.resolve(reference) else {
                        continue
                    }
                    try localRealm.write {
                        localRealm.add(location, update: .modified)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func locationsUploaded(locationReferences: [ThreadSafeReference<LocationData>]) {
        autoreleasepool {
            do {
                let localRealm = try Realm()
                for reference in locationReferences {
                    guard let location = localRealm.resolve(reference) else {
                        continue
                    }
                    try localRealm.write {
                        location.uploaded = 1
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAll() {
        autoreleasepool {
            do {
                try realm!.write {
                    realm!.deleteAll()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteLocations(labels: [String]) {
        autoreleasepool {
            do {
                try realm!.write {
                    let predicate = NSPredicate(format: "label IN %@", labels)
                    let result = realm!.objects(LocationData.self).filter(predicate)
                    realm!.delete(result)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func bulkInsert(locations: [LocationData]) {
        autoreleasepool {
            do {
                try realm!.write {
                    realm!.add(locations)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func getLocations(labels: [String]) -> [LocationData] {
        let predicate = NSPredicate(format: "label IN %@", labels)
        return autoreleasepool {
            () -> [LocationData] in
            let locations = realm!.objects(LocationData.self).filter(predicate).sorted(byKeyPath: "time", ascending: true)
            return Array(locations)
        }
    }
    
    func getLastLocation() -> LocationData? {
        return autoreleasepool {
            () -> LocationData? in
            let result = realm!.objects(LocationData.self).sorted(byKeyPath: "time", ascending: true)
            return result.last
        }
    }
    
    func getLocationsForUpload(label: String) -> [LocationData] {
        let predicate = NSPredicate(format: "label == %@ AND uploaded == 0", label)
        return autoreleasepool {
            () -> [LocationData] in
            let locations = realm!.objects(LocationData.self).filter(predicate).sorted(byKeyPath: "time", ascending: true)
            return Array(locations)
        }
    }
    
    func getNLocations(labels: [String], n: Int) -> [LocationData] {
        let predicate = NSPredicate(format: "label IN %@", labels)
        return autoreleasepool {
            () -> [LocationData] in
            let result = realm!.objects(LocationData.self).filter(predicate).sorted(byKeyPath: "time", ascending: true)
            
            var locations: [LocationData] = []
            for (i, location) in result.enumerated() {
                if(i > n) {
                    break
                }
                locations.append(location)
            }
            return locations
        }
    }
}
