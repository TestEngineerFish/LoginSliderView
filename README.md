# LoginSliderView
滑动图形行为验证码

使用相当简单，只需要两步：
1、实例化一个RegisterSliderView对象，也就是显示滑动行为验证码的view；
  self.sliderView = RegisterSliderView(frame: CGRect(x: (UIScreen.main.bounds.width - self.viewWidth) / 2 , y: (UIScreen.main.bounds.height - self.viewHeight) / 2, width: self.viewWidth, height: self.viewHeight))
  
2、在需要的VC中实现RegisterSliderViewDelegate protocol，用于滑动成功后，后续要做的操作；
  self.sliderView!.delegate = self
