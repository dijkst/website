---
layout: post
title: "Key-Value编程笔记——基础"
date: 2013-06-24 19:40
comments: true
categories: iOS
---
Key-Value Coding是一种非直接访问对象属性的机制，使用字符串来定位属性，而不是直接调用属性的getter或者setter等访问器。

如果属性是简单类型，例如scalar, String或者Boolean，将会转换为`NSNumber`处理。如obj的a属性是Boolean：

{% codeblock lang:objective-c %}
[obj valueForKey:@"a"] // 获得@YES
[obj setValue:@YES forKey:@"a"] // 传递NSNumber，而不是YES
{% endcodeblock %}

Key必须遵循OC命名规范：ASCII编码，以小写字母开头，不含空格。

keyPath是将key组合后的一种方便用法，用点分割属性名:
<!-- more -->
{% codeblock lang:objective-c %}
[obj valueForKeyPath:@"a.b"]
// 等效于
[[obj valueForKey:@"a"] valueForKey:@"b"]

[obj setValue:@"xx" forKeyPath:@"a.b"]
// 等效于
[[obj valueForKey:@"a"] setValue:@"xx" forKey:@"b"]
{% endcodeblock %}

`valueForKey:`找不到给定的Key，会调用`valueForUndefinedKey:`，默认该方法会抛出 `NSUndefinedKeyException`，可以重载这个方法来进行自己的逻辑。

`valueForKeyPath:`本质上调用每个返回值的`valueForKey:`，所以当某层找不到也会调用`valueForUndefinedKey:`。

`setValue:forKey:`找不到给定的Key，会调用`setValue:forUndefinedKey:`，和`ValueForUndefiedKey:`一样，默认抛出`NSUndefinedKeyException`。

`setValuesForKeysWithDictionary:`是一种批量`setValue:forKey:`，如果Value是`nil`，需要用`NSNull`代替，系统会自动转换。

{% highlight 如果将一个简单类型设置为`nil`，例如将Boolean类型设置为`nil`，会调用`setNilValueForKey:`，该方法默认抛出`NSInvalidArgumentException`，可以重载该方法，来将`nil`转换为合适的值。%}

参考文档：Apple [Key-Value Coding Programming Guide](https://developer.apple.com/library/mac/#documentation/cocoa/conceptual/KeyValueCoding/Articles/KeyValueCoding.html#//apple_ref/doc/uid/10000107-SW1)