---
layout: post
title: "推送技术(APNS)三——客户端"
date: 2013-05-17 22:38
comments: true
categories: 
---


客户端基本实现很简单，只需要注册一下remote notification，然后重载几个通知状态调用函数即可.

注意事项:
>
1. 模拟器无法进行APNS调试,只能在真机上调试.
- 真机调试时,必须选择带有APNS功能的`.mobileprovision`(不能是团队证书,即证书的`Application Identifiers`不能带有通配符`＊`）
<!-- more -->
{% codeblock AppDelegate.m lang:objectivec %}

// registe remote notification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     // Let the device know we want to receive push notifications
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
     
     // other code
     return YES;
}

#pragma mark -
#pragma mark APN
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
     NSLog(@"My token is: %@", deviceToken);
     // send token to server
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
     NSLog(@"Failed to get token, error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"收到推送： %@",userInfo);
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        UIAlertView* alert = [[UIAlertViewalloc] initWithTitle:@"推送通知"
                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:@"更新状态",nil];
        [alert show];
        [alert release];
    }
}
{% endcodeblock %}

### 可能遇到的错误：

1. 控制台输出：  
```Error in registration. Error: Error Domain=NSCocoaErrorDomain Code=3000 UserInfo=0x1179f0 "未找到应用程序的“aps-environment”的权利字符串"```  
   原因：使用的配置文件不具有APNS功能，可以用Windows的记事本打开`.mobileprovision`，看看是不是缺少了`<key>aps_environment</key>`，如果是，则说明证书确实缺少APNS功能。  
   解决方法：1.如果你是先创建`.mobileprovision`，然后再开通APNS功能，应该删除原有的`.mobileprovision`，在苹果那重新创建一个`.mobileprovision`，这样，新的`.mobileprovision`就带有APNS功能。简单的说，就是你用的是没带APNS功能的配置文件；
2. （1）的方法后，问题依旧，发现文本内还是没有`<key>aps_environment</key>`节点，可能是因为你的`.mobileprovision`是团队证书或者通用证书，判断方法就是看`Application Identifiers`是否带有通配符`*`号。必须针对指定的App创建专门的`.mobileprovision`才会带有APNS功能。原理很简单，就是你只是对一个App开通APNS，通用证书是通用类型的，即功能最小化，所以是不具有APNS节点的。