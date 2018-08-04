//
//  PlacesController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler

class GeoPlacesController: UIViewController {
    
    var viewModel: GeoPlacesViewModeling?
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlsContainer: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.viewModel = GeoPlacesViewModel()
        self.viewModel!.controller = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlaces()
    }
    
    func setup() {
        loadPlaces()
        addPullUpController()
        customizeStatusBar()
        configureTileOverlay()
        mapView.layer.cornerRadius = 16.0
        controlsContainer.layer.cornerRadius = 10.0
        controlsContainer.clipsToBounds = true
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = CLLocationManager.authorizationStatus() == .authorizedAlways
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func addPullUpController() {
        guard
            let pullUpController = UIStoryboard(name: "Places", bundle: nil)
                .instantiateViewController(withIdentifier: "PlacesDrawerController") as? PlacesDrawerController
            else { return }
        print("1")
        addPullUpController(pullUpController, animated: true)
    }
    
    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: Functions that update the associated views with geotification changes
    func loadPlaces() {
        for place in viewModel!.geoPlaces {
            mapView.addAnnotation(place)
        }
    }
    
    func remove() {
        //        mapView.removeAnnotation(geotification)
        //        removeRadiusOverlay(forGeotification: geotification)
    }
    
    // MARK: Map overlay functions
    func configureTileOverlay() {
        // We first need to have the path of the overlay configuration JSON
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else {
            return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        // After that, you can create the tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
        
        // And finally add it to your MKMapView
        mapView.addOverlay(tileOverlay)
    }
    
    func addRadiusOverlay(forGeotification geotification: GeoPlace) {
        mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: GeoPlace) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    // MARK: Other mapView functions
    @IBAction func zoomToCurrentLocation(sender: UIButton) {
        mapView.zoomToUserLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlaceDetail" {
            let AddGeoPlaceController = segue.destination as! AddGeoPlaceController
            AddGeoPlaceController.viewModel = viewModel
        }
    }
}

extension GeoPlacesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 119.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - MapView Delegate
extension GeoPlacesController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "GeoPlaces"
        if annotation is MKUserLocation {
            let userPin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            userPin.isEnabled = false
            userPin.image = UIImage(named: "user_location_pin")
            return userPin
        }
        else if annotation is GeoPlace {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.image = UIImage(named: "Pin")!
                    .withRenderingMode(.alwaysTemplate)
                    .colorized(color: UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0))
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "cancel")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let overlayColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = overlayColor
            circleRenderer.fillColor = overlayColor.withAlphaComponent(0.4)
            return circleRenderer
        }
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } 
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let geotification = view.annotation as! GeoPlace
        addRadiusOverlay(forGeotification: geotification)
        
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let geotification = view.annotation as! GeoPlace
        removeRadiusOverlay(forGeotification: geotification)
        
    }
    
    // animate annotation views drop
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annView in views {
            
            // animate any annotation views except the user pin
            if !(annView.annotation?.isKind(of: MKUserLocation.self))! {
                let endFrame = annView.frame
                annView.frame = endFrame.offsetBy(dx: 0, dy: -500)
                UIView.animate(withDuration: 0.5, animations: {
                    annView.frame = endFrame
                })
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        //        let geotification = view.annotation as! GeoPlace
        //        remove(geotification: geotification)
        //        saveAllGeotifications()
    }
}
