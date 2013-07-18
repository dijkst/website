---
layout: post
title: "让 Rails 支持 Response 数据 GZip 压缩"
date: 2013-07-18 18:46
comments: true
categories: ruby iOS
---
做网络请求时，一直想用 GZip 对 JSON 进行压缩后传输，但是一直没空弄，听说不难。这两天试了一下，果然不难。

在 Rails 项目根目录下的`config.ru`，加入`use Rack::Deflater`，如下：

{% codeblock config.ru lang:ruby %}
# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
use Rack::Deflater
run Wending::Application
{% endcodeblock %}

重启服务器即可。

如何判断是否生效了？那就来个测试。
<!-- more -->
先看看没有 GZip 压缩是什么样子的：

``` bash
$ curl http://localhost:4100/ # 域名和端口根据自己实际更改
```

再看看使用了 GZip 压缩是什么样子的：

``` bash
$ curl http://localhost:4100/ -H "Acc-Encoding: gzip, deflate" # 域名和端口根据自己实际更改
```

我们会看到采用了 GZip 后，输出的是乱码的，也不难看出，短了不少~这样就代表 GZip 设置成功了！

那该怎么用呢？

刚刚测试的时候其实都说明了：只需要在 request header 里面注明`Acc-Encoding: gzip, deflate`即可。其实说白了，是否用 GZip 压缩，还是客户端决定，客户端要非压缩的数据，服务器就给非压缩的数据；客户端要压缩的数据，服务器就给压缩的数据。默认当然是不压缩啦。

那在 iOS 上该如何用呢？

以 ASIHTTPRequest 为例：

``` objective-c
request = [ASIHTTPRequest requestWithURL:...];
[request setAllowCompressedResponse:YES];
```

请求的时候设置`allowCompressedResponse`为`YES`即可。

##### 可能遇到的问题：

如果服务器返回的不是 JSON 等数据，而是企图下载文件，且客户端依然请求 GZip，还是会被压缩（虽然这个压缩可能会越压越大）。强制不压缩，就是忽略那个 request header，可以这么做：

``` ruby
    def check_update_data
        send_file(file, :x_sendfile => true)
	    headers['Content-Length'] = File.size(file)
	    request.env['HTTP_ACCEPT_ENCODING'] = nil
    end
```

将`HTTP_ACCEPT_ENCODING`设置为`nil`即可。