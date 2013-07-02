---
layout: post
title: "使用CocoaAsyncSocket发送TCP/UDP消息"
date: 2013-07-02 17:19
comments: true
categories: 
---

习惯上每次使用一个类库的功能，我第一时间想到的都是Google那个类库的使用例子。这不是一个好习惯，这次我下载了CocoaAsyncSocket的代码，找了好一阵没找到满意的例子。灰心丧气之余想到很多用到我写的代码的人们也是不看文档，不看注释的。他们给我带来了巨大的困扰，而我现在也不看别人的注释和文档，假如CocoaAsyncSocket的作者要为我服务的话，那他肯定也会吐血不止。

于是，我决定自力更生，从代码注释里找找我需要功能的用法。

我需要的功能是，用TCP或者UDP发送一些数据给服务器，不用关心服务器是否收到数据。

下面例子，只是TCP的发送过程，UDP请自行看注释。

<!-- more -->

TCP连接发送过程中会出现的问题：

>1，Host， 端口什么的可能是无意义的值，还没开始connect就已经失败了  
>2，远程地址连不上，或者中途断线，算作connect失败  
>3，我上面需要的功能只是发送数据，发送完就没事了，需要在发送完后断开连接  

考虑完上面问题，得到的代码如下：

{% codeblock tcp_sender.m %}

#import "GCDAsyncSocket.h"

#define kTCPSenderTag 123

@interface TCPSender()
@property (nonatomic, retain) GCDAsyncSocket *socket;
@end

@implementation TCPSender

+ (void)sendMessage:(NSString *)msg toHost:(NSString *)host port:(UInt16)port {
    [[self alloc] initWithMessage:msg host:host port:port];
}

- (id)initWithMessage:(NSString *)msg host:(NSString *)host port:(UInt16)port {
    self = [super init];
    if (self) {
        if (!msg || !host || !port) {
            [self release];
            return nil;
        }
        self.socket = [[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()] autorelease];
        
        NSError *error = nil;
        if (![self.socket connectToHost:host onPort:port error:&error]) {
            self.socket.delegate = nil;
            [self release];
            self = nil;
        } else {
            NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
            [self.socket writeData:msgData withTimeout:30 tag:kTCPSenderTag];
        }
    }
    
    return self;
}

- (void)dealloc {
    if (self.socket && [self.socket isConnected]) {
        [self.socket disconnect];
    }
    self.socket = nil;
    [super dealloc];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self.socket disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self release];
}

@end

{% endcodeblock %}
