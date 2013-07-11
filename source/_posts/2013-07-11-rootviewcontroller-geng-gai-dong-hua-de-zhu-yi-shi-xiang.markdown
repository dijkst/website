---
layout: post
title: "rootViewController 更改动画的注意事项"
date: 2013-07-11 20:17
comments: true
categories: iOS
---
`Window`的`rootViewController`属性在 iOS5 之后都期望被设置，因为旋转等原因，controller 控制 View 比自己控制 View 更安全。

但是突然出现一个需求，需要更换主`Window`的`rootViewController`，那如何做`UIView`动画呢？

``` objective-c
[UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                  duration:0.4
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    [[[UIApplication sharedApplication].delegate window] setRootViewController:vc];
                }
                completion:NULL];
```

咋看之下没啥问题，运行起来也没问题。能成功实现替换为新的`vc`。

然后出现一个很诡异的问题——如果设备是横的，新的`vc`对应的`View`会有一个旋转的动画，导致动画混乱，甚至很奇怪的动画。

刚开始以为是`vc.view`加载太慢，后来没解决。Google 了一下，发现有人解决了。将上面的代码改为：

``` objective-c
[UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                  duration:0.4
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    BOOL oldState = [UIView areAnimationsEnabled];
                    [UIView setAnimationsEnabled:NO];
                    [[[UIApplication sharedApplication].delegate window] setRootViewController:vc];
                    [UIView setAnimationsEnabled:oldState];
                }
                completion:NULL];
```