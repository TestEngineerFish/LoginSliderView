//
//  CustomSliderView.swift
//  LoginSliderView
//
//  Created by 沙庭宇 on 2019/9/12.
//  Copyright © 2019 Lee. All rights reserved.
//

import UIKit

enum SliderType: Int {
    case puzzle     = 0
    case randomChar = 1
    case trimChar   = 2
    case slider     = 3
}

class CustomSliderView: UIView {

    // MARK: 基本数据
    /// 默认边距
    let margin       = CGFloat(10)
    /// 滑动栏高度
    let sliderHeight = CGFloat(30)
    /// 滑动栏上滑块的大小
    let thumbSize    = CGSize(width: 40, height: 40)
    /// 拼图块🧩大小
    let partSize     = CGSize(width: 50, height: 50)
    /// 拼图块随机位置
    var randomPoint  = CGPoint.zero

    var maxWidth: CGFloat {
        get {
            return self.contentView.frame.width - margin*2
        }
    }
    /// 背景高度
    var imageHeight: CGFloat {
        get {
            let heightScale = CGFloat(0.7) // 背景图高/宽比
            return maxWidth * heightScale
        }
    }

    // MARK: UI对象
    let contentView     = UIView()
    let backgroundView  = UIView()
    // TODO: 拼图
    var imageView       = UIImageView()
    var partView        = UIImageView()
    var partCopyView    = UIImageView()
    var thumbImgView    = UIImageView()
    var progressView    = UIView()

    init(frame: CGRect, type: SliderType) {
        super.init(frame: frame)
        setSliderType(type)
        // 绑定数据
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSliderType(_ type: SliderType) {
        self.contentView.subviews.forEach {$0.removeFromSuperview()}
        switch type {
        case .puzzle:
            _initPuzzleView()
        case .randomChar:
            _initRandomChar()
        case .trimChar:
            _initTrimChar()
        case .slider:
            _initSliderView()
        }
    }

    // MARK: set UI

    func _initView() {
        self.addSubview(backgroundView)
        self.addSubview(contentView)
    }

    func _initPuzzleView() {
        imageView.frame    = CGRect(x: margin, y: margin, width: maxWidth, height: imageHeight)
        partCopyView.frame = CGRect(x: margin, y: randomPoint.y, width: partSize.width, height: partSize.height)
        partView.frame     = CGRect(x: randomPoint.x, y: randomPoint.y, width: partSize.width, height: partSize.height)
        thumbImgView.frame = CGRect(x: partSize.width/2 + margin, y: 0, width: thumbSize.width, height: thumbSize.height)
        progressView.frame = CGRect(x: 0, y: 0, width: thumbImgView.frame.midX, height: sliderHeight)
        let sliderView     = UIView(frame: CGRect(x: margin, y: contentView.frame.size.height - margin*2 - 30, width: maxWidth, height: 30.0))

        sliderView.addSubview(progressView)
        sliderView.addSubview(thumbImgView)
        imageView.addSubview(partView)
        imageView.addSubview(partCopyView)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(sliderView)

        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true

        sliderView.backgroundColor     = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
        sliderView.layer.cornerRadius  = 15
        sliderView.layer.masksToBounds = true

        progressView.backgroundColor   = UIColor.orange

    }

    func _initRandomChar() {

    }

    func _initTrimChar() {

    }

    func _initSliderView() {

    }

    // MARK: bind data

    func setImage() {
        guard var image = UIImage(named: "template") else { return }
        image = rescaleSize(CGSize(width: maxWidth, height: imageHeight), image: image)
        self.imageView.image = image
    }

    // TODO: tools

    /// 调整图片大小
    func rescaleSize(_ size: CGSize, image: UIImage) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(rect)
        let resizeImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImg ?? image
    }

    /// 截取需要尺寸图片
    func clipImage(_ image: UIImage, rect: CGRect) -> UIImage? {
        let realRect = CGRect(x: rect.origin.x * image.scale, y: rect.origin.y * image.scale, width: rect.size.width * image.scale, height: rect.size.height * image.scale)
        guard let imageRef = image.cgImage?.cropping(to: realRect) else { return nil }
        var partImage = UIImage(cgImage: imageRef)
        partImage     = rescaleSize(rect.size, image: partImage)
        return partImage
    }

    func drawBezierPath() -> UIBezierPath {
        let offset   = CGFloat(9)
        let partHalf = partSize.width*0.5
        let path     = UIBezierPath()

        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: partHalf - offset, y: 0))
        path.addQuadCurve(to: CGPoint(x: partHalf + offset, y: 0), controlPoint: CGPoint(x: partHalf, y: -offset*2))
        path.addLine(to: CGPoint(x: partSize.width, y: 0))

        path.addLine(to: CGPoint(x: partSize.width, y: partHalf - offset))
        path.addQuadCurve(to: CGPoint(x: partSize.width, y: partHalf + offset), controlPoint: CGPoint(x: partSize.width + offset*2, y: partHalf))
        path.addLine(to: CGPoint(x: partSize.width, y: partSize.width))

        path.addLine(to: CGPoint(x: partHalf + offset, y: partSize.width))
        path.addQuadCurve(to: CGPoint(x: partHalf - offset, y: partSize.width), controlPoint: CGPoint(x: partHalf, y: partSize.width - offset*2))
        path.addLine(to: CGPoint(x: 0, y: partSize.width))

        path.addLine(to: CGPoint(x: 0, y: partHalf + offset))
        path.addQuadCurve(to: CGPoint(x: 0, y: partHalf - offset), controlPoint: CGPoint(x: offset*2, y: partHalf))
        path.addLine(to: CGPoint.zero)

        path.stroke()
        return path
    }

}
