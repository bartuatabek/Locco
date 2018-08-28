//
//  PlaceDetailDrawerController.swift
//  Locco
//
//  Created by macmini-stajyer-2 on 15.08.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import PullUpController

class PlaceDetailDrawerController: PullUpController {

    var viewModel: GeoPlacesViewModeling?
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    @IBOutlet weak var pinIcon: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeDetailLabel: UILabel!
    @IBOutlet weak var placeImagesCollection: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinIcon.image = UIImage(named: "Pin")!
            .tintedWithLinearGradientColors(colorsArr: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor.colors)!)
        placeNameLabel.text = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].title
        placeDetailLabel.text = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].placeDetail
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func editPlace(_ sender: Any) {
        (parent as? GeoPlacesController)?.editPlaceDrawerPullUpController()
        
        let currentGeoPlace = self.viewModel!.geoPlaces[(self.viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
        var centerCoordinate = currentGeoPlace.coordinate
        centerCoordinate.latitude -= ((self.parent as? GeoPlacesController)?.mapView.region.span.latitudeDelta)! * 0.35
        (self.parent as? GeoPlacesController)?.mapView.setCenter(centerCoordinate, animated: true)
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 150
    }
}

extension PlaceDetailDrawerController: UICollectionViewDataSource {
    // TODO: Get photos from firebase
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.image = UIImage(named: "Fox")
        cell.imageView.layer.cornerRadius = 8.0
        cell.imageView.clipsToBounds = true
        return cell
    }

}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

