---
layout: post
title: "SQLite加密版本SQLCipher编译过程——服务器"
date: 2013-06-05 10:42
comments: true
categories: sqlite
---

很早以前就接触到了SQLCipher，当时已经很完善了，不过很悲剧的发现，SQLCipher版本间不兼容，每更新一次都得重新编译一次，那叫一个悲剧啊~

>
SQLCipher is an open source library that provides transparent, secure 256-bit AES encryption of SQLite database files.

虽然SQLCipher是开源的，但是仅仅是开源的而已——你要自己编译，不想自己编译就得付费购买已经编译好的二进制文件~~

木有钱，只好自己编译了。这里讲服务器端的编译过程。其实所谓的服务器，指的是Linux系的命令行核心的编译，例如centos、MacOSX等系统。
<!-- more -->
编译过程很简单：

#### 1. 下载源代码

官方源代码：[https://github.com/sqlcipher/sqlcipher](https://github.com/sqlcipher/sqlcipher)

#### 2. 编译

进入源代码目录：

{% codeblock lang:bash %}
./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
make
{% endcodeblock %}

理论上需要OpenSSL库，可能是系统自带，也可能是之前装过，总之就是我还没遇到OpenSSL库找不到的现象~

官方说明：[http://sqlcipher.net/introduction/](http://sqlcipher.net/introduction/)

>
**注意**：由于SQLCipher是SQLite的另外一个版本，所以为了不影响系统的SQLite，和其他SQLCipher版本间的兼容问题，所以不能将编译生成的直接install到系统，可以做符号链接等方式来管理二进制版本。

#### 3. 验证编译是否成功

创建一个加密的数据，密码是`aaa`：

{% codeblock lang:bash %}
$ ./sqlite3 test.sqlite
SQLite version 3.7.14.1 2012-10-04 19:37:12
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> PRAGMA key = 'aaa';
sqlite> create table a(ind int);
sqlite> .tables
a
sqlite> .quit
{% endcodeblock %}

尝试不输入密码，直接读取数据库，理论上是读不到数据，或者报错：

{% codeblock lang:bash %}
$ ./sqlite3 test.sqlite
SQLite version 3.7.14.1 2012-10-04 19:37:12
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .tables
sqlite> .quit
{% endcodeblock %}

尝试正确输入密码，应该成功读取：

{% codeblock lang:bash %}
$ ./sqlite3 test.sqlite
SQLite version 3.7.14.1 2012-10-04 19:37:12
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> PRAGMA key = 'aaa';
sqlite> .tables
a
sqlite> .quit
{% endcodeblock %}

上面三个流程都过说明编译成功！