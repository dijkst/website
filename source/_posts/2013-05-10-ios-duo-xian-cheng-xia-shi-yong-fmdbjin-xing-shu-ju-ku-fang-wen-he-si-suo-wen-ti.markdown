---
layout: post
title: "[iOS]多线程下使用FMDB进行数据库访问和死锁问题"
date: 2013-05-10 19:07
comments: true
categories: iOS Sqlite
---
***
多线程访问数据库本身就存在分险，容易形成脏数据。幸好FMDB这个第三方库支持了多线程访问，从而解决了脏数据问题。然而也带来了死锁问题……

先看看FMDB的多线程机制的原理。

看了它的代码，发现其实很简单的一个思路，但是实现起来还真不容易，难怪花了好长时间才支持多线程！！它是生成一个请求队列，将一次事务进行封装放在队列中，只有一个事务完成了，才会进行下一个事务。这就出现了一种现象：如果某一个请求耗时过大，将会导致所有请求堵塞！！同时也要求：同一个线程中，在一个事务完成之前，不能进行下一个事务。

<!-- more -->

举个例子：

    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeUpdate:sql]) {
            [self increaseCounter];
        }
    }];
    
这个方法在执行sql成功后，将会调用increaseCounter方法：

    - (void)increaseCounter {
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeQuery:@"insert ..."];
        }];
    }

而increaseCounter方法中又增加一个事务，去执行另外一个sql语句。

结果出现了这种现象：

第一个事务没结束，第二个事务等待第一个事务结束，而第一个事务等待第二个事务返回状态，出现死锁！！

正确的写法：

    __block BOOL status = NO;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        status = [db executeUpdate:sql];
    }];
    if (status) {
        [self increaseCounter];
    }
     
也就是将两个事务拆开。

***
##总结：

   * 多线程编程应该尽量采用事务队列
   * 事务队列与Mysql等的锁数据库效果相似，即事务完成前，其他线程以及本线程不能访问数据库（***注意不是锁表，是锁库***）
   * 一个事务内应该只包含数据库请求语句，不应当包含其他逻辑
   * 一个请求不应耗时过长，否则出现线程等待