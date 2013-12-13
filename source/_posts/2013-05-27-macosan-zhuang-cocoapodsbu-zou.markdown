---
layout: post
title: "MacOS安装Cocoapods步骤"
date: 2013-05-27 19:24
comments: true
categories: OSX
---

Cocoapods本身就是ruby的一个gem，所以没啥特殊的安装方式，但是很多iOS或者OSX开发人员都对ruby不熟悉，所以简单的总结一下。

分为一下几步骤：

> 1. 安装Command Line Tool (CLT) 
> - 安装Homebrew
> - 安装rvm
> - 安装ruby
> - 安装cocoapods

好像要装不少东西……其实都是一层一层的，CLT是必装的，homebrew管理一些依赖，rvm实现ruby虚拟机。已经安装有的可以跳过，也可以重新按照上面的步骤安装。

__请先确保XCODE为最新版本！！！__

#### 安装Command Line Tool （CLT）

在Xcode的`Preferences`->`Downloads`->`Components`里面可以直接安装，也可以到[Apple](https://developer.apple.com/downloads/index.action)单独下载安装。

<!-- more -->
MacOSX 10.9 系统下，还需要执行命令行`xcode-select --install`！

#### 安装Homebrew

```
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
```

安装完成之后，执行诊断，检查是否有异常

```
$ brew doctor
```

正常是不会有问题的，如果提示存在旧版本的XCODE，最好删除，否则容易混乱CLT。

接下来执行：

```
$ brew update
$ brew tap homebrew/dupes
```

#### 安装rvm

```
$ \curl -L https://get.rvm.io | bash -s stable --autolibs=enable
```

很慢，如果你是第一次装的话，要装各种依赖……

#### 安装ruby

选择合适的ruby版本，选择cocoapods比较兼容的版本装，例如装2.0版本：

```
$ rvm install 2.0
```

#### 安装cocoapods

```
$ gem install cocoapods
```

完工！
