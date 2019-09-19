//
//  ViewController.swift
//  LoginSliderView
//
//  Created by 老沙-Sam on 2017/8/24.
//  Copyright © 2017年 老沙-Sam. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet weak var puzzleButton: UIButton!

    @IBOutlet weak var randomCharButton: UIButton!

    @IBOutlet weak var charButton: UIButton!

    @IBOutlet weak var sliderButton: UIButton!

    let viewWidth: CGFloat  = 325.0
    let viewHeight: CGFloat = 275.0
    let kScreenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        super.loadView()
        puzzleButton.layer.cornerRadius     = 10
        randomCharButton.layer.cornerRadius = 10
        charButton.layer.cornerRadius       = 10
        sliderButton.layer.cornerRadius     = 10
        puzzleButton.transform     = CGAffineTransform(translationX: -puzzleButton.bounds.width - 30, y: 0)
        randomCharButton.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width - 30, y: 0)
        charButton.transform       = CGAffineTransform(translationX: -charButton.bounds.width - 30, y: 0)
        sliderButton.transform     = CGAffineTransform(translationX: UIScreen.main.bounds.width - 30, y: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, delay: 0.15, usingSpringWithDamping: 0.25, initialSpringVelocity: 3, options: UIView.AnimationOptions.curveLinear, animations: {
            self.puzzleButton.transform     = .identity
            self.randomCharButton.transform = .identity
            self.charButton.transform       = .identity
            self.sliderButton.transform     = .identity
        }, completion: nil)
    }

    @IBAction func show(_ sender: UIButton) {
        let type = VerifyType(rawValue: sender.tag) ?? .puzzle
        VerifyView.show(type) { (isSuccess) in
            print(isSuccess)
        }
    }
}

