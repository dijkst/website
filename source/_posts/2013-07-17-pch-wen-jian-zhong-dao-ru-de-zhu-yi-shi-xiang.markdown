---
layout: post
title: "PCH 文件中进行全局 import 的注意事项"
date: 2013-07-17 19:05
comments: true
categories: iOS
---
pch 文件可是个好东西，把常用的定义或者 import 放在 pch 中，这样在不用在项目中再引用和定义了，即可以做到全局 macro，又可以作为全局 import 用。

然而最近在用 DTCoreText 和 ZipArchive 时，发现无论怎么调试，都无法编译通过，出现类似很多类名 not found，甚至是 NSString 都未找到！！

后来研究了好久，原来这两个库有用 C 和 C++ 编译。而 pch 文件对于 C 的文件一样有效。试想一下，C 的代码引用 OC 的代码，会出现什么？当然是编译失败！

问题找到了，如何让 C 的文件编译的时候不引用 OC 的代码呢？

突然想起我们经常看到一个这个定义：

```
#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>
#endif
```

看来这个`ifdef __OBJC__`就是用于判断是否是 OC 文件的！！我以前一直以为这个宏是判断项目是否用 OC 编译的！！当时还纳闷，啥时候会出现不用 OC 写 iOS 项目？

因此，在原来的 pch 里面适当的将代码用这个`ifdef __OBJC__`包起来，就解决了 C 的文件引入 OC 代码的问题！！