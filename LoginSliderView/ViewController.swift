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
        RegisterSliderView.show(.randomChar) { (isSuccess) in
            print(isSuccess)
        }
    }
}

