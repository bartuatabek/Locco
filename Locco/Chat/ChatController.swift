//
//  ChatController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ChatController: UIViewController {
    
    var viewModel: ChatViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ChatViewModel()
        self.viewModel!.controller = self
    }
}
