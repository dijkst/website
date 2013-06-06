---
layout: post
title: "使用Cygwin给Windows安装Linux命令行"
date: 2013-06-06 13:44
comments: true
categories: windows
---

以前也考虑过给Windows装一套命令行，因为Windows的命令行和Mac、Linux等不一样，有些功能没有，最关键都是，命令不一样~我还得去记一套新的命令~而Windows都命令行又不常用，没必要去记。

今天想远程控制家里的电脑，使用QQ的远程控制，经常发现无法发送鼠标事件到对方，于是又想到了用命令行远程登陆——当然Windows的远程登陆好多功能还是得用GUI来完成，好鸡肋啊~

上网找了一下，找到[Cygwin](http://www.cygwin.com)，看上去不错，试了下，还是能满足需求的。

首先到[Cygwin](http://www.cygwin.com)下载[setup.exe](http://cygwin.com/setup.exe)。这个其实不只是一个安装包，还负责依赖的管理。
<!-- more -->
运行这个exe会有几个提示界面，比较简单，就不截图了，简单说下大概干嘛的：

- 一个是安装位置，推荐放在`C:/Cygwin`目录下，避免路径空格和中文的影响，也注意不要放在太深的路径下面，以后你会体会到放在太深路径下的痛苦~
- 一个是选择服务器镜像，中国一般选择`.cn`的吧~
- 选择需要安装的功能和依赖，可以根据自己需要选择，默认是最小化安装。以后可以通过再次运行该exe来进行安装其他的功能

安装完之后，会看到有一个`Cygwin Terminal`，打开即可以用Linux命令行了，例如`ls`、`pwd`等。

可是只能在这个终端里面运行，显然不符合我们的需求。

接下来，需要配置环境变量：`系统`->`高级系统设置`->`环境变量`，在`Path`里面加上`;C:\Cygwin\bin`，注意那个分号，是为了和前面的隔离。

{% img /images/post/2013-06-06-shi-yong-cygwingei-windowsan-zhuang-linuxming-ling-xing/1.jpg %}

打开命令提示符，再试试`ls`便发现可以用了~