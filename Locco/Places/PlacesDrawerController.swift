//
//  SearchViewController.swift
//  PullUpControllerDemo
//
//  Created by Mario on 03/11/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit
import MapKit
import PullUpController

class PlacesDrawerController: PullUpController {
    
    var viewModel: GeoPlacesViewModeling?
    var filteredData = [GeoPlace]()
    var isSearching = false
    
    // MARK: - IBOutlets
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchBoxContainerView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.attach(to: self)
        willMoveToStickyPoint = { point in
            self.view.endEditing(true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 16
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 700)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return searchBoxContainerView.frame.height
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        if UIDevice.modelName == "iPhone SE" {
            return [185, 470]
        } else if UIDevice.modelName == "iPhone X" {
            return [185, 660]
        } else if UIDevice.modelName == "iPhone 8 Plus" {
            return [185, 640]
        } else {
            return [185, 570]
        }
    }
}

// MARK: - UISearchBarDelegate
extension PlacesDrawerController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let lastStickyPoint = pullUpControllerAllStickyPoints.last {
            pullUpControllerMoveToVisiblePoint(lastStickyPoint, animated: true, completion: nil)
        }
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = (viewModel?.geoPlaces.filter({(place : GeoPlace) -> Bool in
                return place.name.lowercased().contains(searchText.lowercased())
            }))!
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let middleStickyPoint = pullUpControllerAllStickyPoints[1]
        pullUpControllerMoveToVisiblePoint(middleStickyPoint, animated: true, completion: nil)
        isSearching = false
        searchBar.text = ""
        tableView.reloadData()
        view.endEditing(true)
    }
}

extension PlacesDrawerController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        
        return (viewModel?.geoPlaces.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell
            else {return UITableViewCell()}
        
        if isSearching {
            cell.configure(pinColor: filteredData[indexPath.row].pinColor.colors, title: filteredData[indexPath.row].name, subtitle: filteredData[indexPath.row].placeDetail)
        } else {
            cell.configure(pinColor: (viewModel?.geoPlaces[indexPath.row].pinColor.colors)!, title: (viewModel?.geoPlaces[indexPath.row].name)!, subtitle: (viewModel?.geoPlaces[indexPath.row].placeDetail)!)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        
        (parent as? GeoPlacesController)?.zoom(to: viewModel!.geoPlaces[indexPath.row].coordinate)
    }
}

// MARK: - PlaceCell
class PlaceCell: UITableViewCell {
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(pinColor: [CGColor], title: String, subtitle: String) {
        pinImage.image = pinImage.image?.tintedWithLinearGradientColors(colorsArr: pinColor)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
//
//extension PlaceCell: UICollectionViewDataSource {
//    // TODO: Get photos from firebase
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 12
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
//        cell.imageView.image = UIImage(named: "Fox")
//        cell.imageView.layer.cornerRadius = 8.0
//        cell.imageView.clipsToBounds = true
//        return cell
//    }
//    
//}
//
//class PhotoCell: UICollectionViewCell {
//    @IBOutlet weak var imageView: UIImageView!
//}
