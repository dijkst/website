---
layout: post
title: "字符编码"
date: 2013-05-09 10:28
comments: true
categories: 
---

## GB18030
变长, 1, 2, 4 字节
```	
单字节，其值从0到0x7F。
双字节，第一个字节的值从0x81到0xFE，第二个字节的值从0x40到0xFE（不包括0x7F）。
四字节，第一个字节的值从0x81到0xFE，第二个字节的值从0x30到0x39，第三个字节从0x81到0xFE，第四个字节从0x30到0x39。
```
* kCFStringEncodingGB_18030_2000

### 兼容 GB2312
GB2312 变长，1，2字节

```
“高位字节”使用了0xA1-0xF7（把01-87区的区号加上0xA0）
“低位字节”使用了0xA1-0xFE（把01-94加上0xA0）。
```

<!-- more -->

## UTF-16

UTF-16以两个字节为编码单元

```
UTF-16以16位为单元对UCS进行编码。
对于小于0x10000的UCS码，UTF-16编码就等于UCS码对应的16位无符号整数。
对于不小于0x10000的UCS码，定义了一个算法。
不过由于实际使用的UCS2，或者UCS4的BMP必然小于0x10000，所以就目前而言，可以认为UTF-16和UCS-2基本相同。

但UCS-2只是一个编码方案，UTF-16却要用于实际的传输，所以就不得不考虑字节序的问题。
```

在解释一个UTF-16文本前，首先要弄清楚每个编码单元的字节序。

```
在UCS编码中有一个叫做"ZERO WIDTH NO-BREAK SPACE"的字符，它的编码是FEFF。而FFFE在UCS中是不存在的字符，所以不应该出现在实际传输中。UCS规范建议我们在传输字节流前，先传输字符"ZERO WIDTH NO-BREAK SPACE"。 
这样如果接收者收到FEFF，就表明这个字节流是Big-Endian的；如果收到FFFE，就表明这个字节流是Little-Endian的。因此字符"ZERO WIDTH NO-BREAK SPACE"又被称作BOM。 
```

MAC 默认 UTF-16 little endian

Foundation 里的 NSUTF16StringEncoding 会自动加上BOM

## UTF-8

1-4字节，目前不会有5，6位的字符

```
对于UTF-8编码中的任意字节B，如果B的第一位为0，则B为ASCII码，并且B独立的表示一个字符;
如果B的第一位为1，第二位为0，则B为一个非ASCII字符（该字符由多个字节表示）中的一个字节，并且不为字符的第一个字节编码;
如果B的前两位为1，第三位为0，则B为一个非ASCII字符（该字符由多个字节表示）中的第一个字节，并且该字符由两个字节表示;
如果B的前三位为1，第四位为0，则B为一个非ASCII字符（该字符由多个字节表示）中的第一个字节，并且该字符由三个字节表示;
如果B的前四位为1，第五位为0，则B为一个非ASCII字符（该字符由多个字节表示）中的第一个字节，并且该字符由四个字节表示;
```

详细 -- [维基百科](http://zh.wikipedia.org/wiki/UTF-8)

BOM : EF BB BF

## Latin-1,2,3…16 (8859-x)

1字节，欧洲各种文字

```
NSISOLatin1StringEncoding
kCFStringEncodingISOLatin2 = 0x0202,	/* ISO 8859-2 */
kCFStringEncodingISOLatin3 = 0x0203,	/* ISO 8859-3 */
kCFStringEncodingISOLatin4 = 0x0204,	/* ISO 8859-4 */
kCFStringEncodingISOLatinCyrillic = 0x0205,	/* ISO 8859-5 */
kCFStringEncodingISOLatinArabic = 0x0206,	/* ISO 8859-6, =ASMO 708, =DOS CP 708 */
kCFStringEncodingISOLatinGreek = 0x0207,	/* ISO 8859-7 */
kCFStringEncodingISOLatinHebrew = 0x0208,	/* ISO 8859-8 */
kCFStringEncodingISOLatin5 = 0x0209,	/* ISO 8859-9 */
kCFStringEncodingISOLatin6 = 0x020A,	/* ISO 8859-10 */
kCFStringEncodingISOLatinThai = 0x020B,	/* ISO 8859-11 */
kCFStringEncodingISOLatin7 = 0x020D,	/* ISO 8859-13 */
kCFStringEncodingISOLatin8 = 0x020E,	/* ISO 8859-14 */
kCFStringEncodingISOLatin9 = 0x020F,	/* ISO 8859-15 */
kCFStringEncodingISOLatin10 = 0x0210,	/* ISO 8859-16 */
```

## BIG-5

繁体中文，中文两个字节，英文一个字节

中文 “高位字节”使用了0x81-0xFE，“低位字节”使用了0x40-0x7E，及0xA1-0xFE

* kCFStringEncodingBig5_E    // Taiwan Big-5E standard
* kCFStringEncodingBig5_HKSCS_1999 // Big-5 with Hong Kong special char set
