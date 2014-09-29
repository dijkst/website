---
layout: post
title: "让 Xcode 增加多 SDK 支持"
date: 2014-09-29 17:21
comments: true
categories: iOS Xcode
---
Xcode 更新换代的时候，也就是 iOS 升级的时候，由于总总原因，可能需要对新的 iOS 做系统兼容，但是这个过程中，往往需要同时以旧的 Xcode 进行编译与发布。

这就出现一个比较头疼的问题——Xcode 共存！

由于 Xcode 是通过 AppStore 自动更新的，往往会覆盖旧版本的 Xcode。当然，我们可以在升级 Xcode 之前将 Xcode 复制出来一个备份，再升级。这样就有两个 Xcode 了！

突然想，编译本质上就是 SDK 不同，我们直接把旧版本的 SDK 放到新版本的 Xcode 里面不就可以了吗？

想到 Xcode 的 target 里面可以设置 `Base SDK`，默认不都是 `Latest SDK` 吗？下拉列表里面还真没有旧版本的 SDK，哪怕安装了旧版本的 Xcode。

于是到旧版本 Xcode 里面找到旧版本的 SDK，放到新版本的 Xcode，重启 Xcode，即可选择 SDK 版本啦！

SDK 路径： /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs
<!-- more -->
{% img /images/post/2014-09-29-rang-xcode-zeng-jia-duo-sdk-zhi-chi/1.png %}

这种方法只适用于你安装了对应版本的模拟器。例如 Xcode6 里面不能安装 iOS6 模拟器，哪怕拿了 SDK6，也是不能用的。
