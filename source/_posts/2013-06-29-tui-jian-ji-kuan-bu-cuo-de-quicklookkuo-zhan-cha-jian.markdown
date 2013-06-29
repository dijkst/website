---
layout: post
title: "MacOS常用QuickLook扩展插件收集"
date: 2013-06-29 12:22
comments: true
categories: MacOS
---

MacOS里有一个相当人性化的功能——QuickLook，选中一个文件，不用打开它，只用按一下空格键，立即可以看到文件内容或者信息，相当快。然而悲剧的是，并不是所有文件类型都被支持的！！如果按了空格键，发现只是显示文件图标，只好很无奈的在按空格键把它关了，再去把文件打开，早知道就直接打开文件了~忧伤啊~

上网找了一下，找到一些不错的QL扩展，分享一下。但是在分享以前，先说一下怎么安装扩展~

将下载好的QL扩展放在`/资源库/QuickLook/`下，注销系统即可生效，不想注销的，可以用终端命令：

```
qlmanage -r
```

下面看看都有些啥好扩展：
<!-- more -->
#### [QuicklookStephen](https://github.com/whomwah/qlstephen)

快速浏览文本类型的文件。有的文本类型的文件，后缀可能不是txt等，QL默认是无法识别的，这个扩展能够将其他后缀的文本类型文件也显示出文本内容。支持`README`、`INSTALL`、`CapFile`、`CHANGELOG`等等，支持手动添加后缀和黑名单。

#### [qlimagesize](https://github.com/downloads/Nyx0uf/qlImageSize/qlImageSize.qlgenerator.zip)

在浏览图片的时候，能在查看窗口的顶部标题栏显示图片的尺寸和体积大小。

#### [Quick Look JSON](http://www.sagtau.com/quicklookjson.html)

高亮并格式化JSON文件。

#### [MobileProvision](http://www.macmation.com/blog/2011/10/quicklook-plugin-for-mobile-provision-files/)

可以快速预览.mobileprovision内的信息以及过期时间等信息。

#### [Suspicious Package Quick Look plugin](http://www.mothersruin.com/software/SuspiciousPackage/)

快速查看.pkg的内容，包括权限、安装脚本和包含的文件。

#### [BetterZip](http://macitbetter.com/BetterZip-Quick-Look-Generator/)

ZIP, TAR, GZip, BZip2, ARJ, LZH, ISO, CHM, CAB, CPIO, RAR, 7-Zip, DEB, RPM, StuffIt's SIT, DiskDoubler, BinHex, MacBinary等格式预览。