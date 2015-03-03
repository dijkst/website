---
layout: post
title: "MacOS常用QuickLook扩展插件收集"
date: 2013-06-29 12:22
comments: true
categories: OSX
---

MacOS里有一个相当人性化的功能——QuickLook，选中一个文件，不用打开它，只用按一下空格键，立即可以看到文件内容或者信息，相当快。然而悲剧的是，并不是所有文件类型都被支持的！！如果按了空格键，发现只是显示文件图标，只好很无奈的在按空格键把它关了，再去把文件打开，早知道就直接打开文件了~忧伤啊~

以前导出搜索不错的插件，最近发现，用 `brew cast` 可以完全帮我们安装。

请移步到 https://github.com/sindresorhus/quick-look-plugins

小知识：让 QuickLook 也能选择文字，只需要在终端中执行以下命令：

```
defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder
```
