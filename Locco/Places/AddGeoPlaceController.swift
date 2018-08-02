//
//  AddGeoPlaceController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 19.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Firebase

protocol AddGeoPlaceControllerDelegate {
    func passViewModel(viewModel: GeoPlacesViewModeling)
}

class AddGeoPlaceController: UITableViewController, UIGestureRecognizerDelegate {
    
    var viewModel: GeoPlacesViewModeling?
    var delegate: AddGeoPlaceControllerDelegate?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var zoomButton: UIBarButtonItem!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radius: UISlider!
    @IBOutlet weak var mapCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.zoomToUserLocation()
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(gestureRecognizer:)))
        mapDragRecognizer.delegate = self
        self.mapView.addGestureRecognizer(mapDragRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//         self.viewModel!.controller = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizer.State.changed) {
            let overlays = mapView.overlays
            for overlay in overlays {
                guard let circleOverlay = overlay as? MKCircle else { continue }
                mapView.removeOverlay(circleOverlay)
            }
            mapView.addOverlay(MKCircle(center: mapView.centerCoordinate, radius: 250))
        }
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        addButton.isEnabled = !nameTextField.text!.isEmpty
    }
    
    @IBAction func sliderEditingChanged(_ sender: UISlider) {
        radiusLabel.text = " \(Int(sender.value)) ft zone"
        
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            mapView?.removeOverlay(circleOverlay)
        }
        mapView?.addOverlay(MKCircle(center: mapView.centerCoordinate, radius: Double(sender.value)))
    }
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        delegate?.passViewModel(viewModel: self.viewModel!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(self.radius.value.rounded())
        let clampedRadius = min(radius, viewModel!.locationManager.maximumRegionMonitoringDistance)
        let identifier = NSUUID().uuidString
        let name = nameTextField.text
        let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        let geotification = GeoPlace(coordinate: coordinate, radius: clampedRadius, identifier: identifier, name: name!, eventType: eventType)
        
        viewModel!.add(geotification: geotification)
        viewModel!.startMonitoring(geotification: geotification)
        viewModel!.saveAllGeotifications()
        dismiss(animated: true, completion: nil)
        
        // server request
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude,
                "radius": radius,
                "identifier": identifier,
                "name": name ?? "",
                "eventType": eventType.rawValue
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/addPlace", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
            }
        }
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
}

extension AddGeoPlaceController: MKMapViewDelegate {
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
}
