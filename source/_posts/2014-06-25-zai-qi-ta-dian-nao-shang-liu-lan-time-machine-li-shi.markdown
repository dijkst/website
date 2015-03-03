---
layout: post
title: "在其他电脑上浏览 Time Machine 历史"
date: 2014-06-25 22:44
comments: true
categories: Mac
---
Time Machine 一般总是在后台默默的运行，一般用得也比较少，就怕有时候用上还真挽回了一条命啊~

但是一直有一个疑问，换了一台 Mac，那如何去找原来那台上面的备份呢？

今天就给我遇上了，由于换了一台 MacBook，很多东西都没迁移过来，不想用还原的方式，想全新安装新的 Mac，于是出现或多或少遗漏一些数据迁移。经过一段时间后，旧 Mac 也处理了，因为觉得要的东西都差不多迁移完成了，但是往往不可预料的发现遗漏了。这时候就想访问原来的那台电脑的 Time Machine 备份磁盘。

可是如何让 Mac 访问另外一台电脑的磁盘呢？折腾了好久都没找到功能，一启动 Time Machine 就进入历史浏览，压根就没机会让我选择其他磁盘。

上网搜索了一下，官网有给出一个答复：[How to access Time Machine from Another Computer?](https://discussions.apple.com/thread/1702971)

试了一下，发现这个功能藏得可真深：

* 先把 Time Machine 这个 APP 固定到 Dock 栏（任务栏），方法就是把 Finder 里面的 APP 拖到 Dock~
* 右击 Dock 上面的 Time Machine，选择`浏览其他 Time Machine 磁盘`

值得注意的是，由于不是自己的备份磁盘，存在访问权限问题，有些文件是访问不了的。因此我们平时文件尽可能存放在其他路径下，不要放在个人路径下。
