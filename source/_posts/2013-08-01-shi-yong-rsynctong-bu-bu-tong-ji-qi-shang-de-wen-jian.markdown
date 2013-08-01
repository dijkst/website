---
layout: post
title: "使用rsync同步不同机器上的文件"
date: 2013-08-01 16:28
comments: true
categories: linux
---


实验系统：Ubuntu

我根据文章[rsync 简明教程](http://waiting.iteye.com/blog/643171)试验成功后，发现Ubuntu自带有启动rsync守护程序的功能，于是决定使用Ubuntu自带的开机启动rsync方式，查看```/etc/init.d/rsync```里的代码可以知道它指定了rsync配置文件的路径：```/etc/rsyncd.conf```，如果没有这个路径，rsync daemon不会启动。


于是创建一个/etc/rsyncd.conf 在里面填上：

```
uid = root
gid = root
use chroot = yes
max connections = 10
syslog facility = local5
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log

[rsyncsrc]
        path = /home/vagrant/rsyncsrc
        list = yes
        ignore errors = yes
        auth users = admin
        secrets file = /etc/rsync/rsync.secrets
        comment = test rsync source
```

上面的参数中，我对```use chroot```印象比较深刻，如果```use chroot``` 指定为true，那么rsync在传输文件以前首先chroot到path参数所指定的目录下。这样做的原因是实现额外的安全保护，缺点是需要root权限，并且不能备份指向外部的符号连接所指向的目录文件。默认为true(摘抄来的)

<!-- more -->

根据配置文件中写的路径，我创建一个权限600 ```/etc/rsync/rsync.secrets```, 并填上：

```
admin:whoisyou
```

要通过init.d启动rsync，还需要把```/etc/default/rsync```里的

```
RSYNC_ENABLE=false
```

改为

```
RSYNC_ENABLE=true
``` 

至于/etc/default这个文件夹的用处在super user 上找到的解释是：
>The files in this dir basically contains configuration parameters. For example, if you have a service at /etc/init.d/test, the script first look at /etc/default/test before starting/stopping the test service, searching for config parameters.


改完后通过命令 ```/etc/init.d/rsync start``` 启动即可 （以后重启会自动启动）


上面是服务器端的配置

===

下面是客户端：

首先建立一个权限600的密码文件，如~/rsync.pas 里面填上：

```
whoisyou
```


输入命令：

```
rsync -azh --password-file=~/rsync.pas admin@127.0.0.1::rsyncsrc ~/target/
```

我是在本机试验的，所以填127.0.0.1


