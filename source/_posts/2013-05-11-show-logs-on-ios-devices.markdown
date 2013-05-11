---
layout: post
title: "在iOS设备上显示log"
date: 2013-05-11 21:11
comments: true
categories: iOS
---

这几天和中间层同事们对接接口， 常常需要生成个链接然后发过去，超级麻烦。于是想能不能让他们在设备上自己复制个链接来测试。

因为这些链接都是有上下文的， 不能说生成就生成. 想来想去最简单的获取方法是在请求链接之前NSLog出来。

为了减少将来的重复劳动，我决定把NSLog出来的东西也在APP的一个TableView里显示一份。

要获得Log，需要用到 asl.h ，通过它可以查询符合特定条件的Log

我的查询条件比较简单：
1. 当前APP的Log
2. APP启动后的Log

```objectivec
- (void)updateLogs {
    aslmsg query = NULL, message = NULL;
    aslresponse response = NULL;
    
    query = asl_new(ASL_TYPE_QUERY);
    constchar *time = [[NSStringstringWithFormat:@"%d", _lastTime] UTF8String]; 
    asl_set_query(query, ASL_KEY_TIME, time, ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
    asl_set_query(query, ASL_KEY_FACILITY, [[[NSBundlemainBundle] bundleIdentifier] UTF8String], ASL_QUERY_OP_EQUAL);

    response = asl_search(NULL, query);
    while (NULL != (message = aslresponse_next(response))) {
        const char *content = asl_get(message, ASL_KEY_MSG);
        NSString *contentString = [[[NSStringalloc] initWithUTF8String:content] autorelease];
        [((NSMutableArray *)self.logs) addObject:contentString];
        
        const char *time = asl_get(message, ASL_KEY_TIME);
        _lastTime = atoi(time);
    }
    
    aslresponse_free(response);
    asl_free(query);
}
```

