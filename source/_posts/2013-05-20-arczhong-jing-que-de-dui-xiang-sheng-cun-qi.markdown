---
layout: post
title: "ARC中精确的对象生存期"
date: 2013-05-20 22:55
comments: true
categories: iOS 
---

从WWDC 2012 Session 712 Asynchronous design patterns with blocks gcd and xpc 里看到的，用其它形式没有重现，暂且记下来。

代码

```objectivec
- (void)logWithData:(dispatch_data_t)data {
	void *buf;
	dispatch_data_t map;

	map = dispatch_data_create_map(data, &buf, NULL);
	NSLog(@"%@", [NSString stringWithUTF8String:buf]);
}
```

将会被编译为  

```objectivec
- (void)logWithData:(dispatch_data_t)data {
	void *buf;
	dispatch_data_t map;

	map = dispatch_data_create_map(data, &buf, NULL);
	objc_release(map);
	NSLog(@"%@", [NSString stringWithUTF8String:buf]);
}
```

这种情况往往会造成崩溃，需要对对象的生存时间进行严格定义

```objectivec
- (void)logWithData:(dispatch_data_t)data {
	void *buf;
	dispatch_data_t map __attribute__((objc_precise_lifetime));

	map = dispatch_data_create_map(data, &buf, NULL);
	NSLog(@"%@", [NSString stringWithUTF8String:buf]);
}
```

上面代码将会编译成

```objectivec
- (void)logWithData:(dispatch_data_t)data {
	void *buf;
	dispatch_data_t map __attribute__((objc_precise_lifetime));

	map = dispatch_data_create_map(data, &buf, NULL);
	NSLog(@"%@", [NSString stringWithUTF8String:buf]);
	objc_releas(map);
}
``` 

刚才我试了下面一段代码，发现没有崩溃，不知道里面哪里多了autorelease

```objectivec
char *buffer = malloc(30);
NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:30 freeWhenDone:YES];
    
buffer[0] = 'a';
buffer[1] = 0;
NSLog(@"%s", buffer);
```

理论上应该是编译成这样：

```objectivec
char *buffer = malloc(30);
NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:30 freeWhenDone:YES];
objc_releas(data);    
buffer[0] = 'a';
buffer[1] = 0;
NSLog(@"%s", buffer);
```

很奇怪。
