---
layout: post
title: "防止CATransaction动画最后一帧闪动"
date: 2013-06-09 09:11
comments: true
categories: iOS 
---

一直都留意到公司里的项目中的一个动画比较奇怪，前两天终于静下来研究了一下是什么问题。

那个是一个立方体切换动画，过程很正常，就是在动画的最后闪了一下。我怀疑是动画的最后并没有保持layer的transform属性，搜索了一阵后发现果然是这样。

CAAnimation默认是动画完毕后就把动画的transform去除（kCAFillModeRemoved），因此要保持动画的最终状态需要如下设置

```
cubicAnimation.removedOnCompletion = NO;
cubicAnimation.fillMode = kCAFillModeForwards;
```
