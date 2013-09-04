---
layout: post
title: "UIScrollView 和 Swipe 手势的识别问题"
date: 2013-09-04 15:40
comments: true
categories: iOS
---
UIScrollView 用得相当普遍，衍生出来的 UITableView 也用得不少。最近有人问我，当给 UIScrollView 加上左右滑动手势 UISwipeGesture 时，感觉好难滑动，必须要很平的左右划才会触发 Swipe，否则都是触发 UIScrollView 的滚动事件。

这时候，我们会想到，不需要那么水平的滑动就好了，例如以滑动45度为分割线，滑动轨迹与水平线夹角在正负45度，都认为是水平滑动，超过45度，就认为是垂直滚动。

看上去好像可以做。那么我们就要拦截发送给 UIScrollView 的手势——重载 UIScrollView 的手势响应方法：

{% codeblock lang:objective-c %}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        if ((fabs(point.y) / fabs(point.x)) < 1) { // 判断角度 tan(45),这里需要通过正负来判断手势方向
            NSLog(@"横向手势");
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}
{% endcodeblock %}

重载 UIScrollView，用这个新的对象，并且适当的调整其中的角度，来优化 APP 中的手势灵敏度。