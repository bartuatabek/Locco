//
//  ProfileViewModel.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa

protocol ProfileViewModeling {
    var controller: UIViewController? { get set }
    
}

class ProfileViewModel: ProfileViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    
    // MARK: - Initialization
    init() {
    }
}
