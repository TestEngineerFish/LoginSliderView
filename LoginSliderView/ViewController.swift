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

    @IBOutlet weak var stackView: UIStackView!


    let viewWidth: CGFloat = 325.0
    let viewHeight: CGFloat = 275.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        stackView.layer.masksToBounds = true
//        stackView.clipRectCorner(directionList: [.allCorners], cornerRadius: 75)
    }
    
    @IBAction func show(_ sender: UIButton) {
        let type = SliderType(rawValue: sender.tag) ?? SliderType.puzzle
        RegisterSliderView.show(type) { (isSuccess) in
            print(isSuccess)
        }
    }
}

extension UIView {
    /// 根据需要,裁剪各个顶点为圆角
    ///
    /// 其实就是根据当前View的Size绘制了一个 CAShapeLayer,将其遮在了当前View的layer上,就是Mask层,使mask以外的区域不可见
    /// - parameter directionList: 需要裁切的圆角方向,左上角(topLeft)、右上角(topRight)、左下角(bottomLeft)、右下角(bottomRight)或者所有角落(allCorners)
    /// - parameter cornerRadius: 圆角半径
    /// - note: .pi等于180度,圆角计算,默认以圆横直径的右半部分顺时针开始计算(就类似上面那个圆形中的‘=====’线),当然如果参数 clockwies 设置false.则逆时针开始计算角度
    func clipRectCorner(directionList: [UIRectCorner], cornerRadius radius: CGFloat) {
        let height = self.frame.size.height
        let width  = self.frame.size.width
        let bezierPath = UIBezierPath()
        // 以左边中间节点开始绘制
        bezierPath.move(to: CGPoint(x: 0, y: height/2))
        // 如果左上角需要绘制圆角
        if directionList.contains(.topLeft) {
            bezierPath.move(to: CGPoint(x: 0, y: radius))
            bezierPath.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        } else {
            bezierPath.addLine(to: self.frame.origin)
        }
        // 如果右上角需要绘制
        if directionList.contains(.topRight) {
            bezierPath.addLine(to: CGPoint(x: self.frame.maxX - radius, y: 0))
            bezierPath.addArc(withCenter: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true)
        } else {
            bezierPath.addLine(to: CGPoint(x: width, y: 0))
        }
        // 如果右下角需要绘制
        if directionList.contains(.bottomRight) {
            bezierPath.addLine(to: CGPoint(x: width, y: height - radius))
            bezierPath.addArc(withCenter: CGPoint(x: width - radius, y: height - radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
        } else {
            bezierPath.addLine(to: CGPoint(x: width, y: height))
        }
        // 如果左下角需要绘制
        if directionList.contains(.bottomLeft) {
            bezierPath.addLine(to: CGPoint(x: radius, y: height))
            bezierPath.addArc(withCenter: CGPoint(x: radius, y: height - radius), radius: radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
        } else {
            bezierPath.addLine(to: CGPoint(x: 0, y: height))
        }
        // 与开始节点闭合
        bezierPath.addLine(to: CGPoint(x: 0, y: height/2))

        let maskLayer   = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path  = bezierPath.cgPath
        layer.mask      = maskLayer
    }
}

