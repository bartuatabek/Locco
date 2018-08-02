//
//  PlacesController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import Pulley

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
        customizeStatusBar()
        controlsContainer.layer.cornerRadius = 10.0
        controlsContainer.clipsToBounds = true
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = CLLocationManager.authorizationStatus() == .authorizedAlways
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
    @IBAction func goToConfirmPlace(sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Places", bundle: nil)
        let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "ConfirmPlace") as! UINavigationController
        let AddGeoPlaceController = navigationController.viewControllers.first as! AddGeoPlaceController
        AddGeoPlaceController.viewModel = viewModel
        present(navigationController, animated: true, completion: nil)
        
        //        let primaryContent = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "ConfirmPlace")
        //        pulleyViewController?.setPrimaryContentViewController(controller: primaryContent, animated: false)
    }
    
    @IBAction func zoomToCurrentLocation(sender: UIButton) {
        mapView.zoomToUserLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlaceDetail" {
            let navigationController = segue.destination as! UINavigationController
            let AddGeoPlaceController = navigationController.viewControllers.first as! AddGeoPlaceController
            AddGeoPlaceController.viewModel = viewModel
        }
    }
}

extension GeoPlacesController: AddGeoPlaceControllerDelegate {
    func passViewModel(viewModel: GeoPlacesViewModeling) {
        self.viewModel = viewModel
        self.viewModel!.controller = self
    }
}

// MARK: - Pulley Delegate
extension GeoPlacesController: PulleyPrimaryContentControllerDelegate {
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        guard let drawer = self.pulleyViewController, drawer.currentDisplayMode == .bottomDrawer else {
            controlsContainer.alpha = 1.0
            return
        }
        controlsContainer.alpha = 1.0 - progress
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
                annotationView?.image = UIImage(named: "AddPin")
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
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let geotification = view.annotation as! GeoPlace
        addRadiusOverlay(forGeotification: geotification)
        
        let primaryContent = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlaceDetail")
        
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
        pulleyViewController?.setDrawerContentViewController(controller: primaryContent, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let geotification = view.annotation as! GeoPlace
        removeRadiusOverlay(forGeotification: geotification)
        
        let primaryContent = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesDrawerController")
        
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        pulleyViewController?.setDrawerContentViewController(controller: primaryContent, animated: false)
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
