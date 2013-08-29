---
layout: post
title: "iOS5 上 Gesture 和 UIButton 手势冲突解决方法"
date: 2013-08-29 10:09
comments: true
categories: iOS
---
在一个 View 上面加一个 UIButton，指明一个 Action，很简单；在这个 View 上面加一个 Tap 手势，恩，也很简单。但是两者一起加，当我们点击 Button 时候，触发哪个呢？

经过测试，当系统是 iOS5 及以下时，响应 Tap 手势；当系统是 iOS6 及以上时，响应 Button 事件！！

那我们一般期望是什么行为呢？估计很多人都是想和 iOS6 那样，优先响应 Button 的事件。

让 iOS5 及以下响应 Button 事件的方法：

{%codeblock lang:objective-c %}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    // Disallow recognition of tap gestures in the control.
    if (([touch.view isKindOfClass:[UIControl class]])) {
        return NO;
    }
    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}
{%endcodeblock%}

重载View，复写上面的方法即可。