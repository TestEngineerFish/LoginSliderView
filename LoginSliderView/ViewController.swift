//
//  ViewController.swift
//  LoginSliderView
//
//  Created by 老沙-Sam on 2017/8/24.
//  Copyright © 2017年 老沙-Sam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    var sliderViewBackground: UIView?
    var sliderView: RegisterSliderView?
    
    let viewWidth: CGFloat = 325.0
    let viewHeight: CGFloat = 275.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(_ sender: UIButton) {

        let sliderView = RegisterSliderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 100, height: 280), type: .puzzle)
        sliderView.center = self.view.center
        self.view.addSubview(sliderView)
    }
}

