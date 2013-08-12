---
layout: post
title: "中国地图坐标偏移算法整理"
date: 2013-08-09 15:04
comments: true
categories: iOS 算法
---
最近被天朝的火星坐标搞得头昏脑胀的，真不知道这个所谓的火星坐标到底是防国外军事打击的呢，还是为难我们这些苦逼的开发人员的~真的能防止国外非法使用吗？难道美国国防部也用 Google 地图？？？

暂且不考虑这个不是我等草民能考虑的问题，先看看如何解决这种火星坐标导致的地图坐标不匹配的问题~

首先，在天朝，所有的坐标都必须经过国家测绘局进行偏移，这里的坐标，包括某个景点的坐标，甚至是整张地图的坐标（地图是由多个建筑、地形坐标构成）！！而偏移算法目前在正规渠道来说是保密的，根据小伙伴们的观察，偏移量是不一定的，我就在想，一个正方形的建筑，经过这种偏移，会不会偏出一个梯形出来…………

既然地图是偏移的，并非真实的地图，那么我们往地图上面标注景点或者建筑的时候，甚至标注用户当前位置时，就不能直接用 GPS 输出的真实值，而是得将 GPS 坐标也进行相同算法的偏移，然后放在地图上就感觉没偏移了——大家一起做漂移~

所以市面上，就出现了一种现象，水货的 GPS 设备（有的手机也是），做定位的时候输出真实值，而中国市面上的地图，例如 Google 地图、百度地图等，都是必须遵守国家测绘局规定进行偏移的。所以出现了定位不准的问题。而行货 GPS 设备，由于是正规渠道，里面内置了偏移芯片，所以输出的定位坐标是偏移过的，放在 Google 地图上面就正常了！
<!-- more -->

其实，从正常的方式使用，例如买行货，用 Google、百度地图等，都是没偏移问题。如果遇到需要收集景点的坐标，也得用行货 GPS 设备，那么皆大欢喜！然而，有一个悲剧的问题发生了——香港、澳门不属于大陆，Google 还是采用真实的地图，而百度认为是中国，所以采用偏移的地图，这样就混乱了——同一个香港坐标，在百度和 Google 里面看到的差距很大~

当然咯，最好的办法是，在香港和澳门收集坐标的时候，两套坐标都收集……可是事实上，我们经常没办法弄到……

这时候就需要转换算法，将两种坐标算法进行互相转换——更悲剧的是，这个算法，真实坐标->火星坐标是保密的，火星坐标->真实坐标是不可逆的！！！

不过，网络上，不知道从哪里出来了一套算法，我试了一下，还挺准的~

{% codeblock lang:objective-c %}
//
// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

//
// World Geodetic System ==> Mars Geodetic System
BOOL outOfChina(CLLocationCoordinate2D coordinate)
{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}

double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)
CLLocationCoordinate2D wgs2gcj(CLLocationCoordinate2D coordinate) {
    if (outOfChina(coordinate)) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
}

// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)
CLLocationCoordinate2D gcj2wgs(CLLocationCoordinate2D coordinate) {
    if (outOfChina(coordinate)) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = wgs2gcj(coordinate);
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}


const double x_M_PI = M_PI * 3000.0 / 180.0;

// 火星坐标系 (GCJ-02) -> 百度坐标系 (BD-09)
CLLocationCoordinate2D bd_encrypt(CLLocationCoordinate2D coordinate) {
    double x = coordinate.longitude, y = coordinate.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
}

// 火星坐标系 (GCJ-02) <- 百度坐标系 (BD-09)
CLLocationCoordinate2D bd_decrypt(CLLocationCoordinate2D coordinate) {
    double x = coordinate.latitude - 0.0065, y = coordinate.longitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta));
}
{% endcodeblock %}

百度坐标系是在火星坐标系上进行二次加密，所以当从真实坐标转换到百度坐标时，需要先转换为火星坐标，再转换为百度坐标。

火星坐标转换为真实坐标是大概值，因为算法本身是不可逆的！