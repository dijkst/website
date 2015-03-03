---
layout: post
title: "GoAgent 提示 SSLError:EOF occurred in violation of protocol 解决办法"
date: 2014-05-24 21:31
comments: true
categories: 
---

用 GoAgent 很长一段时间了，感觉好鸡肋，为啥，因为经常出现这个错误：

```
SSLError: [Errno 8] _ssl.c:504: EOF occurred in violation of protocol
```

网上一搜一大把这个问题，就是没有解决的。

直接后果是大部分 https 的网站上不了！

今天无意中发现有人居然解决了：

https://code.google.com/p/goagent/issues/detail?id=11385

解决方法：

打开 keychain 把 GoAgent 证书从 login 移动到 system 里！
