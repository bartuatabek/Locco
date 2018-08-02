//
//  ChatController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ChatController: UIViewController {
    
    var viewModel: ChatViewModeling
    
    init(viewModel: ChatViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: "Chat", bundle: nil) // nibName => storyboard name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ChatViewModel()
        super.init(coder: aDecoder)
    }
}
