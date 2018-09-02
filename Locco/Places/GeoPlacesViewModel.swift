//
//  PlacesViewModel.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Firebase
import Alamofire
import SwiftyJSON
import CoreLocation
import ReactiveSwift
import ReactiveCocoa
import FirebaseStorage

struct PreferencesKeys {
    static let savedPlaces = "\(Firebase.Auth.auth().currentUser?.uid ?? "unauthorized")-savedPlaces"
    static let savedChatPreviews = "\(Firebase.Auth.auth().currentUser?.uid ?? "unauthorized")-savedChatPreviews"
}

protocol GeoPlacesViewModeling {
    var controller: UIViewController? { get set }
    var locationManager: CLLocationManager { get set }
    var geoPlaces: [GeoPlace]  { get set }
    var unmodifiedGeoPlace: GeoPlace? { get set }
    var activeGeoPlaceIndex: Int { get set }
    var isAddedNewPlace: Bool { get set }
    var isEditing: Bool { get set }
    
    func loadAllGeotifications()
    func saveAllGeotifications()
    func getPeopleInPlace(geotification: GeoPlace, completion: @escaping (_ result: Bool)->())
    func updateAllGeotifications(completion: @escaping (_ result: Bool)->())
    func updatePlaceDetails(geotification: GeoPlace, completion: @escaping (_ result: Bool) ->())
    func add(geotification: GeoPlace)
    func remove(geotification: GeoPlace)
    func region(withGeotification geotification: GeoPlace) -> CLCircularRegion
    func startMonitoring(geotification: GeoPlace)
    func stopMonitoring(geotification: GeoPlace)
}

class GeoPlacesViewModel: NSObject, GeoPlacesViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    var locationManager: CLLocationManager
    var geoPlaces: [GeoPlace]
    var unmodifiedGeoPlace: GeoPlace?
    var activeGeoPlaceIndex: Int
    var isAddedNewPlace: Bool
    var isEditing: Bool
    
    // MARK: - Initialization
    override init() {
        geoPlaces = []
        isEditing = false
        isAddedNewPlace = false
        activeGeoPlaceIndex = -1
        unmodifiedGeoPlace = nil
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geoPlaces = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedPlaces) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? GeoPlace else { continue }
            geoPlaces.append(geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geoPlaces {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedPlaces)
    }
    
    func getPeopleInPlace(geotification: GeoPlace, completion: @escaping (Bool) -> ()) {
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "placeId": geotification.identifier,
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/getPeopleInPlace", method: .get, parameters: parameters, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
            }
        }
    }
    
    func updateAllGeotifications(completion: @escaping (_ result: Bool)->()) {
        geoPlaces = []
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/getPlaces", method: .get, headers: headers)
                .responseJSON { response in
                    if response.result.isSuccess {
                        let placeJSON: JSON = JSON(response.result.value!)
                        for (_, subJson) in placeJSON["data"] {
                            let title = subJson["title"].string!
                            let placeDetail = subJson["placeDetail"].string!
                            let identifier = subJson["id"].string!
                            let color = subJson["color"]
                            var pinColor: PinColors
                            
                            if color.string! == PinColors.color1.rawValue {
                                pinColor = PinColors.color1
                            } else if color.string! == PinColors.color2.rawValue {
                                pinColor = PinColors.color2
                            } else if color.string! == PinColors.color3.rawValue {
                                pinColor = PinColors.color3
                            } else if color.string! == PinColors.color4.rawValue {
                                pinColor = PinColors.color4
                            } else if color.string! == PinColors.color5.rawValue {
                                pinColor = PinColors.color5
                            } else if color.string! == PinColors.color6.rawValue {
                                pinColor = PinColors.color6
                            } else if color.string! == PinColors.color7.rawValue {
                                pinColor = PinColors.color7
                            } else if color.string! == PinColors.color8.rawValue {
                                pinColor = PinColors.color8
                            } else if color.string! == PinColors.color9.rawValue {
                                pinColor = PinColors.color9
                            } else if color.string! == PinColors.color10.rawValue {
                                pinColor = PinColors.color10
                            } else {
                                pinColor = PinColors.color2
                            }
                            
                            let radius = subJson["radius"].double!
                            let latitude = subJson["location"]["_latitude"].double!
                            let longitude = subJson["location"]["_longitude"].double!
                            let onEntry = subJson["onEntry"].bool!
                            let onExit = subJson["onExit"].bool!
                            
                            self.geoPlaces.append(GeoPlace(title: title, placeDetail: placeDetail, identifier: identifier, pinColor: pinColor, radius: radius, coordinate: CLLocationCoordinate2DMake(latitude, longitude), onEntry: onEntry, onExit: onExit))
                        }
                        self.saveAllGeotifications()
                        completion(true)
                    } else {
                        completion(false)
                        print("Error: \(response.result.error ?? "" as! Error)")
                    }
            }
        }
    }
    
    func updatePlaceDetails(geotification: GeoPlace, completion: @escaping (Bool) -> ()) {
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "placeId": geotification.identifier,
                "title": geotification.title!,
                "placeDetail": geotification.placeDetail,
                "color": geotification.pinColor.rawValue,
                "radius": geotification.radius,
                "latitude": geotification.coordinate.latitude,
                "longitude": geotification.coordinate.longitude,
                "onEntry": geotification.onEntry,
                "onExit": geotification.onExit
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updatePlace", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    if response.result.isSuccess {
                        completion(true)
                    } else {
                        completion(false)
                        print("Error: \(response.result.error ?? "" as! Error)")
                    }
            }
        }
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: GeoPlace) {
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "title": geotification.title!,
                "placeDetail": geotification.placeDetail,
                "color": geotification.pinColor.rawValue,
                "radius": geotification.radius,
                "latitude": geotification.coordinate.latitude,
                "longitude": geotification.coordinate.longitude,
                "onEntry": geotification.onEntry,
                "onExit": geotification.onExit
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/addPlace", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let placeId = json["placeId"].rawString()
                        
                        geotification.identifier = placeId!
                        self.geoPlaces.append(geotification)
                        self.startMonitoring(geotification: geotification)
                        self.saveAllGeotifications()
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    func remove(geotification: GeoPlace) {
        if let indexInArray = geoPlaces.index(of: geotification) {
            geoPlaces.remove(at: indexInArray)
        }
        
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "placeId": geotification.identifier,
                ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/deletePlace", method: .get, parameters: parameters, headers: headers)
                .responseJSON { response in
            }
        }
    }
    
    // MARK: CoreLocation tracking functions
    func region(withGeotification geotification: GeoPlace) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = geotification.onEntry
        region.notifyOnExit = geotification.onExit
        return region
    }
    
    func startMonitoring(geotification: GeoPlace) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your place is saved but will only be activated once you grant Locco permission to access the device location.")
        }
        let region = self.region(withGeotification: geotification)
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(geotification: GeoPlace) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

// MARK: - Location Manager Delegate
extension GeoPlacesViewModel: CLLocationManagerDelegate {    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }    
}
