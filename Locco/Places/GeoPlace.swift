//
//  GeoPlace.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct GeoKey {
    static let name = "name"
    static let placeDetail = "placeDetail"
    static let identifier = "identifier"
    static let pinColor = "pinColor"
    static let radius = "radius"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let onEntry = "onEntry"
    static let onExit = "onExit"
}

class GeoPlace: NSObject, NSCoding, MKAnnotation {

    var name: String
    var placeDetail: String
    var identifier: String
    var pinColor: PinColors
    var radius: CLLocationDistance
    var coordinate: CLLocationCoordinate2D
    var onEntry: Bool
    var onExit: Bool
    
    init(name: String, placeDetail: String, identifier: String, pinColor: PinColors, radius: CLLocationDistance, coordinate: CLLocationCoordinate2D, onEntry: Bool, onExit: Bool) {
        self.name = name
        self.placeDetail = placeDetail
        self.identifier = identifier
        self.pinColor = pinColor
        self.radius = radius
        self.coordinate = coordinate
        self.onEntry = onEntry
        self.onExit = onExit
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        name = decoder.decodeObject(forKey: GeoKey.name) as! String
        placeDetail = decoder.decodeObject(forKey: GeoKey.placeDetail) as! String
        identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
        pinColor = decoder.decodeObject(forKey: GeoKey.pinColor) as! PinColors
        radius = decoder.decodeDouble(forKey: GeoKey.radius)
        let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
        let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        onEntry = decoder.decodeObject(forKey: GeoKey.onEntry) as! Bool
        onExit = decoder.decodeObject(forKey: GeoKey.onExit) as! Bool
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: GeoKey.name)
        coder.encode(placeDetail, forKey: GeoKey.placeDetail)
        coder.encode(identifier, forKey: GeoKey.identifier)
        coder.encode(pinColor, forKey: GeoKey.pinColor)
        coder.encode(radius, forKey: GeoKey.radius)
        coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
        coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
        coder.encode(onEntry, forKey: GeoKey.onEntry)
        coder.encode(onExit, forKey: GeoKey.onExit)
    }
    
    // TODO: JSON Decoding
    //    static func decode(data: Data) -> GeoPlace {
    //        //json a cevir.
    //        return GeoPlace(coordinate: json["coordinate"].stringValue, radius: <#T##CLLocationDistance#>, identifier: <#T##String#>, name: <#T##String#>, eventType: <#T##EventType#>)
    //    }
}

