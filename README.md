# LoginSliderView
滑动图形行为验证码
========
Guide gif
----
![guide](https://github.com/TestEngineerFish/LoginSliderView/blob/master/SliderView.gif)

使用步骤
#
由于具体约束都在RegisterSliderView中已设置，使用相当简单，只需要在调用的VC执行以下两步：<\br>

>1、实例化一个`RegisterSliderView`对象，也就是显示滑动行为验证码的view:<\br>

>>
```swift
self.sliderView = RegisterSliderView(frame: CGRect(x: (UIScreen.main.bounds.width - self.viewWidth) / 2 , y: (UIScreen.main.bounds.height - self.viewHeight) / 2, width: self.viewWidth, height: self.viewHeight))<\br>
```
>2、在需要的VC中实现`RegisterSliderViewDelegate` protocol，用于滑动成功后，后续要做的操作:</br>
>>
```swift
self.sliderView!.delegate = self<\br>
```
如果有不明白的，或者有疑问、建议之类，都欢迎拍砖，Issues或者直接联系：<\br>
*微信：_ShaTingYu<\br>
*QQ: 916878440<\br>
