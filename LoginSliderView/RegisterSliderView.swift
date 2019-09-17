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

class RegisterSliderView: UIView {

    // MARK: 基本数据
    /// 默认边距
    let margin       = CGFloat(10)
    /// 滑动栏高度
    let sliderHeight = CGFloat(20)
    /// 滑动栏上滑块的大小
    let thumbSize    = CGSize(width: 40, height: 40)
    /// 拼图块🧩大小
    let puzzleSize   = CGSize(width: 50, height: 50)
    /// 拼图块随机位置
    var randomPoint  = CGPoint.zero
    /// 背景图宽度
    var imageWidth: CGFloat {
        get {
            return self.contentView.frame.width - margin*2
        }
    }
    /// 背景图高度
    var imageHeight: CGFloat {
        get {
            let heightScale = CGFloat(0.6) // 背景图高/宽比
            return imageWidth * heightScale
        }
    }

    var type = SliderType.puzzle
    var completeBlock: ((Bool)->Void)?

    // MARK: UI对象
    let contentView     = UIView()
    let shadowView      = UIView()
    // TODO: 拼图
    var imageView       = UIImageView()
    var puzzleMaskLayer = CAShapeLayer()
    var puzzleMoveView  = UIImageView()
    var thumbImgView    = UIImageView()
    var progressView    = UIView()
    let sliderView      = UIView()
    let refreshBtn      = UIButton()
    lazy var resultView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: imageHeight, width: imageWidth, height: 20))
        let icon = UIImageView(frame: CGRect(x: margin, y: 0, width: view.bounds.height, height: view.bounds.height))
        let text = UILabel(frame: CGRect(x: icon.frame.maxX + 10, y: 0, width: imageWidth - icon.frame.maxX - 20, height: view.bounds.height))
        view.addSubview(icon)
        view.addSubview(text)
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        icon.image = UIImage(named: "send_error")
        let attrStr = NSMutableAttributedString(string: "验证失败: 手残了吧,别不承认!再试一下吧~", attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        attrStr.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.red], range: NSRange(location: 0, length: 5))
        text.attributedText = attrStr
        text.font = UIFont.systemFont(ofSize: 12)
        return view
    }()

    class func show(_ type: SliderType, completeBlock block: ((Bool) -> Void)?) {
        let view = RegisterSliderView(frame: UIScreen.main.bounds, type: type)
        view.completeBlock = block
        UIApplication.shared.keyWindow?.addSubview(view)
    }

    init(frame: CGRect, type: SliderType) {
        super.init(frame: frame)
        _initView()
        self.type = type
        setRandomPoint()
        setSliderType(type)
        setImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// 设置校验类型
    ///
    /// - Parameter type: 校验类型
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
        addSubview(shadowView)
        addSubview(contentView)
        backgroundColor             = UIColor.clear
        shadowView.frame            = self.bounds
        contentView.frame           = CGRect(x: 0, y: 0, width: 300, height: 280)
        contentView.center          = center
        contentView.backgroundColor = UIColor.white
        shadowView.backgroundColor  = UIColor.black.withAlphaComponent(0.15)
        shadowView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        shadowView.addGestureRecognizer(tap)
    }

    /// 初始化拼图View
    func _initPuzzleView() {
        imageView.frame       = CGRect(x: margin, y: margin, width: imageWidth, height: imageHeight)
        puzzleMoveView.frame  = CGRect(x: margin, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        puzzleMaskLayer.frame = CGRect(x: randomPoint.x, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        thumbImgView.frame    = CGRect(x: puzzleMoveView.center.x - thumbSize.width/2, y: (sliderHeight - thumbSize.height)/2, width: thumbSize.width, height: thumbSize.height)
        progressView.frame    = CGRect(x: 0, y: 0, width: thumbImgView.frame.midX, height: sliderHeight)
        sliderView.frame      = CGRect(x: margin, y: imageView.frame.maxY + margin * 2, width: imageWidth, height: sliderHeight)
        refreshBtn.frame      = CGRect(x: contentView.bounds.width - 45, y: contentView.bounds.height - 45, width: 30, height: 30)

        sliderView.addSubview(progressView)
        sliderView.addSubview(thumbImgView)
        imageView.layer.addSublayer(puzzleMaskLayer)
        imageView.addSubview(puzzleMoveView)
        contentView.addSubview(imageView)
        contentView.addSubview(sliderView)
        contentView.addSubview(refreshBtn)

        thumbImgView.image               = UIImage(named: "slide_button")
        imageView.contentMode            = .scaleAspectFill
        imageView.clipsToBounds          = true
        sliderView.backgroundColor       = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
        progressView.backgroundColor     = UIColor.orange
        sliderView.layer.cornerRadius    = sliderHeight/2
        progressView.layer.cornerRadius  = sliderHeight/2
        refreshBtn.titleLabel?.textColor = UIColor.orange

        refreshBtn.setImage(UIImage(named: "refresh"), for: .normal)
        refreshBtn.addTarget(self, action: #selector(refresh(_:)), for: .touchUpInside)
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
        image = image.rescaleSize(CGSize(width: imageWidth, height: imageHeight))
        self.imageView.image = image
        // 有空时将绘制过程放在ImageView中的Draw函数中
        UIGraphicsBeginImageContext(self.imageView.bounds.size)
        let path = image.drawBezierPath(origin: randomPoint, size: puzzleSize)
        UIGraphicsEndImageContext()
        // 绘制完成后,需要修改被移动的拼图frame.因为绘制后的大小不一定等于初始大小
        puzzleMoveView.frame = CGRect(origin: puzzleMoveView.frame.origin, size: path.bounds.size)

        guard var partImage = self.imageView.image?.clipImage(rect: CGRect(origin: puzzleMaskLayer.frame.origin, size: path.bounds.size)) else { return }
        partImage = partImage.clipPathImage(with: path) ?? partImage

        puzzleMoveView.image        = partImage
        puzzleMaskLayer.path        = path.cgPath
        puzzleMaskLayer.strokeColor = UIColor.white.cgColor
        puzzleMaskLayer.fillColor   = UIColor.gray.withAlphaComponent(0.5).cgColor
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
            self.checkResult()
            UIView.animate(withDuration: 0.15) {
                self.thumbImgView.transform   = .identity
                self.puzzleMoveView.transform = .identity
                self.progressView.layer.frame = CGRect(x: 0, y: 0, width: self.thumbImgView.frame.midX, height: self.sliderHeight)
            }
        }
    }

    func checkResult() {
        let xRange = NSRange(location: Int(self.puzzleMaskLayer.frame.origin.x) - 5, length: 10)
        let isSuccess = xRange.contains(Int(self.puzzleMoveView.frame.origin.x))
        self.showResult(isSuccess)
    }

    func showResult(_ isSuccess: Bool) {
        if let block = completeBlock {
            block(isSuccess)
        }
        if isSuccess {
            close()
        } else {
            self.imageView.addSubview(resultView)
            UIView.animate(withDuration: 0.25, animations: {
                self.resultView.transform = CGAffineTransform(translationX: 0, y: -20)
            }) { (finish) in
                UIView.animate(withDuration: 0.15, delay: 0.75, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                    self.resultView.transform = .identity
                }, completion: nil)
            }
        }
    }

    @objc func close() {
        removeFromSuperview()
    }

    @objc func refresh(_ btn: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            btn.transform = CGAffineTransform(rotationAngle: -.pi)
        }) { (finish) in
            if finish {
                btn.transform = .identity
            }
        }
        setRandomPoint()
        setSliderType(type)
        setImage()
    }

    // TODO: tools

    /// 设置随机数
    func setRandomPoint() {
        let minX = imageWidth/2 - puzzleSize.width
        let maxX = imageWidth - puzzleSize.width
        let minY = imageHeight/2 - puzzleSize.height
        let maxY = imageHeight - puzzleSize.height
        randomPoint.x = CGFloat(arc4random() % UInt32(maxX - minX)) + minX
        randomPoint.y = CGFloat(arc4random() % UInt32(maxY - minY)) + minY
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

    /// 绘制拼图路径
    ///
    /// - Returns: 绘制完成的Path
    func drawBezierPath(origin point: CGPoint, size: CGSize) -> UIBezierPath {
        /// 贝塞尔绘制边上缺口的半径
        let offsetW     = CGFloat(6)
        /// 贝塞尔绘制突出小块的直径
        let offsetH    = CGFloat(10)
        let puzzleHalf = (size.width - offsetH)*0.5
        let path       = UIBezierPath()

        path.move(to: CGPoint(x: point.x, y: point.y + offsetH))
        path.addLine(to: CGPoint(x: point.x + puzzleHalf - offsetW, y: point.y + offsetH))
        path.addQuadCurve(to: CGPoint(x: point.x + puzzleHalf + offsetW, y: point.y + offsetH), controlPoint: CGPoint(x: point.x + puzzleHalf, y: point.y))
        path.addLine(to: CGPoint(x: point.x + puzzleHalf*2, y: point.y + offsetH))

        path.addLine(to: CGPoint(x: point.x + puzzleHalf*2, y: point.y + puzzleHalf + offsetH - offsetW))
        path.addQuadCurve(to: CGPoint(x: point.x + puzzleHalf*2, y: point.y + puzzleHalf + offsetH + offsetW), controlPoint: CGPoint(x: point.x + puzzleHalf*2 + offsetH, y: point.y + puzzleHalf + offsetH))
        path.addLine(to: CGPoint(x: point.x + puzzleHalf*2, y: point.y + puzzleHalf*2 + offsetH))

        path.addLine(to: CGPoint(x: point.x + puzzleHalf + offsetW, y: point.y + puzzleHalf*2 + offsetH))
        path.addQuadCurve(to: CGPoint(x: point.x + puzzleHalf - offsetW, y: point.y + puzzleHalf*2 + offsetH), controlPoint: CGPoint(x: point.x + puzzleHalf, y: point.y + puzzleHalf*2))
        path.addLine(to: CGPoint(x: point.x, y: point.y + puzzleHalf*2 + offsetH))

        path.addLine(to: CGPoint(x: point.x, y: point.y + puzzleHalf + offsetH + offsetW))
        path.addQuadCurve(to: CGPoint(x: point.x, y: point.y + puzzleHalf + offsetH - offsetW), controlPoint: CGPoint(x: point.x + offsetH, y: point.y + puzzleHalf + offsetH))
        path.addLine(to: CGPoint(x: point.x, y: point.y + offsetH))
        path.stroke()
        return path
    }
}
