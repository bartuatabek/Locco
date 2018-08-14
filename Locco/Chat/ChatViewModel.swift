//
//  ChatViewModel.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa

protocol ChatViewModeling {
    var controller: UIViewController? { get set }
    
}

class ChatViewModel: ChatViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    
    // MARK: - Initialization
    init() {
    }
}
