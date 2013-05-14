---
layout: post
title: "Javascript和ObjectiveC交互"
date: 2013-05-14 20:13
comments: true
categories: iOS 
---

在iOS下UIWebview中的代码和Objective C代码交互比较蛋疼，其过程可以用下面一段描述：

	1. 制造一个点击，链接为自己定义的格式，比如 protocol://control/action?key1=value1
	2. UIWebview的delegate收到webView:shouldStartLoadWithRequest:navigationType: 分析链接，并处理
	3. 如果要返回结果则调用 [webView stringByEvaluatingJavaScriptFromString:]

要是这种交互接口不多，随便按照上面步骤写写就够用了。如果这些接口不少，我们可以利用performSelector来解放一下生产力。

<!-- more -->

上面描述中接口 protocol://control/action?key1=value1 是一个二级接口 (一般情况够用的了)，我们可以把control当作一个类（一般情况下webview的delegate一个就够了)，action当作类的方法, {key1: value1}单做方法的参数。

例如收到上面地址可以如下处理：

```objectivec

NSURL *url = [NSURL URLWithString:urlString];
if (!url) return;
NSString *host = [url host];
NSString *action = [url lastPathComponent];
NSDictionary *query = [XXXXToolkit parseURLQuery:[url query]];
    
SEL actionSelector = NSSelectorFromString([NSString stringWithFormat:@"action%@:", [self _stringToFirstUppercase:action]]);
if ([host isEqualToString:@"control"]) {
  if ([self respondsToSelector:actionSelector])
       [self performSelector:actionSelector withObject:GenerateWebViewActionDict(self, query)];
}

```

按照上面代码中的规则，webview.delegate 只要实现了actionXxx: 就可以响应protocol://control/xxx 接口.
