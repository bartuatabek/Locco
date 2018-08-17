//
//  PlacesController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import ReactiveCocoa
import ReactiveSwift
import PullUpController
import MapKitGoogleStyler

class GeoPlacesController: UIViewController {
    
    var viewModel: GeoPlacesViewModeling?
    var pullUpController: PlacesDrawerController?
    
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
        if pullUpController == nil {
            addPlacesDrawerPullUpController()
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "createNewPlace"), style: .done, target: self, action: #selector(editPlaceDrawerPullUpController))
        rightBarButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for view in self.view.subviews {
            if view != mapView && view != controlsContainer && view != pullUpController?.view {
                view.removeFromSuperview()
            }
        }
    }
    
    func setup() {
        loadPlaces()
//        configureTileOverlay()
        mapView.layer.cornerRadius = 16.0
        controlsContainer.layer.cornerRadius = 10.0
        controlsContainer.clipsToBounds = true
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = CLLocationManager.authorizationStatus() == .authorizedAlways
        
        let addPinGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPlace))
        addPinGesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(addPinGesture)
    }
    
    @objc func addPlace(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let geotification = GeoPlace(name: "My Place", placeDetail: "Type something about this place", identifier: "", pinColor: PinColors.color2, radius: 100.0, coordinate: coordinate, onEntry: true, onExit: false)
            viewModel?.geoPlaces.append(geotification)
            let lastIndex = (viewModel?.geoPlaces.count)! - 1
            viewModel?.activeGeoPlaceIndex = lastIndex
            
            mapView.addAnnotation(geotification)
            editPlaceDrawerPullUpController()
        }
    }
    
    @objc func addPlacesDrawerPullUpController() {
        pullUpController = UIStoryboard(name: "Places", bundle: nil)
            .instantiateViewController(withIdentifier: "PlacesDrawerController") as? PlacesDrawerController
        viewModel?.activeGeoPlaceIndex = -1
        pullUpController?.viewModel = self.viewModel
        
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "createNewPlace")
        self.navigationItem.rightBarButtonItem?.action = #selector(editPlaceDrawerPullUpController)
        
        for children in self.children {
            if let pullUpChildren = children as? AddGeoPlaceDrawerController {
                removePullUpController(pullUpChildren, animated: true)
            }
            if let pullUpChildren = children as? PlaceDetailDrawerController {
                removePullUpController(pullUpChildren, animated: true)
            }
        }
        
        addPullUpController(pullUpController!, animated: true)
    }
    
    @objc func editPlaceDrawerPullUpController() {
        let addGeoPlacePullUpController = UIStoryboard(name: "Places", bundle: nil)
            .instantiateViewController(withIdentifier: "AddPlace") as? AddGeoPlaceDrawerController
        addGeoPlacePullUpController?.viewModel = self.viewModel
        
        self.navigationItem.rightBarButtonItem?.title = "Done"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        self.navigationItem.rightBarButtonItem?.image = nil
        self.navigationItem.rightBarButtonItem?.action = #selector(addPlacesDrawerPullUpController)
        
        for view in self.view.subviews {
            if view != mapView && view != controlsContainer {
                view.removeFromSuperview()
            }
        }
        
        addPullUpController(addGeoPlacePullUpController!, animated: true)
    }
    
    // MARK: Functions that update the associated views with geotification changes
    func loadPlaces() {
        viewModel!.updateAllGeotifications(completion: { (result) in
            if result {
                self.pullUpController?.refreshTableView()
                for place in self.viewModel!.geoPlaces {
                    self.mapView.addAnnotation(place)
                }
            }
        })
    }
    
    func remove(geotification: GeoPlace) {
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
    }
    
    // MARK: Map overlay functions
    func configureTileOverlay() {
        guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else {
            return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
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
    
    func zoom(to location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MapView Delegate
extension GeoPlacesController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "GeoPlaces"
        if annotation is MKUserLocation {
            let userPin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            let userPinImage = UIImage(named: "CurrentLocationPin")!.overlayWith(image: UIImage(named: "bartu")!.resizeImageWith(newSize: CGSize(width: 39, height: 39)).maskRoundedImage(), posX: 6, posY: 4)
            userPin.isEnabled = false
            userPin.image = userPinImage
            return userPin
        }
        else if annotation is GeoPlace {
            let geotification = annotation as! GeoPlace
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.image = UIImage(named: "Pin")!
                    .tintedWithLinearGradientColors(colorsArr: geotification.pinColor.colors)
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
        UIView.animate(withDuration: 0.25, animations: {
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
        addRadiusOverlay(forGeotification: geotification)
        
        let currentIndex = viewModel?.geoPlaces.index(of: geotification)
        viewModel?.activeGeoPlaceIndex = currentIndex!
        
        let placeDetailDrawerController = UIStoryboard(name: "Places", bundle: nil)
            .instantiateViewController(withIdentifier: "PlaceDetail") as? PlaceDetailDrawerController
        placeDetailDrawerController?.viewModel = self.viewModel
        
        removePullUpController(pullUpController!, animated: true)
        pullUpController = nil
        addPullUpController(placeDetailDrawerController!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let geotification = view.annotation as! GeoPlace
        UIView.animate(withDuration: 0.25, animations: {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        removeRadiusOverlay(forGeotification: geotification)
        addPlacesDrawerPullUpController()
    }
    
    // animate annotation views drop
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annView in views {
            // animate any annotation views except the user pin
            if !(annView.annotation?.isKind(of: MKUserLocation.self))! {
                let endFrame = annView.frame
                annView.frame = endFrame.offsetBy(dx: 0, dy: -500)
                UIView.animate(withDuration: 0.25, animations: {
                    annView.frame = endFrame
                })
            }
        }
    }
}
