---
layout: post
title: "可变长度对象在KVO中的实现"
date: 2013-06-21 16:40
comments: true
categories: iOS
---

KVO是降低代码耦合度的一种很有效的方法，以往我都是对某个实例的属性进行监控，获取他的变化情况。其本质上是监控属性的地址的变化。然而对于可变长度的对象，如`NSMutableArray`和`NSMutableDictionary`等，向这种对象进行添加成员，其的地址不会发生变化，普通的KVO方法自然就不能用了。该如何监控可变长度对象的内容变化呢？

Google了一下，又查阅了官方文档，目前有两种方法：

- 手动实现insert方法和remove方法 [文档](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/AccessorConventions.html#//apple_ref/doc/uid/20002174-178830-BAJEDEFB)
- 调用系统的`mutableValueForKey:`方法，自动触发KVO [文档](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSKeyValueCoding_Protocol/Reference/Reference.html#//apple_ref/occ/instm/NSObject/mutableArrayValueForKey:)

第一种方法具体实现逻辑还不是很清楚，有待进一步深入学习Key-Value编程。

第二种方法使用了Proxy。

<!-- more -->
来个Demo：

{% codeblock lang:objective-c %}
@interface AA : NSObject

@property (strong, nonatomic) NSMutableArray *a;

@end

@implementation AA

- (id)init {
    if (self = [super init]) {
        self.a = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSomeObjects {
    [self.a addObject:@"a"];
    [self.a addObject:@"b"];
}

@end

@interface BB : NSObject

@property (strong, nonatomic) AA *aClass;

@end

@implementation BB

- (id)init {
    if (self = [super init]) {
        self.aClass = [[AA alloc] init];
        [self.aClass addObserver:self
                      forKeyPath:@"a"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
        [self.aClass addSomeObjects];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"object: %@ keyPath: %@ property: %p", object, keyPath, self.aClass.a);
}
@end

{% endcodeblock %}

我们会发现observe方法无效，无任何log输出。

采用第一种手动方法：

将AA的实现修改为以下：

{% codeblock lang:objective-c %}
@implementation AA
- (id)init {
    if (self = [super init]) {
        self.a = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertObject:(NSObject *)object inAAtIndex:(NSUInteger)index {
    [self.a insertObject:object atIndex:index];
}
- (void)insertA:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self.a insertObjects:array atIndexes:indexes];
}
- (void)removeAAtIndexes:(NSIndexSet *)indexes {
    [self.a removeObjectsAtIndexes:indexes];
}

- (void)addSomeObjects {
    [self insertObject:@"a" inAAtIndex:[self.a count]];
    [self insertA:@[@"b"] atIndexes:[NSIndexSet indexSetWithIndex:[self.a count]]];
    [self removeAAtIndexes:[NSIndexSet indexSetWithIndex:0]];
}
@end

{% endcodeblock %}

得到Log：

```
object: <AA: 0xfd06730> keyPath: a property: 0x6c20dd0
object: <AA: 0xfd06730> keyPath: a property: 0x6c20dd0
object: <AA: 0xfd06730> keyPath: a property: 0x6c20dd0
```

会不会感觉很麻烦？不能直接用`[self.a addObject:@"a"]`而得必须用`[self insertA:@[@"a"] atIndexes:[NSIndexSet indexSetWithIndex:[self.a count]]]`或者`[self insertObject:@"a" inAAtIndex:[self.a count]];`！没办法，KVO会在这两个方法内的方法执行完成后触发，所以必须显式调用。

*这三个方法不是必须全部实现，需要哪个实现哪个方法*

第二种方法就比较简单了，在原有基础上，只是修改`addSomeObjects`方法：

{% codeblock lang:objective-c %}
- (void)addSomeObjects {
    [[self mutableArrayValueForKey:@"a"] addObject:@"a"];
    [[self mutableArrayValueForKey:@"a"] removeObject:@"a"];
}
{% endcodeblock %}

```
object: <AA: 0x6e61990> keyPath: a property: 0x6e94b90
object: <AA: 0x6e61990> keyPath: a property: 0x6e94d50
```

然而，不难发现，对象地址变了！！！！`0x6e94b90`=>`0x6e94b50`，虽然可能一般不出现问题，但是如果你之前把`a`赋值给另外一个变量，那么两者就不是同一个了，这是很危险的一种行为！

怎么办？把上面的两个方法合并起来用~~最后AA就变成了这样的代码：

{% codeblock lang:objective-c %}
@interface AA : NSObject

@property (strong, nonatomic) NSMutableArray *a;

@end

@implementation AA
- (id)init {
    if (self = [super init]) {
        self.a = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertObject:(NSObject *)object inAAtIndex:(NSUInteger)index {
    [self.a insertObject:object atIndex:index];
}
- (void)insertA:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self.a insertObjects:array atIndexes:indexes];
}
- (void)removeAAtIndexes:(NSIndexSet *)indexes {
    [self.a removeObjectsAtIndexes:indexes];
}
- (void)addSomeObjects {
    [[self mutableArrayValueForKey:@"a"] addObject:@"a"];
    [[self mutableArrayValueForKey:@"a"] removeObject:@"a"];
}
@end
{% endcodeblock %}

这种写法将系统的自动KVO手动实现了，所以不再是重新生成一个对象`a`，因此地址不变！