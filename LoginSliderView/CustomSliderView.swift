//
//  CustomSliderView.swift
//  LoginSliderView
//
//  Created by 沙庭宇 on 2019/9/12.
//  Copyright © 2019 Lee. All rights reserved.
//

import UIKit


/// 校验模式
enum SliderType: String {
    case puzzle     = "拼图校验"
    case randomChar = "字符校验(字符随机位置)"
    case trimChar   = "字符校验(字符固定位置)"
    case slider     = "滑动校验"
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
    let puzzleSize   = CGSize(width: 50, height: 50)
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
    // TODO: 拼图
    var imageView       = UIImageView()
    var puzzleMaskLayer = CAShapeLayer()
    var puzzleMoveView  = UIImageView()
    var thumbImgView    = UIImageView()
    var progressView    = UIView()
    let sliderView      = UIView()

    init(frame: CGRect, type: SliderType) {
        super.init(frame: frame)
        _initView()
        setRandomPoint()
        setSliderType(type)
        // 绑定数据
        setImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// 设置校验类型
    ///
    /// - Parameter type: <#type description#>
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

    /// 初始化容器视图
    func _initView() {
        self.addSubview(contentView)
        contentView.frame = self.bounds
    }

    /// 初始化拼图View
    func _initPuzzleView() {
        imageView.frame       = CGRect(x: margin, y: margin, width: maxWidth, height: imageHeight)
        puzzleMoveView.frame  = CGRect(x: margin, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        puzzleMaskLayer.frame = CGRect(x: randomPoint.x, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        thumbImgView.frame    = CGRect(x: puzzleSize.width/2 + margin, y: (sliderHeight - thumbSize.height)/2, width: thumbSize.width, height: thumbSize.height)
        progressView.frame    = CGRect(x: 0, y: 0, width: thumbImgView.frame.midX, height: sliderHeight)
        sliderView.frame      = CGRect(x: margin, y: contentView.frame.size.height - margin - sliderHeight, width: maxWidth, height: sliderHeight)

        sliderView.addSubview(progressView)
        sliderView.addSubview(thumbImgView)
        imageView.layer.addSublayer(puzzleMaskLayer)
        imageView.addSubview(puzzleMoveView)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(sliderView)

        thumbImgView.image              = UIImage(named: "slide_button")
        imageView.contentMode           = .scaleAspectFill
        imageView.clipsToBounds         = true
        sliderView.backgroundColor      = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
        progressView.backgroundColor    = UIColor.orange
        sliderView.layer.cornerRadius   = 15
        progressView.layer.cornerRadius = 15

        thumbImgView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(slidThumbView(sender:)))
        thumbImgView.addGestureRecognizer(pan)
    }

    func _initRandomChar() {

    }

    func _initTrimChar() {

    }

    func _initSliderView() {

    }

    // MARK: bind data


    /// 设置图片
    func setImage() {
        guard var image = UIImage(named: "template") else { return }
        image = image.rescaleSize(CGSize(width: maxWidth, height: imageHeight))
        self.imageView.image = image
        let path = self.drawBezierPath()
        // 绘制完成后,需要修改被移动的拼图frame.因为绘制后的大小不一定等于初始大小
        puzzleMoveView.frame = CGRect(origin: puzzleMoveView.frame.origin, size: path.bounds.size)

        guard var partImage = self.imageView.image?.clipImage(rect: CGRect(origin: puzzleMaskLayer.frame.origin, size: path.bounds.size)) else { return }
        partImage = partImage.clipPathImage(with: path) ?? partImage

        puzzleMoveView.image        = partImage
        puzzleMaskLayer.path        = path.cgPath
        puzzleMaskLayer.strokeColor = UIColor.white.cgColor
        puzzleMaskLayer.fillColor   = UIColor.gray.withAlphaComponent(0.8).cgColor
    }

    // TODO: Event


    /// 滑动进度条的手势事件
    ///
    /// - Parameter sender: 滑动的手势对象
    @objc func slidThumbView(sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: sliderView)
        thumbImgView.transform   = CGAffineTransform(translationX: point.x, y: 0)
        puzzleMoveView.transform = CGAffineTransform(translationX: point.x, y: 0)
        progressView.layer.frame = CGRect(x: 0, y: 0, width: thumbImgView.frame.midX, height: self.sliderHeight)
        if sender.state == UIGestureRecognizer.State.ended {
            UIView.animate(withDuration: 0.15) {
                self.thumbImgView.transform   = .identity
                self.puzzleMoveView.transform = .identity
                self.progressView.layer.frame = CGRect(x: 0, y: 0, width: self.thumbImgView.frame.midX, height: self.sliderHeight)
            }
        }
    }

    // TODO: tools

    /// 设置随机数
    func setRandomPoint() {
        let minX = maxWidth/2 - puzzleSize.width
        let maxX = maxWidth - puzzleSize.width
        let minY = imageHeight/2 - puzzleSize.height
        let maxY = imageHeight - puzzleSize.height
        randomPoint.x = CGFloat(arc4random() % UInt32(maxX - minX)) + minX
        randomPoint.y = CGFloat(arc4random() % UInt32(maxY - minY)) + minY
    }


    /// 绘制拼图路径
    ///
    /// - Returns: <#return value description#>
    func drawBezierPath() -> UIBezierPath {
        /// 贝塞尔绘制边上缺口的半径
        let offsetW     = CGFloat(6)
        /// 贝塞尔绘制突出小块的直径
        let offsetH    = CGFloat(10)
        let puzzleHalf = (puzzleSize.width - offsetH)*0.5
        let path       = UIBezierPath()

        path.move(to: CGPoint(x: 0, y: offsetH))
        path.addLine(to: CGPoint(x: puzzleHalf - offsetW, y: offsetH))
        path.addQuadCurve(to: CGPoint(x: puzzleHalf + offsetW, y: offsetH), controlPoint: CGPoint(x: puzzleHalf, y: 0))
        path.addLine(to: CGPoint(x: puzzleHalf*2, y: offsetH))

        path.addLine(to: CGPoint(x: puzzleHalf*2, y: puzzleHalf + offsetH - offsetW))
        path.addQuadCurve(to: CGPoint(x: puzzleHalf*2, y: puzzleHalf + offsetH + offsetW), controlPoint: CGPoint(x: puzzleHalf*2 + offsetH, y: puzzleHalf + offsetH))
        path.addLine(to: CGPoint(x: puzzleHalf*2, y: puzzleHalf*2 + offsetH))

        path.addLine(to: CGPoint(x: puzzleHalf + offsetW, y: puzzleHalf*2 + offsetH))
        path.addQuadCurve(to: CGPoint(x: puzzleHalf - offsetW, y: puzzleHalf*2 + offsetH), controlPoint: CGPoint(x: puzzleHalf, y: puzzleHalf*2))
        path.addLine(to: CGPoint(x: 0, y: puzzleHalf*2 + offsetH))

        path.addLine(to: CGPoint(x: 0, y: puzzleHalf + offsetH + offsetW))
        path.addQuadCurve(to: CGPoint(x: 0, y: puzzleHalf + offsetH - offsetW), controlPoint: CGPoint(x: offsetH, y: puzzleHalf + offsetH))
        path.addLine(to: CGPoint(x: 0, y: offsetH))

        path.stroke()
        return path
    }
}

extension UIImage {

    /// 按尺寸截取图片
    ///
    /// - Parameter rect: 需要截取的位置
    /// - Returns: 截取后的图片,不存在则返回nil
    func clipImage(rect: CGRect) -> UIImage? {
        let scale = self.scale
        let realRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let imageRef = self.cgImage?.cropping(to: realRect) else { return nil }
        var partImage = UIImage(cgImage: imageRef)
        partImage     = partImage.rescaleSize(rect.size)
        return partImage
    }

    /// 调整图片大小
    ///
    /// - Parameter size: 需要调整后的尺寸
    /// - Returns: 返回调整后的图片
    func rescaleSize(_ size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: rect)
        let resizeImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImg ?? self
    }

    /// 按照path路径剪切图片
    ///
    /// - Parameter path: 需要截图的路径
    /// - Returns: 截取后的图片,不存在则返回nil
    func clipPathImage(with path: UIBezierPath) -> UIImage? {
        let originScale = self.size.width / self.size.height
        let boxBounds   = path.bounds
        let width       = boxBounds.size.width
        let height      = width / originScale

        UIGraphicsBeginImageContextWithOptions(boxBounds.size, false, UIScreen.main.scale)
        let bitmap = UIGraphicsGetCurrentContext()

        let newPath: UIBezierPath = path
        newPath.apply(CGAffineTransform(translationX: -path.bounds.origin.x, y: -path.bounds.origin.y))
        newPath.addClip()

        bitmap?.translateBy(x: boxBounds.size.width / 2.0, y: boxBounds.size.height / 2.0)
        bitmap?.scaleBy(x: 1.0, y: -1.0) // 改变内容大小比例
        guard let _cgImage = self.cgImage else { return nil}
        bitmap?.draw(_cgImage, in: CGRect(x: -width/2, y: -height/2, width: width, height: height))

        let resultImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImg
    }
}
