---
layout: post
title: "Nagios4+Nginx+Ganglia配置"
date: 2013-11-29 20:14
comments: true
categories: linux 
---


本文参考 [Nagios on nginx & Ubuntu 12.04](http://idevit.nl/node/93)

最近需要在服务器上配置一个Nagios用于检测服务器的异常情况并报警，我们的服务器已经搭建好Ganglia，Nagios主要用于报警通知。现在最新的Nagios的版本已经到了4.0.2, 而apt-get只有nagios3, 并且似乎还自动装了apache, 这不是我们需要的。看了一些资料后得知一般情况下 nagios 应该安装在 /usr/local/nagios 文件夹下，这样安装插件的时候会少很多麻烦。 而按照ubuntu的习惯，配置文件我决定放在 /etc/nagios 文件夹里。

首先介绍一下安装上面的配置需要了解的nagios的各个文件夹或者文件的用途

> /usr/local/nagios/libexec 是nagios插件存放的位置， nagios配置中有个USER1指的就是这个文件夹的路径  
> /etc/nagios/nagios.cfg 是nagios的主配置文件，它会引用到很多其它的配置文件，比如下面说到的objects文件夹下的所有配置  
> /etc/nagios/objects 文件夹里有可以配置命令的 commands.cfg 可以配置联系方式的 contacts.cfg  
> /etc/nagios/servers 这是我需要的一个文件夹，用于配置需要监控的服务的，需要在 /etc/nagios/nagios.cfg里取消掉相应行的注释  


### 下面是我的安装配置过程

#### 1. 安装依赖

```
	apt-get install libperl-dev libpng12-dev libgd2-xpm-dev build-essential php5-gd wget libgd2-xpm
```
	
##### 2. 创建 nagios 用户， 和 nagcmd 用户组

```
	adduser --system --no-create-home --disabled-login --group nagios
	groupadd nagcmd
	usermod -G nagcmd nagios
	usermod -a -G nagcmd www-data
```

<!-- more -->
#### 3. 在一个临时文件夹下下载解压 nagios 源码以及插件源码， 最新的源码可以在 [nagios.org](http://www.nagios.org/download/) 上找到

```
	cd ~/tmp
	mkdir nagios
	cd nagios
	wget http://jaist.dl.sourceforge.net/project/nagios/nagios-4.x/nagios-4.0.2/nagios-4.0.2.tar.gz
	wget https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
	tar xvf nagios-3.4.4.tar.gz
	tar xvf nagios-plugins-1.4.16.tar.gz
```
	
#### 4. 配置 nagios 源码并编译安装

```
	cd ~/tmp/nagios/nagios-4.0.2
	
	./configure --prefix /usr/local/nagios \
	--sysconfdir=/etc/nagios \
	--with-nagios-user=nagios \
	--with-nagios-group=nagios \
	--with-command-user=nagios \
	--with-command-group=nagcmd
	
	make all
	make install
	make install-config
	make install-commandmode
```
	
	安装参考文章，需要 make install-init 的， 但我发现我这个版本的 init 脚本用不了， 在[All the geeky things](http://blacks3pt3mb3r.wordpress.com/tag/etcinit-dnagios-20-cant-open-etcrc-dinit-dfunctions/) 这个博客里找到了一个稍微修改就可以使用的脚本。将它放到 /etc/init.d/nagios 即可
	
#### 5. 设置网站登录密码，这个不是必须的详情请看参考文章
#### 6. 设置nagios的log的存放位置

```
	mkdir /var/log/nagios
	touch /var/log/nagios/nagios.log
	chown nagios:nagios /var/log/nagios
	vi /etc/nagios/nagios.cfg # 修改nagios.log的路径
```
#### 7. 安装插件, 插件将被安装在 /usr/local/nagios/libexec 里面

```
	cd ~/tmp/nagios/nagios-plugins-1.5
	./configure --with-nagios-user=nagios --with-nagios-group=nagios
	make && make install
```
	
#### 8. 测试nagios的配置，并设置开机启动
	
```
	/usr/local/nagios/bin/nagios -v /etc/nagios/nagios.cfg
```

如果没有问题，会提示一切正常

```
	chmod +x /etc/init.d/nagios
	update-rc.d -f nagios defaults
```

到这里，只需要 service nagios start 就可以启动nagios了。想要在网页上看到nagios，需要安装nginx 和 fcgi

```
	apt-get install nginx
	apt-get install spawn-fcgi fcgiwrap
```

这时需要确认php-fpm监听的地址，从配置文件/etc/php5/fpm/pool.d/www.conf中可以找到  
还需要确认/var/run/fcgiwrap.socket 是否存在，如果不存在则要另外找出这个socket的位置



	

```
# pidfile: /var/nagios/nagios.pid
#
### BEGIN INIT INFO
# Provides:      nagios
# Required-Start:   $local_fs $syslog $network
# Required-Stop:   $local_fs $syslog $network
# Short-Description:   start and stop Nagios monitoring server
# Description:      Nagios is is a service monitoring system
### END INIT INFO

# Source function library.
# . /etc/rc.d/init.d/functions
. /lib/lsb/init-functions

prefix="/usr/local/nagios"
exec_prefix="${prefix}"
exec="${exec_prefix}/bin/nagios"
prog="nagios"
config="/etc/nagios/nagios.cfg"
pidfile="${prefix}/var/nagios.lock"
user="nagios"
group="nagios"
checkconfig="false"
ramdiskdir="/var/nagios/ramcache"

test -e /etc/sysconfig/$prog && . /etc/sysconfig/$prog

lockfile=/var/lock/$prog
USE_RAMDISK=${USE_RAMDISK:-0}

if test "$USE_RAMDISK" -ne 0 && test "$RAMDISK_SIZE"X != "X"; then
   ramdisk=`mount |grep "$ramdiskdir type tmpfs"`
   if [ "$ramdisk"X == "X" ]; then
      mkdir -p -m 0755 $ramdiskdir
      mount -t tmpfs -o size=${RAMDISK_SIZE}m tmpfs $ramdiskdir
      mkdir -p -m 0755 $ramdiskdir/checkresults
      chown -R $user:$group $ramdiskdir
   fi
fi

check_config() {
   TMPFILE="/tmp/.configtest.$$"
   /usr/sbin/service nagios configtest > "$TMPFILE"
   WARN=`grep ^"Total Warnings:" "$TMPFILE" |awk -F: '{print \$2}' |sed s/' '//g`
   ERR=`grep ^"Total Errors:" "$TMPFILE" |awk -F: '{print \$2}' |sed s/' '//g`

   if test "$WARN" = "0" && test "${ERR}" = "0"; then
      echo "OK - Configuration check verified" > /var/run/nagios.configtest
      chmod 0644 /var/run/nagios.configtest
      /bin/rm "$TMPFILE"
   return 0
   else
      # We'll write out the errors to a file we can have a
      # script watching for
      echo "WARNING: Errors in config files - see log for details: $TMPFILE" > /var/run/nagios.configtest
      egrep -i "(^warning|^error)" "$TMPFILE" >> /var/run/nagios.configtest
      chmod 0644 /var/run/nagios.configtest
      cat "$TMPFILE"
   exit 8
   fi
}

start() {
   test -x $exec || exit 5
   test -f $config || exit 6
   if test "$checkconfig" = "false"; then
      check_config
   fi
   echo -n $"Starting $prog: "
   # We need to _make sure_ the precache is there and verified
   # Raise priority to make it run better
   daemon --user=$user -- $exec -d $config
   #touch $lockfile
   retval=$?
   echo
   test $retval -eq 0 && touch $lockfile
   return $retval
}

stop() {
   echo -n $"Stopping $prog: "
   killproc -p ${pidfile}  $exec
   retval=$?
   echo
   test $retval -eq 0 && rm -f $lockfile
   return $retval
}

restart() {
   check_config
   checkconfig="true"
   stop
   start
}

reload() {
   echo -n $"Reloading $prog: "
   killproc -p ${pidfile} $exec -HUP
   RETVAL=$?
   echo
}

force_reload() {
   restart
}

case "$1" in
   start)
      status_of_proc $prog && exit 0
      $1
      ;;
   stop)
      status_of_proc $prog|| exit 0
      $1
      ;;
   restart)
      $1
      ;;
   reload)
      status_of_proc $prog || exit 7
      $1
      ;;
   force-reload)
      force_reload
      ;;
   status)
      status_of_proc $prog
      ;;
   condrestart|try-restart)
      status_of_proc $prog|| exit 0
      restart
      ;;
   configtest)
      $nice su -s /bin/bash - nagios -c "$corelimit >/dev/null 2>&1 ; $exec -vp $config"
      RETVAL=$?
      ;;
   *)
      echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
      exit 2
esac
exit $?
```