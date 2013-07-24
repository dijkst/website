---
layout: post
title: "使用 drawInRect 绘图时丢失清晰度解决方法"
date: 2013-07-24 18:40
comments: true
categories: iOS
---

有一个小需求，就是需要动态修改一张图片上面的数字，当然不能事先准备那么多数字的图片，所以就需要动态的在一个图片上面画数字。

需求很简单，我首先这么实现：

``` objective-c
    UIImage *image = [UIImage imageNamed:@"assemble-a"];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
```

画出来的图怎么看都模糊，刚开始没在意，以为就是这样的……

然后给美女设计师看效果，直接回了一句——怎么这么糊……
<!--more-->
额，好像确实是越看越糊……

既然是模糊了，极有可能是 scale 没有对。凡事先问 Google，还真有同样的问题的：

[drawInRect: losing Quality of Image resolution](http://stackoverflow.com/questions/14729021/drawinrect-losing-quality-of-image-resolution)

解决方法就是用

```
UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
```

代替

```
UIGraphicsBeginImageContext(image.size);
```
