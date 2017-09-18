//
//  ViewController.swift
//  LoginSliderView
//
//  Created by Lee on 2017/8/24.
//  Copyright © 2017年 Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RegisterSliderViewDelegate {
    
    
    @IBOutlet weak var buttonShowSliderView: UIButton!
    var sliderViewBackground: UIView = UIView()
    var sliderView: RegisterSliderView?
    
    let viewWidth: CGFloat = 325.0
    let viewHeight: CGFloat = 275.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonShowSliderView.layer.cornerRadius = 5.0
    }
    
    func creatAndHideRegisterSliderView() {
        guard let _: RegisterSliderView = self.sliderView else {
            self.sliderViewBackground = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            self.sliderViewBackground.backgroundColor = UIColor.black
            self.sliderViewBackground.alpha = 0.2
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.creatAndHideRegisterSliderView))
            self.sliderViewBackground.addGestureRecognizer(tap)
            self.view.addSubview(self.sliderViewBackground)
            
            self.sliderView = RegisterSliderView(frame: CGRect(x: (UIScreen.main.bounds.width - self.viewWidth) / 2 , y: (UIScreen.main.bounds.height - self.viewHeight) / 2, width: self.viewWidth, height: self.viewHeight))
            self.view.addSubview(self.sliderView!)
            self.sliderView!.delegate = self
            return
        }
        self.sliderView?.removeFromSuperview()
        self.sliderViewBackground.removeFromSuperview()
        self.sliderView = nil
        self.sliderViewBackground = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //滑动成功后的回调
    func sliderViewDidDragToEndPoint() {
        self.creatAndHideRegisterSliderView()
        NSLog("恭喜恭喜！")
    }
    
    @IBAction func show(_ sender: UIButton) {
        self.creatAndHideRegisterSliderView()
    }
}

