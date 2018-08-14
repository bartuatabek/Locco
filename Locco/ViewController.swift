//
//  ViewController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIScrollViewDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
        
        textView.text = "With Locco, you can easily locate your friends and family from your iPhone"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private typealias ScrollView = ViewController

extension ScrollView {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        // Change the text accordingly
        if Int(currentPage) == 0 {
            self.textView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.textView.text = "With Locco, you can easily locate your friends and family from your iPhone"
                self.textView.fadeIn()
            })
        } else if Int(currentPage) == 1 {
            self.textView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.textView.text = "You can hide or stop sharing your location with your friends."
                self.textView.fadeIn()
            })
        } else if Int(currentPage) == 2 {
            self.textView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.textView.text = "If you don't want your friends to see your location in Find My Friends anymore, you can stop sharing from the app on your iOS device. You can still see the location of your friends, but your friends see Location Not Available when they try to locate you."
                self.textView.fadeIn()
            })
        } else {
            self.textView.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.textView.text = "If you accept someone's request to follow your location, that person can then see your location. If you want to see that person's location, you must invite them, and they must accept your invitation. If you accept a request from a friend that you’re not following, a follow request is sent to your friend automatically."
                self.textView.fadeIn()
            })
            
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.startButton.alpha = 1.0
            })
        }
    }
}


