---
layout: post
title: "不要在 Initializer 和 dealloc 方法中使用 setter 和 getter"
date: 2013-12-07 22:39
comments: true
categories: iOS
---

今天和同事在争论 iOS 中，init 方法使用 `self.xxx = xx;` 是否合适的问题，以下面代码为导火索：

```objective-c
 - (id)initWithIconImage:(UIImage *)iconImage loadingImage:(UIImage *)loadingImage {
     if (self = [self init]) {
        self.iconImage = iconImage;
     }
     return self;
 }
```

他的观点是 `self.iconImage = iconImage;` 应该改为 `_iconImage = [iconImage retain];`，理由是担心内存被强制释放，那么 `self.iconImage = xxx` 将会导致崩溃。

我的观点是 `if (self = [self init])` 已经判断内存是否初始化正常了，不需要考虑 `self` 内存异常问题，所以不需要专门改成 `_iconImage = [iconImage retain];`，当然这么写也没错。

看似一个挺无聊的争论，但是最后一个技术专家站出来，贴了个 Apple 的文档： [Don’t Use Accessor Methods in Initializer Methods and dealloc](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/MemoryMgmt.pdf)

> The only places you shouldn’t use accessor methods to set an instance variable are in initializer methods and dealloc. 

看来我们争论的方向都错了，init 里面不用 setter 不是内存问题，而是** setter 可能会触发其他的逻辑**，例如重写的 setter 方法或者 KVC，将可能调用其他还没来得及 init 的变量，最终导致不可预计行为！

颠覆了以前的使用方法~~

不禁思考到其他语言，似乎都存在这种问题~~