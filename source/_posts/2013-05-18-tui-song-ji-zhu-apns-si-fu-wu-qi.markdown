---
layout: post
title: "推送技术(APNS)四——服务器"
date: 2013-05-18 20:18
comments: true
categories: 
---

服务器有三件事要做：

- 发送消息
- 处理异常消息
- 收集卸载设备
<!-- more -->
### 发送消息

APNS服务器分为两种，sanbox（开发测试用）和production（上线服务器用）：

- sanbox:     `gateway.sandbox.push.apple.com`:2195  
- production: `feedback.sandbox.push.apple.com`:2196

自己的服务器和Apple的APNS通讯，有两种格式——简单格式与增强格式，推荐使用增强格式，能获取到异常消息ID。

增强格式：

{% img http://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Art/aps_binary_provider_2.jpg %}

从图中可以看出：

- 可以对消息进行编号，在发送异常的时候，Apple将会返回异常的编号，供服务器后续处理
- 可以设置过期时间，在时间超过后，用户还没满足接收条件，则这个消息将会被丢弃
- token长度貌似是固定的……
- 消息内容不得超过256字节
- 消息内容为JSON格式，可以为UTF8编码，也可以为Unicode编码，建议用UTF8，中文会大大减少长度

>
当发送成功，Apple不会返回任何信息  
当发送异常，Apple会返回错误信息，并关闭连接，这时候应该跳过错误的信息，重新连接，从错误信息后面继续发（Apple会忽略错误信息后面的信息，所以哪怕你信息已经发送过了，还得再发一次）

### 处理异常

异常返回格式：

{% img http://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Art/aps_binary_error.jpg %}

异常状态码：

| Status code  | Description
| ----------- | -------------
| 0 | No errors encountered
| 1 | Processing error
| 2 | Missing device token
| 3 | Missing topic
| 4 | Missing payload
| 5 | Invalid token size
| 6 | Invalid topic size
| 7 | Invalid payload size
| 8 | Invalid token
| 10 | Shutdown
| 255 | None (unknown)

### 处理卸载

用户卸载了App，我们就不需要对该用户再发送，以免浪费带宽，拖慢发送速度。

需要发起新的SSL连接到APNS获取卸载设备Token：

- sanbox: `feedback.sandbox.push.apple.com:2196`
- production: `feedback.push.apple.com:2196`

格式：

{% img http://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Art/aps_feedback_binary.jpg %}

### 常见问题：
1. 发送信息或者收集反馈时，提示`SSL_connect returned=1 errno=0 state=SSLv3 read server session ticket A: sslv3 alert certificate expired`  
原因：证书过期  
解决方法：从Apple那里重新申请SSL证书，替换即可。不影响已经上线的App。
- 发送信息过程中，突然出现`Write failed: Broken pipe`  
原因：因为某种原因，例如发送了错误的token等，导致Apple强行关闭了SSL连接。  
解决方法：跳过最后一次发送的信息，重新连接，继续发送错误信息之后的信息。
- 经常收不到  
原因：Apple不保证送达率  
解决方法：无
- 可不可以只弹出气泡，没有文本显示？  
可以，aps节点里面不要有alert。扩展出去，甚至可以发送用户完全不知道的信息，用来触发App执行某种动作，或者触发APNS的feedback功能，从而收集卸载量
- Apple发送成功没有返回状态，会不会出现是异常但是异常信息还没返回的现象，从而导致逻辑混乱？  
会出现，因此可以采取分批发送，发送一批等1秒，来检查发送状态，不用每发一条检查一下。
- feedback会返回多久前的数据？  
从上次连接feedback服务器到当前之间的数据。每次连接后都会清空数据。

官方参考文档:[Provider Communication with Apple Push Notification Service](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/CommunicatingWIthAPS.html)