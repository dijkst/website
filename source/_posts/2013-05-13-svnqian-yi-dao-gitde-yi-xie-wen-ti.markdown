---
layout: post
title: "SVN迁移到GIT的一些问题"
date: 2013-05-13 17:02
comments: true
categories: 
---

今天准备把一个SVN的项目迁移到Git上，看了一下网络上的迁移方法

    git svn clone svn://192.168.1.108:9999/ --no-metadata -A user.txt --trunk=trunk --tags=tags --branches=branches myProject
    
，看上去好像不难，试了一下，发现一个很悲剧的事情：SVN的结构不是标准结构-_-#

    - branches
        - A1
        - A2
        - B1
        - B2
    - trunkA
    - trunkB
    - tagsA
    
居然将两个项目放在了一起，就不能使用标准的方法了 T\^T

<!-- more -->

    git svn clone svn://192.168.1.108:9999/yanzi/ --no-metadata -A user.txt --trunk=trunkA --tags=tagsA --branches=branches --ignore-refs=refs/remotes/A.* myProject
    
通过ignore-refs设置来过滤，总算可以SVN2GIT……

但是，悲剧了，遇到这种错误：

```
Use of uninitialized value $u in substitution (s///) at /usr/share/git-core/perl/Git/SVN.pm line 2098.
Use of uninitialized value $u in concatenation (.) or string at /usr/share/git-core/perl/Git/SVN.pm line 2098.
``` 

Google一下，修改了SVN.pm文件，把

```
$u =~ s!^\Q$url\E(/|$)!! or die 
        "$refname: '$url' not found in '$u'\n"; 
```

替换为

```
if(!$u) { 
        $u = $pathname; 
}else { 
        $u =~ s!^\Q$url\E(/|$)!! or die 
        "$refname: '$url' not found in '$u'\n"; 
} 
```

再试一试，又挂了…… T\^T

```
'tempfile' can't be called as a method at /usr/share/git-core/perl/Git/SVN.pm
```

又Google，修改SVN.pm，把

```
File::Temp->tempfile
```

改完

```
File::Temp::tempfile
```

总算完成了~

据说是git版本的bug，有的人说更新Git可以修复，但是我这个Git是Apple自动维护的，也就懒得更新了，先记着吧~