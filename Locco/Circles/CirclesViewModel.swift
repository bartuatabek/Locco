//
//  CirclesViewModel.swift
//  Locco
//
//  Created by Alperen Özdemir on 19.07.2018.
//  Copyright © 2018 Alperen Özdemir. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa

protocol CirclesViewModeling {
    var controller: UIViewController? { get set }
    func getCircleName() ->String
}

class CirclesViewModel: CirclesViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    
    // MARK: - Initialization
    init() {}
    
    func getCircleName() ->String{
        return "test"
    }
    
    
}
