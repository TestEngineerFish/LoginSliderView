//
//  ViewController.swift
//  LoginSliderView
//
//  Created by 老沙-Sam on 2017/8/24.
//  Copyright © 2017年 老沙-Sam. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RegisterSliderViewDelegate {
    
    
    @IBOutlet weak var buttonShowSliderView: UIButton!
    var sliderViewBackground: UIView?
    var sliderView: RegisterSliderView?
    
    let viewWidth: CGFloat = 325.0
    let viewHeight: CGFloat = 275.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonShowSliderView.layer.cornerRadius = 5.0
    }
    
    @objc func creatAndHideRegisterSliderView() {
        /*
        if let _sliderView = self.sliderView {
            UIView.animate(withDuration: 0.25, animations: {
                _sliderView.alpha = 0
                self.sliderViewBackground?.alpha = 0
            }) { (result) in
                if result {
                    _sliderView.removeFromSuperview()
                    self.sliderView = nil
                    self.sliderViewBackground?.removeFromSuperview()
                    self.sliderViewBackground = nil
                }
            }
        } else {
            self.sliderView           = RegisterSliderView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
            self.sliderView?.center   = self.view.center
            self.sliderViewBackground = UIView(frame: UIScreen.main.bounds)
            self.sliderView?.delegate = self
            self.sliderViewBackground?.alpha           = 0
            self.sliderViewBackground?.backgroundColor = UIColor.black
            self.view.addSubview(self.sliderViewBackground!)
            self.view.addSubview(self.sliderView!)
            UIView.animate(withDuration: 0.15, animations: {
                self.sliderViewBackground?.alpha = 0.25
                self.sliderView?.alpha = 1.0
            }) { (result) in
                if result {
                    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.creatAndHideRegisterSliderView))
                    self.sliderViewBackground?.addGestureRecognizer(tap)
                }
            }
        }
        */
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
//        self.creatAndHideRegisterSliderView()
        let sliderView = CustomSliderView(frame: CGRect(x: 0, y: 0, width: 400, height: 360), type: .puzzle)
        sliderView.center = self.view.center
        self.view.addSubview(sliderView)
    }
}

