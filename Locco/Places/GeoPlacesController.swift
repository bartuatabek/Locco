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
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
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
    }
    
    func setup() {
        loadPlaces()
        configureTileOverlay()
        mapView.layer.cornerRadius = 16.0
        controlsContainer.layer.cornerRadius = 10.0
        controlsContainer.clipsToBounds = true
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = CLLocationManager.authorizationStatus() == .authorizedAlways
        
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        let addPinGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPlaceToTouchPosition))
        addPinGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(addPinGesture)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if (viewModel?.isEditing)! {
            viewModel?.isEditing = false
            
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            
            self.navigationItem.rightBarButtonItem?.title = ""
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "createNewPlace")
            self.navigationItem.rightBarButtonItem?.action = #selector(addPlaceToCurrentLocation)
            pullUpController?.pullUpControllerMoveToVisiblePoint(185, animated: true, completion: nil)
            
            if (viewModel?.isAddedNewPlace)! {
                viewModel?.activeGeoPlaceIndex = -1
                viewModel?.isAddedNewPlace = false
                mapView.removeAnnotation((viewModel?.geoPlaces.removeLast())!)
                
                for view in self.view.subviews {
                    if view.findViewController() is PlaceDetailDrawerController || view.findViewController() is AddGeoPlaceDrawerController {
                        removePullUpController(view.findViewController() as! PullUpController, animated: true)
                    }
                }
                return
            }
            
            let unmodifiedGeoPlace = (viewModel?.unmodifiedGeoPlace)!
            let activeGeoPlaceIndex = viewModel?.activeGeoPlaceIndex

            let currentGeoPlace = viewModel!.geoPlaces[(viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
            let annotationView = mapView.view(for: currentGeoPlace)
            annotationView?.image = UIImage(named: "Pin")!
                .tintedWithLinearGradientColors(colorsArr: unmodifiedGeoPlace.pinColor.colors)

            guard let overlays = mapView?.overlays else { return }
            for overlay in overlays {
                guard let circleOverlay = overlay as? MKCircle else { continue }
                mapView.removeOverlay(circleOverlay)
            }
            
            mapView?.addOverlay(MKCircle(center: (viewModel?.geoPlaces[activeGeoPlaceIndex!].coordinate)!, radius: unmodifiedGeoPlace.radius))
            viewModel?.geoPlaces[activeGeoPlaceIndex!].title = unmodifiedGeoPlace.title
            viewModel?.geoPlaces[activeGeoPlaceIndex!].placeDetail = unmodifiedGeoPlace.placeDetail
            viewModel?.geoPlaces[activeGeoPlaceIndex!].identifier = unmodifiedGeoPlace.identifier
            viewModel?.geoPlaces[activeGeoPlaceIndex!].pinColor = unmodifiedGeoPlace.pinColor
            viewModel?.geoPlaces[activeGeoPlaceIndex!].radius = unmodifiedGeoPlace.radius
            viewModel?.geoPlaces[activeGeoPlaceIndex!].coordinate = unmodifiedGeoPlace.coordinate
            viewModel?.unmodifiedGeoPlace = nil
            
            for view in self.view.subviews {
                if view.findViewController() is AddGeoPlaceDrawerController {
                    removePullUpController(view.findViewController() as! PullUpController, animated: true)
                }
            }
            addPlaceDetailDrawerPullUpController()
        }
    }
    
    @IBAction func addPlaceToCurrentLocation(_ sender: Any) {
        if !(viewModel?.isEditing)! {
            addPlace(coordinate: mapView.userLocation.coordinate)
        }
    }
        
    @objc func addPlaceToTouchPosition(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began && !(viewModel?.isEditing)! {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPlace(coordinate: coordinate)
        }
    }
    
    @objc func addPlacesDrawerPullUpController() {
        if pullUpController == nil {
            pullUpController = UIStoryboard(name: "Places", bundle: nil)
                .instantiateViewController(withIdentifier: "PlacesDrawerController") as? PlacesDrawerController
        }
        
        if (viewModel?.activeGeoPlaceIndex)! >= 0 && !(viewModel?.isEditing)! {
            let currentGeoPlace = viewModel!.geoPlaces[(viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
            let annotationView = (self.parent as? GeoPlacesController)?.mapView.view(for: currentGeoPlace)
            mapView.deselectAnnotation((mapView.annotations[(mapView.annotations as NSArray).index(of: currentGeoPlace)]), animated: true)
            annotationView?.isDraggable = false
        }
        
        viewModel?.isEditing = false
        viewModel?.activeGeoPlaceIndex = -1
        pullUpController?.viewModel = self.viewModel
        
        if pullUpController != nil {
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.navigationItem.leftBarButtonItem?.isEnabled = false

            self.navigationItem.rightBarButtonItem?.title = ""
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "createNewPlace")
            self.navigationItem.rightBarButtonItem?.action = #selector(addPlaceToCurrentLocation)
        }
        
        for view in self.view.subviews {
            if view.findViewController() is PlaceDetailDrawerController {
                removePullUpController(view.findViewController() as! PullUpController, animated: true)
            } else if view.findViewController() is AddGeoPlaceDrawerController {
                removePullUpController(view.findViewController() as! PullUpController, animated: true)
            }
        }
        
        addPullUpController(pullUpController!, animated: true)
        pullUpController?.pullUpControllerMoveToVisiblePoint(185, animated: true, completion: nil)
    }
    
    @objc func addPlaceDetailDrawerPullUpController() {        
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "createNewPlace")
        self.navigationItem.rightBarButtonItem?.action = #selector(addPlaceToCurrentLocation)
        
        for view in self.view.subviews {
            if view.findViewController() is AddGeoPlaceDrawerController {
                removePullUpController(view.findViewController() as! PullUpController, animated: true)
            } else if view.findViewController() is PlaceDetailDrawerController {
                (view.findViewController() as! PlaceDetailDrawerController).loadData()
                (view.findViewController() as! PlaceDetailDrawerController).pullUpControllerMoveToVisiblePoint(185, animated: true, completion: nil)
            }
        }
    }
    
    @objc func editPlaceDrawerPullUpController() {
        let addGeoPlacePullUpController = UIStoryboard(name: "Places", bundle: nil)
            .instantiateViewController(withIdentifier: "AddPlace") as? AddGeoPlaceDrawerController
        addGeoPlacePullUpController?.viewModel = self.viewModel
        
        if ((viewModel?.isAddedNewPlace)!) {
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.action = #selector(savePlace)
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Done"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.action = #selector(updatePlace)
        }
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        
        addPullUpController(addGeoPlacePullUpController!, animated: true)
        
        for view in self.view.subviews {
            if view.findViewController() is PlaceDetailDrawerController {
                (view.findViewController() as! PlaceDetailDrawerController).pullUpControllerMoveToVisiblePoint(0, animated: true, completion: nil)
            }
        }
    }
    
    @objc func savePlace() {
        viewModel?.isEditing = false
        viewModel?.isAddedNewPlace = false
        viewModel?.unmodifiedGeoPlace = nil
        viewModel?.add(geotification: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!])!)
        pullUpController?.refreshTableView()
        mapView.selectAnnotation((viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!])!, animated: true)
        addPlaceDetailDrawerPullUpController()
    }
    
    @objc func updatePlace() {
        viewModel?.isEditing = false
        viewModel?.unmodifiedGeoPlace = nil
        viewModel?.updatePlaceDetails(geotification: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!])!, completion: { (result) in })
        pullUpController?.refreshTableView()
        mapView.selectAnnotation((viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!])!, animated: true)
        self.addPlaceDetailDrawerPullUpController()
    }
    
    // MARK: Functions that update the associated views with geotification changes
    func addPlace(coordinate: CLLocationCoordinate2D) {
        let geotification = GeoPlace(title: "My Place", placeDetail: "Type something about this place", identifier: "", pinColor: PinColors.color2, radius: 100.0, coordinate: coordinate, onEntry: true, onExit: true)
        viewModel?.geoPlaces.append(geotification)
        let lastIndex = (viewModel?.geoPlaces.count)! - 1
        viewModel?.activeGeoPlaceIndex = lastIndex
        viewModel?.isEditing = true
        viewModel?.isAddedNewPlace = true
        
        var centerCoordinate = coordinate
        centerCoordinate.latitude -= (mapView.region.span.latitudeDelta) * 0.30
        mapView.setCenter(centerCoordinate, animated: true)
        mapView.addAnnotation(geotification)
        editPlaceDrawerPullUpController()
    }
    
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
        viewModel?.remove(geotification: geotification)
        mapView.removeAnnotation(geotification as MKAnnotation)
        removeRadiusOverlay(forGeotification: geotification)
        addPlacesDrawerPullUpController()
        pullUpController?.reloadData()
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
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MapView Delegate
extension GeoPlacesController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "GeoPlaces"
//        if annotation is MKUserLocation {
//            let userPin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            let userPinImage = UIImage(named: "CurrentLocationPin")!.overlayWith(image: UIImage(named: "bartu")!.resizeImageWith(newSize: CGSize(width: 39, height: 39)).maskRoundedImage(), posX: 6, posY: 4)
//            userPin.layer.zPosition = CGFloat(Int.max)
//            userPin.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
//            userPin.isEnabled = false
//            userPin.image = userPinImage
//            return userPin
//        }
        if let userLocation = annotation as? MKUserLocation {
            userLocation.title = ""
            return nil
        }
         if annotation is GeoPlace {
            let geotification = annotation as! GeoPlace
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.image = UIImage(named: "Pin")!
            .tintedWithLinearGradientColors(colorsArr: geotification.pinColor.colors)
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let overlayColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 4.0
            circleRenderer.strokeColor = overlayColor
            circleRenderer.fillColor = overlayColor.withAlphaComponent(0.2)
            return circleRenderer
        }
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } 
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !(viewModel?.isEditing)! && !(view.annotation is MKUserLocation) {
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
            addPullUpController(placeDetailDrawerController!, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if !(viewModel?.isEditing)! && !(view.annotation is MKUserLocation) {
            let geotification = view.annotation as! GeoPlace
            UIView.animate(withDuration: 0.25, animations: {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            removeRadiusOverlay(forGeotification: geotification)
            for view in self.view.subviews {
                if view.findViewController() is PlaceDetailDrawerController {
                    removePullUpController(view.findViewController() as! PullUpController, animated: true)
                    pullUpController?.pullUpControllerMoveToVisiblePoint(185, animated: true, completion: nil)
                }
            }
        }
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
    
    // drag annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        case .ending, .canceling:
            view.dragState = .none
            viewModel!.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate = (view.annotation?.coordinate)!
        default: break
        }
    }
}
