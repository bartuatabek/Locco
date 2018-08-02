//
//  ActivityController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ActivityController: UIViewController {
    
    var viewModel: ActivityViewModeling
    
    init(viewModel: ActivityViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: "Activity", bundle: nil) // nibName => storyboard name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ActivityViewModel()
        super.init(coder: aDecoder)
    }
}
