---
layout: post
title: 在已经存在的iOS项目中集成OCTest
date: 2013-05-29 15:58
comments: true
categories: iOS
---
创建新项目的时候，我们都能勾选单元测试那个选项，但是往往在iOS都没有写单元测试的习惯，所以经常不勾这个勾。今天突然需要往原来没单元测试的项目里面添加OCTest，google了一下，还挺麻烦的说……

首先添加一个Target，随便取个名字，例如`unitTests`，在`Build Phases`的`Target Dependencies`里面添加需要测试的项目：

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/1.jpg %}

在`Build Settings`->`Bundle Loader`，设置为`$(BUILT_PRODUCTS_DIR)/待测试的Target名称.app/待测试的Target名称`

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/2.jpg %}

<!-- more -->

在`Build Settings`->`Test Host`，设置为`$(BUNDLE_LOADER)`

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/3.jpg %}

最后回到主项目的target(不是test)，设置`Symbols Hidden by Default`在`Debug`时为`NO`

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/4.jpg %}

到这里基本完成了。

发现Scheme里面多了一个unitTests，可是Apple自动生成的却没有这个啊，我们test的时候都是用test功能，而不是运行这个unitTests项目啊？

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/5.jpg %}

试着调整了一下了Scheme，就可以了。

先删除unitTests的Scheme：

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/6.jpg %}

将主项目的test设置为unitTests：

{% img /images/post/2013-05-29-xiang-yi-jing-cun-zai-de-iosxiang-mu-zhong-ji-cheng-octest/7.jpg %}

这样就能用Test来进行单元测试了！
