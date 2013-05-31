---
layout: post
title: "viewWithTag的搜索逻辑"
date: 2013-05-31 19:13
comments: true
categories: iOS
---
`- [UIView viewWithTag:]`这个方法经常用，一般也没出现什么问题，最近在一个项目中，采用动态增加subview的方式构造View，同时对特殊的view做了tag。问题出来了，整个view里面有好多相同tag的subview！！那么这个方法到底返回哪个view呢？他的实现逻辑又是什么？

查了一下官方文档：

> This method searches the current view and all of its subviews for the specified view.

从这句话，很容易判断出：

* 会首先判断当前view的tag是否匹配
* 会递归搜索子视图

这个不难理解，就不多说了，我们来个例子分析我遇到的问题：
<!-- more -->
{% codeblock AppDelegate.m lang:objectivec %}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addViewToView:self.view];
    NSLog(@"%@", [self.view recursiveDescription]);
    NSLog(@"找到view: %@", [self.view viewWithTag:520]);
    NSLog(@"-----------------------");
    
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    [self addViewToView2:self.view];
    NSLog(@"%@", [self.view recursiveDescription]);
    NSLog(@"找到view: %@", [self.view viewWithTag:520]);
    NSLog(@"-----------------------");
    
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    [self addViewToView3:self.view];
    NSLog(@"%@", [self.view recursiveDescription]);
    NSLog(@"找到view: %@", [self.view viewWithTag:520]);
    NSLog(@"-----------------------");
    
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
    [self addViewToView4:self.view];
    NSLog(@"%@", [self.view recursiveDescription]);
    NSLog(@"找到view: %@", [self.view viewWithTag:520]);
}

/* 递归添加520的view*/
- (void)addViewToView:(UIView *)view {
    static NSUInteger index = 0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [v setTag:520];
    [view addSubview:v];
    index++;
    if (index < 3)
        [self addViewToView:v];
}

/* 递归，每层增加两个view，第一个view为520tag，第二个为其他view
   往第一个view加子视图 
 */
- (void)addViewToView2:(UIView *)view {
    static NSUInteger index2 = 0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [v setTag:520];
    [view addSubview:v];
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [view addSubview:v2];
    index2++;
    if (index2 < 3)
        [self addViewToView2:v];
}

/* 递归，每层增加两个view，第一个view为520tag，第二个为其他view
   往第二个view加子视图 
 */
- (void)addViewToView3:(UIView *)view {
    static NSUInteger index3 = 0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [v setTag:520];
    [view addSubview:v];
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [view addSubview:v2];
    index3++;
    if (index3 < 3)
        [self addViewToView3:v2];
}


/* 递归，每层增加两个view，第一个为其他view，第二个view为520tag，
   往第一个view加子视图 
 */
- (void)addViewToView4:(UIView *)view {
    static NSUInteger index4 = 0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [view addSubview:v];
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [v2 setTag:520];
    [view addSubview:v2];
    index4++;
    if (index4 < 3)
        [self addViewToView4:v];
}

{% endcodeblock %}

输出信息：

```
<UIView: 0xb045e60; frame = (0 0; 320 460); autoresize = W+H; layer = <CALayer: 0xb045f10>>
   | <UIView: 0x10c3bed0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0x10c3bf30>>
   |    | <UIView: 0x10c3c790; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0x10c3c720>>
   |    |    | <UIView: 0x10c3c7f0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0x10c3c850>>
找到view: <UIView: 0x10c3bed0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0x10c3bf30>>
-----------------------
<UIView: 0xb045e60; frame = (0 0; 320 460); autoresize = W+H; layer = <CALayer: 0xb045f10>>
   | <UIView: 0xb045860; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048310>>
   |    | <UIView: 0xb045a80; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb045ae0>>
   |    |    | <UIView: 0xb0485f0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb045ba0>>
   |    |    | <UIView: 0xb048650; frame = (0 0; 100 100); layer = <CALayer: 0xb0486b0>>
   |    | <UIView: 0xb045b10; frame = (0 0; 100 100); layer = <CALayer: 0xb045b70>>
   | <UIView: 0xb0458c0; frame = (0 0; 100 100); layer = <CALayer: 0xb045920>>
找到view: <UIView: 0xb045860; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048310>>
-----------------------
<UIView: 0xb045e60; frame = (0 0; 320 460); autoresize = W+H; layer = <CALayer: 0xb045f10>>
   | <UIView: 0xb0486e0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048740>>
   | <UIView: 0xb048770; frame = (0 0; 100 100); layer = <CALayer: 0xb0487d0>>
   |    | <UIView: 0xb048800; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048860>>
   |    | <UIView: 0xb0488b0; frame = (0 0; 100 100); layer = <CALayer: 0xb048910>>
   |    |    | <UIView: 0xb048940; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb0489a0>>
   |    |    | <UIView: 0xb0489f0; frame = (0 0; 100 100); layer = <CALayer: 0xb048a50>>
找到view: <UIView: 0xb0486e0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048740>>
-----------------------
<UIView: 0xb045e60; frame = (0 0; 320 460); autoresize = W+H; layer = <CALayer: 0xb045f10>>
   | <UIView: 0xb048ac0; frame = (0 0; 100 100); layer = <CALayer: 0xb048b20>>
   |    | <UIView: 0xb048be0; frame = (0 0; 100 100); layer = <CALayer: 0xb048c40>>
   |    |    | <UIView: 0xb048d20; frame = (0 0; 100 100); layer = <CALayer: 0xb048d80>>
   |    |    | <UIView: 0xb048dd0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048e30>>
   |    | <UIView: 0xb048c90; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048cf0>>
   | <UIView: 0xb048b50; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048bb0>>
找到view: <UIView: 0xb048dd0; frame = (0 0; 100 100); tag = 520; layer = <CALayer: 0xb048e30>>

```

我们可以获得以下信息：

1. 递归搜索是从父视图开始搜索
- 递归搜索是**深度优先算法**——优先进入子视图搜索，再搜索同级视图

第二点是重点，我一直以为搜索是广度优先的，这种搜索逻辑和我理解完全相反啊！！！