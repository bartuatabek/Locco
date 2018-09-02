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
    static let title = "title"
    static let placeDetail = "placeDetail"
    static let identifier = "identifier"
    static let pinColor = "pinColor"
    static let radius = "radius"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let onEntry = "onEntry"
    static let onExit = "onExit"
}

class GeoPlace: NSObject, NSCoding, NSCopying, MKAnnotation {

    var title: String?
    var placeDetail: String
    var identifier: String
    var pinColor: PinColors
    var radius: CLLocationDistance
    var coordinate: CLLocationCoordinate2D
    var onEntry: Bool
    var onExit: Bool
    
    init(title: String, placeDetail: String, identifier: String, pinColor: PinColors, radius: CLLocationDistance, coordinate: CLLocationCoordinate2D, onEntry: Bool, onExit: Bool) {
        self.title = title
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
        title = decoder.decodeObject(forKey: GeoKey.title) as! String?
        placeDetail = decoder.decodeObject(forKey: GeoKey.placeDetail) as! String
        identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
        let color = decoder.decodeObject(forKey: GeoKey.pinColor) as! String
        
        if color == PinColors.color1.rawValue {
            pinColor = PinColors.color1
        } else if color == PinColors.color2.rawValue {
            pinColor = PinColors.color2
        } else if color == PinColors.color3.rawValue {
            pinColor = PinColors.color3
        } else if color == PinColors.color4.rawValue {
            pinColor = PinColors.color4
        } else if color == PinColors.color5.rawValue {
            pinColor = PinColors.color5
        } else if color == PinColors.color6.rawValue {
            pinColor = PinColors.color6
        } else if color == PinColors.color7.rawValue {
            pinColor = PinColors.color7
        } else if color == PinColors.color8.rawValue {
            pinColor = PinColors.color8
        } else if color == PinColors.color9.rawValue {
            pinColor = PinColors.color9
        } else if color == PinColors.color10.rawValue {
            pinColor = PinColors.color10
        } else {
            pinColor = PinColors.color3
        }
        
        radius = decoder.decodeDouble(forKey: GeoKey.radius)
        let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
        let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        onEntry = decoder.decodeBool(forKey: GeoKey.onEntry)
        onExit = decoder.decodeBool(forKey: GeoKey.onExit)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: GeoKey.title)
        coder.encode(placeDetail, forKey: GeoKey.placeDetail)
        coder.encode(identifier, forKey: GeoKey.identifier)
        coder.encode(pinColor.rawValue, forKey: GeoKey.pinColor)
        coder.encode(radius, forKey: GeoKey.radius)
        coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
        coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
        coder.encode(onEntry, forKey: GeoKey.onEntry)
        coder.encode(onExit, forKey: GeoKey.onExit)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = GeoPlace(title: title!, placeDetail: placeDetail, identifier: identifier, pinColor: pinColor, radius: radius, coordinate: coordinate, onEntry: onEntry, onExit: onExit)
        return copy
    }
}

