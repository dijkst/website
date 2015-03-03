---
layout: post
title: "在 CALayer 上画线出现模糊的解决办法"
date: 2014-05-23 20:34
comments: true
categories: iOS
---
iOS 原生的 CALayer 不支持设置四边其中一个边框，只能设置整个边框(border)，因此想到设置一个属性来自己画线：

{%codeblock lang:objective-c %}
- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];

    // border left
    [self drawLineInContext:ctx
                      fromX:0
                      fromY:0
                        toX:0
                        toY:self.bounds.size.height
                      color:self.borderLeftColor
                      width:self.borderLeftWidth];
    // border right
    [self drawLineInContext:ctx
                      fromX:self.bounds.size.width - self.borderBottomWidth
                      fromY:0
                        toX:self.bounds.size.width - self.borderBottomWidth
                        toY:self.bounds.size.height
                      color:self.borderRightColor
                      width:self.borderRightWidth];
    // border top
    [self drawLineInContext:ctx
                      fromX:0
                      fromY:0
                        toX:self.bounds.size.width
                        toY:0
                      color:self.borderTopColor
                      width:self.borderTopWidth];
    // border bottom
    [self drawLineInContext:ctx
                      fromX:0
                      fromY:self.bounds.size.height - self.borderBottomWidth
                        toX:self.bounds.size.width
                        toY:self.bounds.size.height - self.borderBottomWidth
                      color:self.borderBottomColor
                      width:self.borderBottomWidth];
}

- (void)drawLineInContext:(CGContextRef)ref
                    fromX:(CGFloat)startX
                    fromY:(CGFloat)startY
                      toX:(CGFloat)targetX
                      toY:(CGFloat)targetY
                    color:(UIColor *)color
                    width:(CGFloat)width {
    if (color == nil || color == [NSNull class])
        return;
    CGContextMoveToPoint(ref, startX, startY);
    CGContextAddLineToPoint(ref, targetX, targetY);
    CGContextSetStrokeColorWithColor(ref, color.CGColor);
    CGContextSetLineWidth(ref, width);
    CGContextStrokePath(ref);
}
{%endcodeblock%}

再简单不过的函数了，可是画出来的线总感觉很奇怪，同样是 width=1 的线，底部总感觉比左右边框更粗，也更模糊，而且不是总是这样的，仔细一看，好像 width 也差不多相同，就是虚了点，感觉多了一点像素。

网上搜索了一下，发现有人提出在代码前加这句：

```
CGContextSetShouldAntialias(context, NO)
```

以前没用过，查了一下文档，得知是设置抗锯齿的，将抗锯齿功能关闭。试了一下，果然可以，但是，同时也发现了一点：边框不连接！也就是说，左边框超出了底边框！

我似乎有点头绪，可是到底是哪里不对劲却又说不上来！

首先抗锯齿功能可不是随便想关就关的，所以这个观点不能采纳！！

接着，左边框超出底边框，说明我底边框的 Y 值不准确！！

之前认为，画线时指明的 width 时，是向右向下延伸。看来原来理解错误了！

既然不是向右向下延伸，那就很有可能是向两边延伸了！

回头看 width=1 ，当我给它一个整形坐标时，向两边各自延伸 0.5，在抗锯齿中，可能出现 0.5 被虚化。

现在试着解决：

{%codeblock lang:objective-c %}
- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];

    // border left
    [self drawLineInContext:ctx
                      fromX:self.borderLeftWidth/2.f
                      fromY:0
                        toX:self.borderLeftWidth/2.f
                        toY:self.bounds.size.height
                      color:self.borderLeftColor
                      width:self.borderLeftWidth];
    // border right
    [self drawLineInContext:ctx
                      fromX:self.bounds.size.width - self.borderRightWidth/2.f
                      fromY:0
                        toX:self.bounds.size.width - self.borderRightWidth/2.f
                        toY:self.bounds.size.height
                      color:self.borderRightColor
                      width:self.borderRightWidth];
    // border top
    [self drawLineInContext:ctx
                      fromX:0
                      fromY:self.borderTopWidth/2.f
                        toX:self.bounds.size.width
                        toY:self.borderTopWidth/2.f
                      color:self.borderTopColor
                      width:self.borderTopWidth];
    // border bottom
    [self drawLineInContext:ctx
                      fromX:0
                      fromY:self.bounds.size.height - self.borderBottomWidth/2.f
                        toX:self.bounds.size.width
                        toY:self.bounds.size.height - self.borderBottomWidth/2.f
                      color:self.borderBottomColor
                      width:self.borderBottomWidth];
}
{%endcodeblock%}

实践证明，正常了。

这里的前提是，size 的 width 和 height 都为整数，当为小数时，还是会出现模糊~