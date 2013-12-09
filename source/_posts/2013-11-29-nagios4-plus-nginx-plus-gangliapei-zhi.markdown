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

#### 安装依赖
	
```
	apt-get install libperl-dev libpng12-dev libgd2-xpm-dev build-essential php5-gd wget libgd2-xpm
```

<!-- more -->
	
#### 创建 nagios 用户， 和 nagcmd 用户组

```
	adduser --system --no-create-home --disabled-login --group nagios
	groupadd nagcmd
	usermod -G nagcmd nagios
	usermod -a -G nagcmd www-data
```
	
#### 在一个临时文件夹下下载解压 nagios 源码以及插件源码， 最新的源码可以在 [nagios.org](http://www.nagios.org/download/) 上找到

```
	cd ~/tmp
	mkdir nagios
	cd nagios
	wget http://jaist.dl.sourceforge.net/project/nagios/nagios-4.x/nagios-4.0.2/nagios-4.0.2.tar.gz
	wget https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
	tar xvf nagios-3.4.4.tar.gz
	tar xvf nagios-plugins-1.4.16.tar.gz
```
	
#### 配置 nagios 源码并编译安装

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
	
安装参考文章，需要 make install-init 的， 但我发现4.0.2版的 init 脚本用不了， 弄了好久最后在[All the geeky things](http://blacks3pt3mb3r.wordpress.com/tag/etcinit-dnagios-20-cant-open-etcrc-dinit-dfunctions/) 这个博客里找到了一个稍微修改就可以使用的脚本。将它放到 /etc/init.d/nagios 即可
	
#### 设置网站登录密码，参考 [Nagios on nginx & Ubuntu 12.04](http://idevit.nl/node/93)
#### 设置nagios的log的存放位置

```
	mkdir /var/log/nagios
	touch /var/log/nagios/nagios.log
	chown nagios:nagios /var/log/nagios
	vi /etc/nagios/nagios.cfg # 修改nagios.log的路径
```
#### 安装插件, 插件将被安装在 /usr/local/nagios/libexec 里面

```
	cd ~/tmp/nagios/nagios-plugins-1.5
	./configure --with-nagios-user=nagios --with-nagios-group=nagios
	make && make install
```
	
#### 测试nagios的配置，并设置开机启动
	
```
	/usr/local/nagios/bin/nagios -v /etc/nagios/nagios.cfg
```

如果没有问题，会提示一切正常

```
	chmod +x /etc/init.d/nagios
	update-rc.d -f nagios defaults
```

到这里，只需要 service nagios start 就可以启动nagios了。想要在网页上看到nagios，需要安装nginx 和 fcgi

#### 安装 nginx & fcgi

```
	apt-get install nginx
	apt-get install spawn-fcgi fcgiwrap
```

这时需要确认php-fpm监听的地址，从配置文件```/etc/php5/fpm/pool.d/www.conf```中可以找到, 假设为 ```unix:/var/run/php5-fpm.sock```  
还需要确认```/var/run/fcgiwrap.socket```是否存在，如果不存在则要另外找出这个socket的位置

#### 配置 nginx 并启动

这里并不设置密码（不是必须，但一般都要设置，参考[Nagios on nginx & Ubuntu 12.04](http://idevit.nl/node/93)）

添加nginx配置

{% codeblock /etc/nginx/sites-available/nagios %}
server {
        listen   9981;
        root /var/www/html;
        index index.html index.htm;
        server_name localhost;
        
        location /nagios {
                index index.php;
                alias /usr/local/nagios/share/;
        }

        location ~ ^/nagios/(.*\.php)$ {
                alias /usr/local/nagios/share/$1;
                include /etc/nginx/fastcgi_params;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
        }

        location ~ \.cgi$ {
                root /usr/local/nagios/sbin/;
                rewrite ^/nagios/cgi-bin/(.*)\.cgi /$1.cgi break;
                fastcgi_param AUTH_USER $remote_user;
                fastcgi_param REMOTE_USER $remote_user;
                include /etc/nginx/fastcgi_params;
                fastcgi_pass unix:/var/run/fcgiwrap.socket;
        }
}
{% endcodeblock %}

启动nginx ```service nginx start```, 这时打开 http://localhost:9981/nagios 应该可以看到打开监控网页了。

#### 安装ganglia插件

```
cd /usr/local/nagios/libexec/
touch check_ganglia.py
chown nagios:nagios check_ganglia.py
chmod +x check_ganglia.py
vi check_ganglia.py
```
贴下面代码

{% codeblock /usr/local/nagios/libexec/check_ganglia.py %}
#!/usr/bin/env python

import sys
import getopt
import socket
import xml.parsers.expat

class GParser:
  def __init__(self, host, metric):
    self.inhost =0
    self.inmetric = 0
    self.value = None
    self.host = host
    self.metric = metric

  def parse(self, file):
    p = xml.parsers.expat.ParserCreate()
    p.StartElementHandler = parser.start_element
    p.EndElementHandler = parser.end_element
    p.ParseFile(file)
    if self.value == None:
      raise Exception('Host/value not found')
    return float(self.value)

  def start_element(self, name, attrs):
    if name == "HOST":
      if attrs["NAME"]==self.host:
        self.inhost=1
    elif self.inhost==1 and name == "METRIC" and attrs["NAME"]==self.metric:
      self.value=attrs["VAL"]

  def end_element(self, name):
    if name == "HOST" and self.inhost==1:
      self.inhost=0

def usage():
  print """Usage: check_ganglia \
-h|--host= -m|--metric= -w|--warning= \
-c|--critical= [-s|--server=] [-p|--port=] """
  sys.exit(3)

if __name__ == "__main__":
##############################################################
  ganglia_host = '127.0.0.1'
  ganglia_port = 8649
  host = None
  metric = None
  warning = None
  critical = None

  try:
    options, args = getopt.getopt(sys.argv[1:],
      "h:m:w:c:s:p:",
      ["host=", "metric=", "warning=", "critical=", "server=", "port="],
      )
  except getopt.GetoptError, err:
    print "check_gmond:", str(err)
    usage()
    sys.exit(3)

  for o, a in options:
    if o in ("-h", "--host"):
       host = a
    elif o in ("-m", "--metric"):
       metric = a
    elif o in ("-w", "--warning"):
       warning = float(a)
    elif o in ("-c", "--critical"):
       critical = float(a)
    elif o in ("-p", "--port"):
       ganglia_port = int(a)
    elif o in ("-s", "--server"):
       ganglia_host = a

  if critical == None or warning == None or metric == None or host == None:
    usage()
    sys.exit(3)
       
  try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ganglia_host,ganglia_port))
    parser = GParser(host, metric)
    value = parser.parse(s.makefile("r"))
    s.close()
  except Exception, err:
    print "CHECKGANGLIA UNKNOWN: Error while getting value \"%s\"" % (err)
    sys.exit(3)

  if value >= critical:
    print "CHECKGANGLIA CRITICAL: %s is %.2f" % (metric, value)
    sys.exit(2)
  elif value >= warning:
    print "CHECKGANGLIA WARNING: %s is %.2f" % (metric, value)
    sys.exit(1)
  else:
    print "CHECKGANGLIA OK: %s is %.2f" % (metric, value)
    sys.exit(0)

{% endcodeblock %}

在 ```/etc/nagios/objects/commands.cfg``` 添加上

```
# check_ganglia
define command {
    command_name check_ganglia
    command_line $USER1$/check_ganglia.py -h $HOSTNAME$ -m $ARG1$ -w $ARG2$ -c $ARG3$
}
```

#### 重启 nagios

```
service nagios restart
```

后面还需要配置nagios的service hosts hostgroups contacts， 这里不说了。have fun。




#### 附带 /etc/init.d/nagios

{% codeblock nagios %}
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
{% endblock %}
