---
layout: post
title: "小心浮点数转整数发生的意外行为"
date: 2013-06-19 20:45
comments: true
categories: iOS 
---

事情是这样的，我程序里有一个字符串常量 @"4.81"

我需要把它转成 @"481", 事实上从意义上说，并不是去掉小数点，而是把@"4.81" 的 4.81乘以100 再转成整数，最后转回字符串。

于是我就这样做了

```
[NSString stringWithFormat:@"%d", (NSInteger)([@"4.81" doubleValue] * 100)];
```

结果却是

```
@"480"
```

所以，好危险，遇到这种情况还是要检查过才行。至于解决办法… 对于我的情况， 可以用四舍五入的方法

```
[NSString stringWithFormat:@"%d", (NSInteger)([kYouMiWallSDKVersion doubleValue] * 100 + 0.5)]
```

