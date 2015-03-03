---
layout: post
title: "SourceTree 中链接注释中的 issue id 到Kelude"
date: 2014-05-30 16:30
comments: true
categories: Git
---
Mac 上用 Git 时，SourceTree 简直就是非常方便的神器。

今天突发奇想，每次看到 git 的 commit message 里面有 fix #xxxxx 的时候，总是不知道到底修复的是啥。必须到 issue 里面去搜索 ID 才能找到，很少麻烦！

在 SourceTree 中逛了一圈，发现在项目的 Settings 中有一个 `Commit Text Replacements` 功能，很有可能是我正在找寻的~

上网搜索了一下，官方提供了说明：[Link to Bitbucket issue tracker from commits](https://confluence.atlassian.com/display/SOURCETREEKB/Link+to+Bitbucket+issue+tracker+from+commits)

经过测试，这里的 Replacements 功能并不是在提交的时候替换，而是在 SourceTree 显示注释的时候进行替换。因此并不会影响我们的最终提交~
