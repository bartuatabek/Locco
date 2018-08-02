//
//  PlacesViewModel.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import CoreLocation
import ReactiveSwift
import ReactiveCocoa

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

protocol GeoPlacesViewModeling {
    var controller: UIViewController? { get set }
    var locationManager: CLLocationManager { get set }
    var geoPlaces: [GeoPlace]  { get set }
    
    func loadAllGeotifications()
    func saveAllGeotifications()
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
    
    // MARK: - Initialization
    override init() {
        geoPlaces = []
        locationManager = CLLocationManager()
        super.init()
        loadAllGeotifications()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geoPlaces = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? GeoPlace else { continue }
            add(geotification: geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geoPlaces {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: GeoPlace) {
        geoPlaces.append(geotification)
    }
    
    func remove(geotification: GeoPlace) {
        if let indexInArray = geoPlaces.index(of: geotification) {
            geoPlaces.remove(at: indexInArray)
        }
    }
    
    // MARK: CoreLocation tracking functions
    func region(withGeotification geotification: GeoPlace) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: GeoPlace) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your place is saved but will only be activated once you grant Location Tracker permission to access the device location.")
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

