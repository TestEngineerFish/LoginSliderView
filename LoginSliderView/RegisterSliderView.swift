//
//  RegisterSliderView.swift
//  PanningMan
//
//  Created by 老沙-Sam on 2017/3/9.
//  Copyright © 2017年 老沙. All rights reserved.
//

import UIKit

protocol RegisterSliderViewDelegate {
//    func sliderViewShouldRecovered() -> (Bool)  //滑到终点松开手指时是否应该还原
    func sliderViewDidDragToEndPoint()          //滑条已经被滑到终点
}

class RegisterSliderView: UIView {
    /*
    
    var delegate: RegisterSliderViewDelegate?
    
    /// 展示图中阴影的位置
    var cutPoint = CGPoint.zero
    var cutSize  = CGSize(width: 50, height: 50)
    
    //定义一些常量
    let padding: CGFloat = 10.0 //内边距
    let appleBranchHeight: CGFloat = 15.0//苹果中间图片距离苹果顶部的高度
    let sliderLength: CGFloat = 50.0//滑动栏上的按钮长、宽
    let difference: CGFloat = 2.0//因为绿色苹果框图的问题，有一定的差值，与代码无关，图片没问题可设置为0
    let resultViewHeight: CGFloat = 20.0//滑动失败后的提示区域高度
    let appleWidth: CGFloat = 67.0//苹果碎片的宽度
    let appleHeight: CGFloat = 72.0//苹果碎片的高度
    let offset: CGFloat = 5.0//滑动后对比图的容错偏移量
    
    //展示图
    let templateImage: UIImageView = {
        let image: UIImageView = UIImageView(image: #imageLiteral(resourceName: "template"))
        image.clipsToBounds = true
        return image
    }()
    
    //苹果拼图的View
    fileprivate lazy var appleView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    //苹果拼图中的苹果icon
    let appleImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "apple"))
    
    //苹果中间的图片碎片
    fileprivate lazy var fragmentImage: UIImageView = {
        let image: UIImageView = UIImageView()
        image.layer.cornerRadius = 28
        image.clipsToBounds = true
        return image
    }()
    
    //    模板图片上的阴影
    var vacancyView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "empty_apple"))
    
    //    滑动栏
    fileprivate lazy var sliderView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
        view.layer.cornerRadius = 15
        return view
    }()
    
    //    滑动栏上的按钮
    fileprivate lazy var sliderImgV: UIImageView = {
        let sliderImgV: UIImageView = UIImageView(image: #imageLiteral(resourceName: "slide_button"))
        sliderImgV.isUserInteractionEnabled = true
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.pan(pan:)))
        sliderImgV.addGestureRecognizer(pan)
        return sliderImgV
    }()
    
    
    fileprivate var imgCenter = CGPoint.zero
    
    //    滑动栏上的提示文案
    fileprivate lazy var tipsLabel: UILabel = {
        let tipsLabel: UILabel = UILabel()
        tipsLabel.textAlignment = .center
        tipsLabel.font = UIFont.systemFont(ofSize: 13.0)
        tipsLabel.text = "拖动滑块将悬浮苹果正确拼合"
        tipsLabel.textColor = UIColor.black
        return tipsLabel
    }()
    
    //    滑动结束后的结果展示
    let resultView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let resultViewBackground: UIView =  {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.2
        return view
    }()
    
    let resultImg: UIImageView = UIImageView(image: #imageLiteral(resourceName: "send_error"))
    
    let resultText: UILabel = {
        let text: UILabel  = UILabel()
        text.font = UIFont.systemFont(ofSize: 11.0)
        text.text = "验证失败："
        text.textColor = UIColor.red
        return text
    }()
    
    let resultTips: UILabel = {
        let text: UILabel = UILabel()
        text.font = UIFont.systemFont(ofSize: 11.0)
        text.text = "手残了吧，别不承认～Try again"
        text.textColor = UIColor.black
        return text
    }()
    
    //    复写这个View的初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    //    复写初始化布局方法，定义一些子控件的大小、位置
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.templateImage.frame = CGRect(x: self.padding, y: self.padding, width: self.bounds.size.width - self.padding * 2, height: 185)
        
        location = self.randomLocation(with: self.templateImage, width: self.appleWidth, height: self.appleHeight)
        
        self.vacancyView.frame = location
        
        guard let uiImage: UIImage = self.templateImage.image, let cgImage: CGImage = uiImage.cgImage else {
            return
        }
        self.fragmentImage.image = self.cutImage(image: cgImage, rect: CGRect(x: location.origin.x, y: location.origin.y + self.appleBranchHeight, width: location.size.width - self.difference, height: location.size.height - self.appleBranchHeight - self.difference))
        
        self.sliderView.frame = CGRect(x: self.templateImage.frame.origin.x, y: self.templateImage.frame.maxY + 25, width: self.templateImage.bounds.size.width, height: 30)
        
        self.sliderImgV.frame = CGRect(x: 15, y: (self.sliderView.bounds.size.height - self.sliderLength) / 2, width: self.sliderLength, height: self.sliderLength)
        
        self.appleView.frame = CGRect(x: self.sliderImgV.center.x - self.location.size.width / 2, y: self.location.origin.y, width: self.location.size.width, height: self.location.size.height)
        
        self.appleImage.frame = CGRect(x: 0, y: 0, width: self.appleView.bounds.size.width, height: self.appleView.bounds.size.height)
        
        self.fragmentImage.frame = CGRect(x: 0, y: self.appleBranchHeight, width: self.location.size.width - self.difference, height: self.location.size.height - self.appleBranchHeight - self.difference)
        
        self.tipsLabel.sizeToFit()
        self.tipsLabel.frame = CGRect(x: (self.sliderView.bounds.width - self.tipsLabel.bounds.size.width) * 0.5, y: (self.sliderView.bounds.height - self.tipsLabel.bounds.size.height) * 0.5, width: self.tipsLabel.bounds.size.width, height: self.tipsLabel.bounds.size.height)
        
        self.resultView.frame = CGRect(x:0, y:self.templateImage.bounds.size.height, width: self.templateImage.bounds.size.width, height: self.resultViewHeight)
        
        self.resultViewBackground.frame = CGRect(x:0, y:0, width: self.resultView.bounds.size.width, height: self.resultView.bounds.size.height)
        
        self.resultImg.frame = CGRect(x:15, y:(self.resultView.bounds.size.height - 15) / 2, width: 15, height: 15)
        
        self.resultText.sizeToFit()
        self.resultText.frame = CGRect(x:self.resultImg.frame.maxX + 5, y:(self.resultView.bounds.size.height - self.resultText.bounds.size.height) / 2, width: self.resultText.bounds.size.width, height: self.resultText.bounds.size.height)
        
        self.resultTips.sizeToFit()
        self.resultTips.frame = CGRect(x:self.resultText.frame.maxX, y:(self.resultView.bounds.size.height - self.resultTips.bounds.size.height) / 2, width: self.resultTips.bounds.size.width, height: self.resultTips.bounds.size.height)
    }
    
    func setupSubviews() {
        
        self.addSubview(self.templateImage)
        
        self.addSubview(self.sliderView)
        
        self.appleView.addSubview(self.fragmentImage)
        
        self.appleView.addSubview(self.appleImage)
        
        self.sliderView.addSubview(self.tipsLabel)
        
        self.sliderView.addSubview(self.sliderImgV)
        
        self.templateImage.addSubview(vacancyView)
        
        self.templateImage.addSubview(self.appleView)
        
        self.templateImage.addSubview(self.resultView)
        
        self.resultView.addSubview(self.resultViewBackground)
        
        self.resultView.addSubview(self.resultImg)
        
        self.resultView.addSubview(self.resultText)
        
        self.resultView.addSubview(self.resultTips)
    }
    
    @objc func pan(pan: UIPanGestureRecognizer) {
        
        let halfWidth: CGFloat = sliderImgV.frame.width * 0.5
        let point: CGPoint = pan.translation(in: self)
        if pan.state == .began {
            imgCenter = pan.view!.center
        }
        
        //point 滑动图片的中心坐标
        sliderImgV.center.x = imgCenter.x + point.x
        self.tipsLabel.isHidden = true
        UIView.animate(withDuration: 0.1) {
            self.appleView.center.x = self.sliderImgV.center.x
        }
        
        if pan.state == .ended {
            print("SliderImageV:\(appleView.frame.origin.x)  Location:\(self.location.origin.x)")
            
            if appleView.frame.origin.x > self.location.origin.x - self.offset && appleView.frame.origin.x < self.location.origin.x + self.offset {
                perform(#selector(self.noticeDelegate))
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.sliderImgV.center.x = halfWidth + 15
                    self.appleView.center.x = self.sliderImgV.center.x
                    self.tipsLabel.isHidden = false
                    self.showAndHideResultView()
                })
            }
        }
        setNeedsDisplay()
    }
    
    //    通过验证后的事件
    @objc func noticeDelegate() {
        delegate?.sliderViewDidDragToEndPoint()
    }
    
    func showAndHideResultView() {
        UIView.animate(withDuration: 0.25, animations: {
            
            self.resultView.frame = CGRect(x:0, y:self.templateImage.bounds.size.height - self.resultViewHeight, width: self.templateImage.bounds.size.width, height: self.resultViewHeight)
        })
        UIView.animate(withDuration: 0.25, delay: 1.5, animations: {
            self.resultView.frame = CGRect(x:0, y:self.templateImage.bounds.size.height, width: self.templateImage.bounds.size.width, height: 0)
        })
    }
    
    /// 随机获取图片的位置
    func randomPoint() -> CGPoint {
        let randomX = CGFloat(arc4random() % UInt32(self.bounds.width/2) + UInt32(self.bounds.width/2 - cutSize.width))
        let randomY = CGFloat(arc4random() % UInt32(self.bounds.height/2) + UInt32(self.bounds.height/2 - cutSize.height))
        return CGPoint(x: randomX, y: randomY)
    }
    
    ///    截取特定区域图片
    func cutImage(image: CGImage, rect: CGRect) -> UIImage {
        let scale : CGFloat = UIScreen.main.scale
        let x: CGFloat = rect.origin.x * scale
        let y: CGFloat = rect.origin.y * scale
        let w: CGFloat = rect.size.width * scale
        let h: CGFloat = rect.size.height * scale
        let dianRect: CGRect = CGRect(x: x, y: y, width: w, height: h)
        
        guard let newImageRef: CGImage = image.cropping(to: dianRect) else {
            return UIImage()
        }
        let newImage: UIImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }
    */
}


