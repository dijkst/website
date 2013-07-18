---
layout: post
title: "让Xcode静态库不需要使用者link framework"
date: 2013-07-18 20:06
comments: true
categories: iOS
---

有些情况下需要创建静态库给别人用，如果静态库里要引用很多 framework ，会给别人带来麻烦；特别是那些要设置为 optional 的 framework ，很容易导致在低版本系统上崩溃。

一般情况下，静态库中大部分的 Objective C framework 可以通过下面的方法来避免让使用者 link 。

>首先，要测试一个 framework 是否已经被 link 到了程序中, 对于 Objective C 的库可以通过 NSClassFromString 检测出来;  
>如果那个 framework 没有被 link 进来，则使用 dlopen 加载 framework;  
>使用 framework 中的类时，依然需要通过 NSClassFromString 。

整个过程所需的代码大致如下：

``` objective-c
#include <stdlib.h>
#include <dlfcn.h>

if (!(NSClassFromString(@"ASIdentifierManager"))) {
	dlopen("/System/Library/Frameworks/AdSupport.framework/AdSupport", RTLD_LOCAL);
}

NSObject *manager = [NSClassFromString(@"ASIdentifierManager") performSelector:NSSelectorFromString(@"sharedManager")];
if (manager) {
	[manager performSelector:NSSelectorFromString("@advertisingIdentifier")];
	...
}
```

对于 Objective C 的类，使用起来毫无压力，有时还需要使用到 framework 中的常量。如果用到的常量不多，可以在 dlopen 后马上把需要的常量导进来，供之后使用。

``` objective-c
void *handle = dlopen("core telephony framework path", RTLD_LOCAL);
NSString *_k_CTCallStateDialing = *(void **)dlsym(handle, "CTCallStateDialing");
```

还有一些我也不知怎么导入，例如枚举值，对于系统的 framework 我对它的稳定性比较有信心。通过看代码可以看出枚举值，可以直接使用枚举值对应的整数

``` objective-c
// 1 == MessageComposeResultSent
if (result == 1) {
	....
}
```


