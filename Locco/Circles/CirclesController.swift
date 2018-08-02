//
//  CirclesController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import AVFoundation

class CirclesController: UIViewController {
    
    var viewModel: CirclesViewModeling
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
//        self.title = viewModel.getCircleName()
    }
    
    init(viewModel: CirclesViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: "Circles", bundle: nil) // nibName => storyboard name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = CirclesViewModel()
        super.init(coder: aDecoder)
        
        let path = Bundle.main.path(forResource: "Bushmaster.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
}
