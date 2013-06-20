---
layout: post
title: "小心浮点数转整数发生的意外行为"
date: 2013-06-19 20:45
comments: true
categories: iOS 
---

事情是这样的，我程序里有一个字符串常量`@"4.81"`

我需要把它转成`@"481"`, 事实上从意义上说，并不是去掉小数点，而是把`@"4.81"`的`4.81`乘以`100`再转成整数，最后转回字符串。

于是我就这样做了

```
[NSString stringWithFormat:@"%d", (NSInteger)([@"4.81" doubleValue] * 100)];
```

结果却是

```
@"480"
```

所以，好危险，遇到这种情况还是要检查过才行。至于解决办法… 
<!-- more -->
尝试用以下代码:

```
[NSString stringWithFormat:@"%.0f", [@"4.81" doubleValue] * 100]
```

成功输出`481`。但是又尝试了以下代码:

```
[NSString stringWithFormat:@"%.0f", [@"4.815" doubleValue] * 100]
```

理论上会四舍五入，输出`482`，但是实际上输出`481`。这是因为在`[@"4.815" doubleValue]`系统中存储的是`4.8149999`，乘以100后四舍五入就是`481`，而不是`482`。

因此这个方法不可靠，暂时可以用下面四舍五入的方法：

```
[NSString stringWithFormat:@"%d", (NSInteger)([@"4.81" doubleValue] * 100 + 0.5)]
```
