//
//  ActivityController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ActivityController: UITableViewController {
    
    var viewModel: ActivityViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ActivityViewModel()
        self.viewModel!.controller = self
    }
}
