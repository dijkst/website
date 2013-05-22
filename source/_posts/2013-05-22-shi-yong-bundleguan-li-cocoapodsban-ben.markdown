---
layout: post
title: "使用Bundle管理Cocoapods版本"
date: 2013-05-22 18:15
comments: true
categories: ruby
---

Cocoapods将Rails的Gem思想成功的迁移到了OSX中，让iOS和MacOS也能快速的管理第三方依赖。

然而，用久了发现一个很尴尬的问题——Cocoapods还不是很完善，因此更新频率很大，虽然我经常更新，但是他对旧版本的Cocoapods兼容性并不好。

例如，我有一个项目是用0.16版本的Cocoapods开发的，过了一段时间，需要对这个项目进行更新，在运行`pod install`时会出现各种问题，原因是我用新版本的pod来安装旧版本的`podfile.lock`，虽然官方也尽量在兼容旧版本，但不可避免还是会出现各种问题，例如——用法过期并移除……

这时候想到，进行Rails开发中，用Bundle进行Gem管理，而Cocoapods本身就是一个Gem，那能不能用Bundle来管理Cocoapods呢？
<!-- more -->

我们先试着在项目根目录下，创建Gemfile文件：

{% codeblock Gemfile lang:objectivec %}
gem 'cocoapods', '~> 0.16.0'
{% endcodeblock %}

执行`bundle install`:

{% codeblock %}
$ bundle install
Fetching source index from http://ruby.taobao.org/
Resolving dependencies...
Using rake (10.0.4)
Using i18n (0.6.1)
Using multi_json (1.7.3)
Using activesupport (3.2.13)
Using addressable (2.3.4)
Using colored (1.2)
Using escape (0.0.4)
Using multipart-post (1.2.0)
Using faraday (0.8.7)
Using json (1.7.7)
Using faraday_middleware (0.9.0)
Using hashie (2.0.5)
Using netrc (0.7.7)
Using octokit (1.24.0)
Using open4 (1.3.0)
Using xcodeproj (0.5.5)
Installing cocoapods (0.16.4)
Using bundler (1.3.5)
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endcodeblock %}

用`gem list`看看本地有哪几个版本cocoapods：

{% codeblock %}
$ gem list cocoapods

*** LOCAL GEMS ***

cocoapods (0.19.1, 0.16.4)
{% endcodeblock %}

现在试试能否用旧版本的cocoapods：

```
$ pod --version
0.16.4
```

退出项目文件夹，去其他文件夹试试会不会自动切换到新版本:

```
$ cd ..
$ pod --version
0.19.1
```

成功！

发现有人直接用`pod --version`没效果，可能是他不是使用最新版本的RVM，则需要手动调用bundle：

```
$ bundle exec pod --version
0.16.1
```