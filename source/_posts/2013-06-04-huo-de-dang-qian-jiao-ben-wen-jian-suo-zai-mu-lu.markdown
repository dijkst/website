---
layout: post
title: "获得当前脚本文件所在目录"
date: 2013-06-04 23:35
comments: true
categories: bash
---

只用$(dirname $_)是不能获得绝对路径的， 还要跳到那个目录，再获取绝对路径，命令如下

{% codeblock script.sh %}
#!/bin/bash
DIR=`cd $(dirname $_); pwd`
echo $DIR
{% endcodeblock %}
