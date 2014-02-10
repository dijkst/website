---
layout: post
title: "Git 同步远程 Tags"
date: 2014-02-10 11:35
comments: true
categories: Git
---
一个项目做久了，Tag 越来越多，大多时候也不怎么关心 Tag，只有需要找以前的版本才会翻查一下。

一不留神，发现服务器上的 Tag 好像被人整理了一下，而本地的 Tag 依然是老版本的，查了一下，似乎没有很好的方法保证服务器和本地的 tags 自动同步。

只好每个客户端自行本地清理自己的 tags 了：

git 1.7以上版本可以直接使用命令：

```
git fetch origin --prune --tags
```

git 1.7及以下版本需要先删除所有 tags 再 fetch 一次：
```
git tag -l | xargs git tag -d
git fetch
```