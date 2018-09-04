//
//  CirclesViewModel.swift
//  Locco
//
//  Created by Alperen Özdemir on 19.07.2018.
//  Copyright © 2018 Alperen Özdemir. All rights reserved.
//

import Firebase
import Alamofire
import SwiftyJSON
import CoreLocation
import ReactiveSwift
import ReactiveCocoa

protocol CirclesViewModeling {
    var controller: UIViewController? { get set }
    //    var locationManager: CLLocationManager { get set }
    //    var circles: [Circle]  { get set }
    //    var peopleInCircle: [PeopleInCircle] { get set }
    
    func getCircles(completion: @escaping (_ result: Bool)->())
}

class CirclesViewModel: CirclesViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    
    // MARK: - Initialization
    init() {}
    
    func getCircles(completion: @escaping (Bool) -> ()) {
//        circles = []
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/getCircles", method: .get, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
                    if response.result.isSuccess {
//                        let placeJSON: JSON = JSON(response.result.value!)
//                        for (_, subJson) in placeJSON["data"] {
//                            let title = subJson["title"].string!
//                            let placeDetail = subJson["placeDetail"].string!
//                            let identifier = subJson["id"].string!
//                            let color = subJson["color"]
//                            var pinColor: PinColors
//
//                            if color.string! == PinColors.color1.rawValue {
//                                pinColor = PinColors.color1
//                            } else if color.string! == PinColors.color2.rawValue {
//                                pinColor = PinColors.color2
//                            } else if color.string! == PinColors.color3.rawValue {
//                                pinColor = PinColors.color3
//                            } else if color.string! == PinColors.color4.rawValue {
//                                pinColor = PinColors.color4
//                            } else if color.string! == PinColors.color5.rawValue {
//                                pinColor = PinColors.color5
//                            } else if color.string! == PinColors.color6.rawValue {
//                                pinColor = PinColors.color6
//                            } else if color.string! == PinColors.color7.rawValue {
//                                pinColor = PinColors.color7
//                            } else if color.string! == PinColors.color8.rawValue {
//                                pinColor = PinColors.color8
//                            } else if color.string! == PinColors.color9.rawValue {
//                                pinColor = PinColors.color9
//                            } else if color.string! == PinColors.color10.rawValue {
//                                pinColor = PinColors.color10
//                            } else {
//                                pinColor = PinColors.color2
//                            }
//
//                            let radius = subJson["radius"].double!
//                            let latitude = subJson["location"]["_latitude"].double!
//                            let longitude = subJson["location"]["_longitude"].double!
//                            let onEntry = subJson["onEntry"].bool!
//                            let onExit = subJson["onExit"].bool!
//
//                            self.geoPlaces.append(GeoPlace(title: title, placeDetail: placeDetail, identifier: identifier, pinColor: pinColor, radius: radius, coordinate: CLLocationCoordinate2DMake(latitude, longitude), onEntry: onEntry, onExit: onExit))
//                        }
//                        self.saveAllGeotifications()
                        completion(true)
                    } else {
                        completion(false)
                        print("Error: \(response.result.error ?? "" as! Error)")
                    }
            }
        }
    }
}
