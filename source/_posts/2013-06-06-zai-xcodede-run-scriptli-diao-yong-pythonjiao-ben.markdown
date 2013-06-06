---
layout: post
title: "在XCode的Run Script里调用python脚本"
date: 2013-06-06 20:00
comments: true
categories: iOS bash
---

昨天把同事的打包文档的python脚本改了一下，早上我在终端上运行没出问题，打算加到XCode里成为打包 SDK 的脚本的一部分，开始了漫长折腾...

首先我的 python 脚本是被一个bash脚本调用的

{% codeblock generate_doc.sh %}
#!/bin/bash

CURRENT_FOLDER=`cd $(dirname $0); pwd`
DOC_FOLDER="$CURRENT_FOLDER/../doc"
python3 "${CURRENT_FOLDER}/generate_doc/generate_doc.py" $DOC_FOLDER
{% endcodeblock %}

我在`Run Script`里
```
sh ${PRJ_ROOT}/dev/scripts/generate_doc.sh
```

提示两个错误  
1，python3找不到  
2，xxxx/../doc 是个文件夹  

<!-- more -->

对于第二个问题我刚开始没有理会，`xxxx/../doc`就是文件夹嘛，有什么疑问的。

检查了一下`Run Script`运行时的环境变量发现python3的目录没有被包含在内， 于是在`Run Script`里添加了一下

```
PATH="${PATH}:/usr/local/bin"
sh ${PRJ_ROOT}/dev/scripts/generate_doc.sh
```

提示两个错误  
1，在open(xxx).read() UnicodeDecodeError   
2，xxxx/../doc 是个文件夹  


对于第一个问题，可以显式设置encoding来解决（后来发现不是很有必要）

```
open(md_path, 'r', encoding='utf-8').read()
```

第二个问题再次被我忽略，再次运行

还是提示两个错误  
1，print(xxx) UnicodeDecodeError  
2，xxxx/../doc 是个文件夹  

这次不能忍第二个问题了，弄了很久，杯具地发现 `$DOC_FOLDER`要加双引号才行

```
python3 "${CURRENT_FOLDER}/generate_doc/generate_doc.py""${DOC_FOLDER}"
```

现在剩下一个错误  
1，print(xxx) UnicodeDecodeError

找了很久才解决，需要在环境变量中添加个Python编码的设置: `export PYTHONIOENCODING=UTF-8` ，最后执行python的脚本如下

{% codeblock generate_doc.sh %}
#!/bin/bash

CURRENT_FOLDER=`cd $(dirname $0); pwd`
DOC_FOLDER="$CURRENT_FOLDER/../doc"

export PYTHONIOENCODING=UTF-8

python3 "${CURRENT_FOLDER}/generate_doc/generate_doc.py""${DOC_FOLDER}"
{% endcodeblock %}

这样，我的打包脚本就能执行起来了。
