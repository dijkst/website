---
layout: post
title: "推送技术(APNS)二——证书"
date: 2013-05-16 11:40
comments: true
categories: iOS
---
苹果的证书那叫一个多啊~~~ -_-!

这里不仅仅讲到证书，还讲到provision。

为了能正确使用Push功能，需要对App进行相应的设置，服务器也需要相应设置，因此这里牵扯到两方面的证书/provision：

> 1. 用于App的mobileprovision配置文件
> -  用于服务器和APNS验证的SSL证书

### 1. 制作/更新配置文件(.mobileprovision)

该证书作用于xcode，存储在xcode的Organizer里，用于配置App的权限。

*`如果你已经有一个开发用的.mobileprovision，在开通APNS后，应当在Organizer删除原有的.mobileprovision对应的Profile，重新制作一个再安装。（团队开发需要Agent帐号制作，制作后，团队成员可以在苹果开发者中心的Provision里面下载）
`*


*`不能使用团队开发用的.mobileprovision，必须使用指明App的.mobileprovision。即App Identifier不能带有通配符＊。`*

制作过程就不讲了，更新过程就是先删除，再创建。


官方文档：[Creating and Installing the Provisioning Profile](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW5)

### 2. 制作SSL证书和密钥(aps_developer_identity.cer)

该证书用于完成服务器与APNS的SSL连接，仅用于服务器，后面还要将其转换为服务器能用的pem文件.

过程和制作开发者证书一样，制作`.certSigningRequest`文件，在AppID里面的Push Notifications制作，即可获得SSL证书(.cer)

官方文档：[Creating the SSL Certificate and Keys](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW4)

### 3. 在服务器上安装SSL证书密钥对(.pem)

该.pem文件由第二步的`aps_developer_identity.cer`生成，包含SSL证书和密钥两个内容，作用于服务器，存放在服务器上。

到`钥匙串访问`里，找到之前安装到SSL证书，**选择证书和专用密钥两个**，右击`导出2项...`，保存为`apple_push_notification_development.p12`文件（网络上有的说是分别导出成两个p12，然后合并，没必要，直接导出成一个p12文件即可），密码不用输入即可。

{% img /images/post/2013-05-16-tui-song-ji-u-apns-er-zheng-shu/1.jpeg %}

然后到控制台，输入：

```
openssl pkcs12 -in apple_push_notification_development.p12 -out apple_push_notification_development.pem -nodes
```

注意：网络上说这个`openssl`命令时，有一个`-clcerts`参数，官方文档没有这个参数，不加这个参数也是正常使用的。

至此，服务器端的pem文件制作完成。

官方文档：[Installing the SSL Certificate and Key on the Server](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW6)

****

**dev和distribution模式下各需要一套配置和证书，操作流程一样！**