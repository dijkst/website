---
layout: post
title: "在 iOS6 系统的 iPad 设备中打开 AppStore 下载页面"
date: 2014-01-16 14:58
comments: true
categories: iOS
---
以前做 iPhone 的开发时，经常需要做一个功能，例如“更新 App”，点击之后跳转到 AppStore 的下载页面，然而，今天发现了一个问题：

我的跳转地址是 `itms-apps://itunes.apple.com/app/id438865278?mt=8`，这个地址是服务器返回的，我以前也是这么写的，应该没有问题。

测试的妹子说，在 iOS6 上面，该地址只能打开 AppStore 的首页，不能进入下载页面，在 iOS5 和 iOS7 中都正常，iOS6 所有设备均失败（iPad3、4、mini 等等）。

我尝试在 Safari 中输入该地址，发现也确实无法让 AppStore 进入下载界面。

在 iPhone 的 iOS6 中，正常。

因此估计是 iPad 的问题，上网搜了一下，发现这个问题是普遍存在的 —— 只在 iOS6 的 iPad 设备中出现！
<!-- more -->
参考地址： https://discussions.apple.com/thread/4420524?tstart=0

`It apparently works with https, but http and itms-apps fail.`

将 `itms-apps` 替换为 `https` 即可正常。

最后经过测试，使用 `https` 在 iPhone、iPad 上均可正常使用，不会跳转 Safari，完全不需要使用 `itms-apps`！