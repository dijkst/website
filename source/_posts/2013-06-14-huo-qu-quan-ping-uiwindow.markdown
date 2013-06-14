---
layout: post
title: "获取全屏UIWindow"
date: 2013-06-14 20:42
comments: true
categories: iOS
---

如果客官是写代码给别人用的那一群人，很可能有在当前APP中弹出一个对话框或者窗口的需要，而且很多时候我们只知道那个APP是一个iOS程序，对它的实现一无所知（可能是cocos2dx，可能是unity3d...）。还好iOS程序有个常识----APP有window才能显示，我们需要做的就是获得那个window，把我们创建的UIView添加上去。

其实还有一些方案，比如创建一个UIWindow，保证它的level比Normal的level高，然后makeKeyAndVisible。这种做法会遇到问题，比如，在这个不是NormalLevel的window里用webview播放在线视频页面层次会错乱，在这个window里使用虚拟键盘，ios6下也会有问题。

还有一个方案，让用到你的代码的程序员提供一个UIView或者ViewController，然后把想要放的界面放进去，这个方案比较可靠，缺点是遇到那些没有iOS编程概念的程序员会很难教育，如果他们使用unity3d，他们可能根本不需要知道UIView是什么。

所以还是回到题目中的问题，首先要明白一个API只要不被不允许怎样使用，那么那个API的什么用法都有可能被程序员们用到。比如现在要说的UIWindow，一个APP最好不要使用多个UIWindow，我在stackoverflow上遇到过不少这样的告诫，作为一个写代码给别人用的人，我很感激他们用心良苦，但还是有很多人没有看到这种告诫或者无视掉, 拥有多个UIWindow的APP我见过不少。

要获得我们寄宿UIView的UIWindow就要知道下面几个事实：

1，有的程序不止一个UIWindow

<!-- more -->

2，显示AlertView的时候，系统也创建了一个UIWindow， 他的level是一个比较高的level

3，有些人会创建不是屏幕大小的window（比如像iHandy的APP，他们能够覆盖statusBar）

4，有些人会创建一个透明的window供以后某个时刻使用

5，有些人会创建一个userInteractionEnable等于NO的而且exclusiveTouchs的window，我实在不知何解，但就是遇上了

要找到命中的window就要把上面的一一排除，下面贴代码（只写了逻辑，没考虑性能，借鉴了SVProgressHUD，有些情况我依然没考虑）：

{% codeblock normal_window.m %}
+ (UIWindow *)applicationFrontNormalWindow {
    UIWindow *window = nil;
    NSEnumerator *frontToBackWindows = [[[UIApplicationsharedApplication]windows]reverseObjectEnumerator];
   
    for (UIWindow *aWindow in frontToBackWindows) {
        if (aWindow.windowLevel == UIWindowLevelNormal) {
            BOOL isIt = YES;
           
            CGSize applicationFrameSize = [[UIScreenmainScreen] applicationFrame].size;
            CGSize screenSize = [UIScreenmainScreen].bounds.size;
            CGSize windowSize = aWindow.bounds.size;
           
            if (!(applicationFrameSize.width * applicationFrameSize.height == windowSize.width * windowSize.height) &&
                !(screenSize.width * screenSize.height == windowSize.width * windowSize.height)) {
                isIt = NO;
            }
           
            if (aWindow.isHidden) {
                isIt = NO;
            }
           
            if (aWindow.alpha == 0.0f) {
                isIt = NO;
            }
           
            if (aWindow.exclusiveTouch) {
                isIt = NO;
            }
           
            if (!aWindow.userInteractionEnabled) {
                isIt = NO;
            }
           
            if (isIt) {
                window = aWindow;
                break;
            }
        }
    }
   
    return window;
}
{% endcodeblock %}
