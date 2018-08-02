//
//  GeoPlace.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct GeoKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let name = "name"
    static let eventType = "eventTYpe"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

class GeoPlace: NSObject, NSCoding, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var name: String
    var eventType: EventType
    
    var title: String? {
        if name.isEmpty {
            return "No Note"
        }
        return name
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, name: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.name = name
        self.eventType = eventType
    }
    
//    static func decode(data: Data) -> GeoPlace {
//        //json a cevir.
//        return GeoPlace(coordinate: json["coordinate"].stringValue, radius: <#T##CLLocationDistance#>, identifier: <#T##String#>, name: <#T##String#>, eventType: <#T##EventType#>)
//    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
        let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: GeoKey.radius)
        identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
        name = decoder.decodeObject(forKey: GeoKey.name) as! String
        eventType = EventType(rawValue: decoder.decodeObject(forKey: GeoKey.eventType) as! String)!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
        coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
        coder.encode(radius, forKey: GeoKey.radius)
        coder.encode(identifier, forKey: GeoKey.identifier)
        coder.encode(name, forKey: GeoKey.name)
        coder.encode(eventType.rawValue, forKey: GeoKey.eventType)
    }
}

