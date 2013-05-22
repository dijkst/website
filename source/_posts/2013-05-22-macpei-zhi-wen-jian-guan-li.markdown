---
layout: post
title: "MAC配置文件管理"
date: 2013-05-22 23:24
comments: true
categories: OSX
---

现在我有两台MAC，一台在公司用，一台在家里用。没什么工作和娱乐的区别，两台电脑的设置基本一样，但每个东西设置两次是很麻烦的事。我的解决办法是使用网盘和软链接还有github，下面说说网盘可以做啥:

我注册了Dropbox， 快盘，Copy，SkyDrive。   
Dropbox服务器在国外，速度不快，但信得过，用它存放重要文件，代码，系统配置；  
快盘速度快，但资料随时可能被国家收编，只能用它存放照片，和对别人无益，对自己无害的东西；  
Copy， SkyDrive，还在考虑能放什么。

我觉得比较多重复的有vim和shell的配置

对于Vim
在Dropbox文件夹下
新建个VimSetting 文件夹，关于vim的配置文件都放在里面

```sh
$ ls Dropbox/PreciousCode/VimSetting/
gvimrc     vim     vimrc
```

<!-- More -->
·
在$HOME目录下使用软链接

```
.gvimrc -> /Users/ENZO/Dropbox/PreciousCode/VimSetting/gvimrc 
.vim -> /Users/ENZO/Dropbox/PreciousCode/VimSetting/vim 
.vimrc -> /Users/ENZO/Dropbox/PreciousCode/VimSetting/vimrc 
```

对于shell
在Dropbox文件夹下新建TermConfigs里面添加一些别名设置，常用函数脚本

```
$ ls Dropbox/PreciousCode/TermConfigs/
alias.sh     functions.sh
```

在Dropbox文件夹下新建scripts文件夹，添加一些自己写的方便的脚本文件。

```
$ ls Dropbox/PreciousCode/scripts/
code_line.sh
```

在~/.bash_profile 里导入TermConfigs的脚本

```
source "$HOME/Dropbox/PreciousCode/TermConfigs/functions.sh"
…
```

把scripts添加到环境变量

```
add_path "$HOME/Dropbox/PreciousCode/scripts" # add_path 请看http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there/39995#39995
```


   

