---
layout: post
title: "ARC对for-in语句的处理"
date: 2013-05-25 09:13
comments: true
categories: iOS 
---

为了加快 for in 语句的效率， 启用了ARC的编译器不会在下面句子中 retain obj

```
for (NSObject *obj in array) { … }
```

下面代码：

```
for (NSObject *obj in array) {
     obj = nil;
     …
}
```

如果编译通过，在 obj = nil 时会release 掉obj， 会崩溃。

为了安全，编译器不会让上面语句编译通过。
语句 for (NSObject *obj in array) { … } 不允许修改obj的值。

<!-- more -->

若要修改obj的值需要显式添加 __strong

```
for (NSString * __strong str in array) {
     str = [str substringToIndex:3];
     …
} // 正确
```

但这里添加 __strong 影响效率. 应该考虑是否真有必要改变数组元素的值。

