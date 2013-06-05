---
layout: post
title: "给Octopress增加生成QR二维码功能"
date: 2013-06-05 18:38
comments: true
categories: octopress
---

花了半天总算把QRCode边栏改为了可以直接像`img`标签那样的用法，方便在blog中随时添加带有URL的QRCode。当然稍微修改一下还能在里面包含其他的信息，不过我目前没那种需求，所以就做这个支持了。

为了让它能像`img`那样的使用，因此我很干脆的直接调用了`ImageTag`类进行解析。

需要修改`plugins/image_tag.rb`：
<!-- more -->
{% codeblock image_tag.diff start:40 %}
    def render(context)
      if @img
        "<img #{@img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
+
+    def img_info
+      @img
+    end
  end
end
{% endcodeblock %}

创建插件`plugins/qrcode.rb`:

{% codeblock qrcode.rb %}
module Jekyll
  class QRCode < Liquid::Tag
    @size = ""
    @img = nil

    def initialize(tagname, markup, tokens)
        super
        if markup =~ /([^ ]+x[^ ]+ )?(.*)/i
            if !$1.nil?
                @size = $1.strip
            else
                @size = "100x100"
            end
        end
        @img = ImageTag.new('img', $2, nil)
    end

    def render(context)
        url = @img.img_info['src']
        @img.img_info['src'] = "http://chart.apis.google.com/chart?chs=#{@size}&cht=qr&chld=|0&chco=165B94&chl=#{url.start_with?('/') ? context.registers[:site].config['url']+url : url}"
        "<a href=#{url}>#{@img.render(context)}</a>"
    end
  end
end
Liquid::Template.register_tag('qrcode', Jekyll::QRCode)
{% endcodeblock %}

用法：

和`img`类似，就是多了一个大小的设置：

```{% raw %}
{% qrcode 150x150 http://github.com %}
{% endraw %}```

效果：

{% qrcode 150x150 http://github.com %}