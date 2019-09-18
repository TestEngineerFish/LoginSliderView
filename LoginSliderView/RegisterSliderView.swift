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

    // ---- 拼图----


    // 字符校验(字符随机位置)
    let hintLabel       = UILabel()
    var charButtonArray = [UIButton]()
    var resultText      = ""
    var chooseText      = ""
    let buttonSize      = CGSize(width: 50.0, height: 50.0)
    var maxPoint        = CGPoint.zero // 记录最大X、Y


    // ---- 拼图----
    var imageView       = UIImageView()
    var puzzleMaskLayer = CAShapeLayer()
    var puzzleMoveView  = UIImageView()
    var thumbImgView    = UIImageView()
    var progressView    = UIView()
    let sliderView      = UIView()
    let refreshBtn      = UIButton()
    /// 滑动栏高度
    let sliderHeight    = CGFloat(20)
    /// 滑动栏上滑块的大小
    let thumbSize       = CGSize(width: 40, height: 40)
    /// 拼图块🧩大小
    let puzzleSize      = CGSize(width: 50, height: 50)
    /// 拼图块随机位置
    var randomPoint     = CGPoint.zero

    // ---- 通用 ----
    let contentView     = UIView()
    let shadowView      = UIView()

    var currentType = SliderType.puzzle
    var completeBlock: ((Bool)->Void)?
    /// 默认边距
    let margin       = CGFloat(10)
    /// 背景图宽度
    var imageWidth: CGFloat {
        get { return self.contentView.frame.width - margin*2 }
    }
    /// 背景图高度
    var imageHeight: CGFloat {
        get {
            let heightScale = CGFloat(0.6) // 背景图高/宽比
            return imageWidth * heightScale
        }
    }
    /// 失败提示View
    lazy var resultView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: imageHeight, width: imageWidth, height: 20))
        let icon = UIImageView(frame: CGRect(x: margin, y: 2.5, width: view.bounds.height - 5, height: view.bounds.height - 5))
        let text = UILabel(frame: CGRect(x: icon.frame.maxX + 5, y: 0, width: imageWidth - icon.frame.maxX - 20, height: view.bounds.height))
        view.addSubview(icon)
        view.addSubview(text)
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        icon.image = UIImage(named: "send_error")
        let attrStr = NSMutableAttributedString(string: "验证失败: 手残了吧,别不承认!再试一下吧~", attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        attrStr.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.red], range: NSRange(location: 0, length: 5))
        text.attributedText = attrStr
        text.font = UIFont.systemFont(ofSize: 11)
        self.imageView.insertSubview(view, at: 0)
        return view
    }()

    class func show(_ type: SliderType, completeBlock block: ((Bool) -> Void)?) {
        let view = RegisterSliderView(frame: UIScreen.main.bounds, type: type)
        view.completeBlock = block
        UIApplication.shared.keyWindow?.addSubview(view)
    }

    init(frame: CGRect, type: SliderType) {
        super.init(frame: frame)
        currentType = type
        _initView()
        setSliderType(type)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// 设置校验类型
    ///
    /// - Parameter type: 校验类型
    func setSliderType(_ type: SliderType) {
        // 移除背景图中子视图
        contentView.subviews.forEach {$0.removeFromSuperview()}
        switch type {
        case .puzzle:
            // 移除滑动栏上的子视图
            sliderView.subviews.forEach{$0.removeFromSuperview()}
            // 设置随机坐标
            randomPoint = getRandomPoint()
            // 初始化拼图视图
            _initPuzzleView()
            // 裁切并设置拼图
            setPuzzleContent()
        case .randomChar:
            _initRandomChar()
            setRandomCharContent()
        case .trimChar:
            _initTrimChar()
        case .slider:
            _initSliderView()
        }
    }

    // MARK: set UI

    /// 初始化公共容器视图
    func _initView() {
        addSubview(shadowView)
        addSubview(contentView)
        addSubview(refreshBtn)

        shadowView.frame            = self.bounds
        contentView.frame           = CGRect(x: 0, y: 0, width: 300, height: 280)
        contentView.center          = center
        refreshBtn.frame            = CGRect(x: contentView.frame.maxX - 45, y: contentView.frame.maxY - 45, width: 30, height: 30)
        backgroundColor             = UIColor.clear
        contentView.backgroundColor = UIColor.white
        shadowView.backgroundColor  = UIColor.black.withAlphaComponent(0.15)

        shadowView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        shadowView.addGestureRecognizer(tap)
        refreshBtn.setImage(UIImage(named: "refresh"), for: .normal)
        refreshBtn.addTarget(self, action: #selector(refresh(_:)), for: .touchUpInside)

    }

    /// 初始化拼图View
    func _initPuzzleView() {
        imageView.frame       = CGRect(x: margin, y: margin, width: imageWidth, height: imageHeight)
        puzzleMoveView.frame  = CGRect(x: margin, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        puzzleMaskLayer.frame = CGRect(x: randomPoint.x, y: randomPoint.y, width: puzzleSize.width, height: puzzleSize.height)
        thumbImgView.frame    = CGRect(x: puzzleMoveView.center.x - thumbSize.width/2, y: (sliderHeight - thumbSize.height)/2, width: thumbSize.width, height: thumbSize.height)
        progressView.frame    = CGRect(x: 0, y: 0, width: thumbImgView.frame.midX, height: sliderHeight)
        sliderView.frame      = CGRect(x: margin, y: imageView.frame.maxY + margin * 2, width: imageWidth, height: sliderHeight)
        sliderView.addSubview({
            let label       = UILabel(frame: sliderView.bounds)
            label.text      = "拖动滑块,将图片拼合完整"
            label.textColor = UIColor.black.withAlphaComponent(0.6)
            label.font      = UIFont.systemFont(ofSize: 11)
            label.textAlignment = .center
            return label
        }())

        sliderView.addSubview(progressView)
        sliderView.addSubview(thumbImgView)
        imageView.layer.addSublayer(puzzleMaskLayer)
        imageView.addSubview(puzzleMoveView)
        contentView.addSubview(imageView)
        contentView.addSubview(sliderView)

        imageView.contentMode            = .scaleAspectFill
        imageView.clipsToBounds          = true
        sliderView.backgroundColor       = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
        sliderView.layer.cornerRadius    = sliderHeight/2
        progressView.layer.cornerRadius  = sliderHeight/2
        progressView.backgroundColor     = UIColor.orange

        thumbImgView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(slidThumbView(sender:)))
        thumbImgView.addGestureRecognizer(pan)
    }

    func _initRandomChar() {
        imageView.frame = CGRect(x: margin, y: margin, width: imageWidth, height: imageHeight)
        hintLabel.frame = CGRect(x: margin, y: imageView.frame.maxY + margin, width: imageWidth, height: 50)
        contentView.addSubview(imageView)
        contentView.addSubview(hintLabel)
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        hintLabel.textAlignment = .center
        imageView.isUserInteractionEnabled = true
    }

    func _initTrimChar() {

    }

    func _initSliderView() {

    }

    // MARK: bind data


    /// 设置拼图验证的内容
    func setPuzzleContent() {
        guard var image = UIImage(named: "template") else { return }
        image = image.rescaleSize(CGSize(width: imageWidth, height: imageHeight))
        imageView.image    = image
        thumbImgView.image = UIImage(named: "slide_button")

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


    /// 设置字符校验(随机位置)的内容
    func setRandomCharContent() {
        guard var image = UIImage(named: "template") else { return }
        image = image.rescaleSize(CGSize(width: imageWidth, height: imageHeight))
        imageView.image = image
        let randomText  = getRandomChinese(count: 8)
        resultText      = randomText.subString(location: 0, length: 4)
        chooseText      = ""
        let hintText    = String(format: "请按顺序点击 %@ 完成验证", resultText)
        let attriStr    = NSMutableAttributedString(string: hintText, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13)])
        attriStr.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.red, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], range: NSRange(location: 7, length: 4))
        hintLabel.attributedText = attriStr

        charButtonArray.forEach {$0.removeFromSuperview()}
        charButtonArray.removeAll()
        maxPoint = CGPoint.zero
        var tag = 0
        randomText.forEach { (char) in
            let normalImg   = UIImage.imageWithColor(UIColor.white, size: buttonSize, cornerRadius: buttonSize.width/2)
            let selectedImg = UIImage.imageWithColor(UIColor.gray, size: buttonSize, cornerRadius: buttonSize.width/2)
            let button      = UIButton()
            button.tag      = tag
            button.frame    = CGRect(origin: getButtonRandomPoint(button), size: buttonSize)
            button.setTitle(String(char), for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setBackgroundImage(normalImg, for: .normal)
            button.setBackgroundImage(selectedImg, for: .selected)
            button.addTarget(self, action: #selector(selectedButton(button:)), for: .touchUpInside)
            button.layer.cornerRadius = buttonSize.width/2
            button.titleLabel?.font   = UIFont.systemFont(ofSize: 15)
            DispatchQueue.main.async(execute: {
                 button.transform = CGAffineTransform(rotationAngle: .pi/(self.getRandomNumber(from: 0, to: 400)/100))
            })
            imageView.addSubview(button)
            imageView.sendSubviewToBack(button)
            charButtonArray.append(button)
            tag += 1
        }
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


    /// 选择按钮事件
    ///
    /// - Parameter button: 按钮
    @objc func selectedButton(button: UIButton) {
        if button.isSelected { return }
        button.isSelected = true
        chooseText.append(button.currentTitle ?? "")
        if chooseText.count >= 4 {
            checkResult()
        }
    }

    /// 校验结果
    func checkResult() {
        var isSuccess = false
        switch currentType {
        case .puzzle:
            let xRange = NSRange(location: Int(self.puzzleMaskLayer.frame.origin.x) - 5, length: 10)
            isSuccess = xRange.contains(Int(self.puzzleMoveView.frame.origin.x))
        case .randomChar:
            isSuccess = chooseText == resultText
        case .trimChar:
            break
        case .slider:
            break
        }
        self.showResult(isSuccess)
    }

    /// 显示结果页
    ///
    /// - Parameter isSuccess: 是否正确
    /// - note: 暂时只有错误时,才显示
    func showResult(_ isSuccess: Bool) {
        if let block = completeBlock {
            block(isSuccess)
        }
        if isSuccess {
            close()
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.resultView.transform = CGAffineTransform(translationX: 0, y: -20)
            }) { (finish) in
                UIView.animate(withDuration: 0.15, delay: 0.75, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                    self.resultView.transform = .identity
                }, completion: nil)
            }
            refresh(refreshBtn)
        }
    }

    /// 关闭当前页面
    @objc func close() {
        removeFromSuperview()
    }

    /// 刷新
    ///
    /// - Parameter btn: 刷新按钮
    @objc func refresh(_ btn: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            btn.transform = CGAffineTransform(rotationAngle: -.pi)
        }) { (finish) in
            if finish {
                btn.transform = .identity
            }
        }
        setSliderType(currentType)
    }

    // TODO: tools

    /// 获取随机坐标
    func getRandomPoint() -> CGPoint {
        let minX = imageWidth/2 - puzzleSize.width
        let maxX = imageWidth - puzzleSize.width
        let minY = imageHeight/2 - puzzleSize.height
        let maxY = imageHeight - puzzleSize.height

        let x = getRandomNumber(from: minX, to: maxX)
        let y = getRandomNumber(from: minY, to: maxY)
        return CGPoint(x: x, y: y)
    }


    /// 获取随机数,需指定范围
    ///
    /// - Parameters:
    ///   - from: 最小值
    ///   - to: 最大值
    /// - Returns: 随机值
    func getRandomNumber(from:CGFloat, to:CGFloat) -> CGFloat {
        if from >= to { return from }
        let number = CGFloat(arc4random() % UInt32(to - from)) + from
        return number
    }

    /// 获取随机中文字符
    ///
    /// - Parameter count: 字符数s
    /// - Returns: 随机字符
    func getRandomChinese(count: Int) -> String {
        var content = ""
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(bitPattern: Int32(CFStringEncodings.GB_18030_2000.rawValue)))
        for _ in 0..<count {
            let randomH = 0xA1+arc4random()%(0xFE - 0xA1+1)
            let randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1)
            var number  = (randomH<<8)+randomL
            let data    = Data(bytes: &number, count: 2)
            guard let string = String(data: data, encoding: String.Encoding(rawValue: gbkEncoding)) else {
                continue
            }
            content.append(string)
        }
        return content
    }

    /// 获取按钮随机的坐标
    ///
    /// - Parameter charButton: 当前按钮对象
    /// - Returns: 随机坐标
    func getButtonRandomPoint(_ charButton:UIButton) -> CGPoint {
        var randomPoint = CGPoint.zero
        let numberH  = 4 //水平字符数量
        let numberV  = 2 // 垂直字符数量
        let defaultW = imageWidth / CGFloat(numberH)
        let defaultH = imageHeight / CGFloat(numberV)
        if charButton.tag % numberH == 0 {
            maxPoint.x = 0
        }
        if charButton.tag >= numberH {
            maxPoint.y = defaultH
        }
        let offsetY = charButton.tag >= numberH ? maxPoint.y : CGFloat.zero
        randomPoint.x = getRandomNumber(from: maxPoint.x, to: maxPoint.x + defaultW - buttonSize.width)
        randomPoint.y = getRandomNumber(from: offsetY, to: offsetY + defaultH - buttonSize.height)
        print(randomPoint)
        if (charButton.tag + 1) % numberH != 0 {
            maxPoint.x = randomPoint.x + buttonSize.width
        }
        if randomPoint.y + buttonSize.height > maxPoint.y {
            maxPoint.y = randomPoint.y + buttonSize.height
        }
        return randomPoint
    }
}

extension String {

    /// 获取指定长度的字符
    ///
    /// - Parameters:
    ///   - location: 起始位置
    ///   - length: 所需长度
    /// - Returns: 截取后的内容
    func subString(location: Int, length: Int) -> String {
        let fromIndex = self.index(startIndex, offsetBy: location)
        let toIndex   = self.index(fromIndex, offsetBy: length)
        let subString = self[fromIndex..<toIndex]
        return String(subString)
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


    /// 根据颜色,绘制图片
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - width: 图片宽度
    ///   - height: 图片高度
    ///   - cornerRadius: 图片圆角
    /// - Returns: 绘制完后的图片对象
    class func imageWithColor(_ color: UIColor, size: CGSize, cornerRadius: CGFloat = 0) -> UIImage {

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let roundedRect: UIBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        roundedRect.lineWidth = 0

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        roundedRect.fill()
        roundedRect.stroke()
        roundedRect.addClip()
        var image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius))
        return image!
    }
}
