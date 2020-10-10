import RealmSwift

class LocationData: Object, Encodable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var time: Date = Date()
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var speed: Double = 0.0
    @objc dynamic var speedAccuracy: Double = 0.0
    @objc dynamic var heading: Double = 0.0
    @objc dynamic var label: String = ""
    @objc dynamic var uploaded: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case time
        case latitude
        case longitude
        case accuracy
        case altitude
        case speed
        case speedAccuracy = "speed_accuracy"
        case heading
        case label
        case uploaded
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(1000.0 * time.timeIntervalSince1970, forKey: .time)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(speed, forKey: .speed)
        try container.encode(speedAccuracy, forKey: .speedAccuracy)
        try container.encode(heading, forKey: .heading)
        try container.encode(label, forKey: .label)
    }
}
