//
//  CirclesController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import PullUpController
import MapKitGoogleStyler

class CirclesController: UIViewController {
    
    var viewModel: CirclesViewModeling?
    var pullUpController: InviteDrawerController?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlsContainer: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.viewModel = CirclesViewModel()
        self.viewModel!.controller = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if pullUpController == nil {
            addInviteDrawerPullUpController()
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setup() {
        configureTileOverlay()
        mapView.layer.cornerRadius = 16.0
        controlsContainer.layer.cornerRadius = 10.0
        controlsContainer.clipsToBounds = true
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    @objc func addInviteDrawerPullUpController() {
        pullUpController = UIStoryboard(name: "Circles", bundle: nil)
            .instantiateViewController(withIdentifier: "InviteContact") as? InviteDrawerController
        
        pullUpController?.viewModel = self.viewModel
        
        for view in self.view.subviews {
            if view.findViewController() is PlaceDetailDrawerController {
                removePullUpController(view.findViewController() as! PullUpController, animated: true)
            }
        }
        
        addPullUpController(pullUpController!, animated: true)
        pullUpController?.pullUpControllerMoveToVisiblePoint(185, animated: true, completion: nil)
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
    
    // MARK: Other mapView functions
    @IBAction func zoomToCurrentLocation(sender: UIButton) {
        mapView.zoomToUserLocation()
    }
}

extension CirclesController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // This is the final step. This code can be copied and pasted into your project
        // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
        // for displaying the tile overlay.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
