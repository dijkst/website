---
layout: post
title: "设置Ubuntu程序开机启动"
date: 2013-08-13 00:02
comments: true
categories: linux
---

以前配置系统启动项都是拿来能用就行，对于其中规则一点都不熟悉，这两天恰好遇到几篇通俗易懂的介绍，受益匪浅。

涉及到开机启动的配置文件在下面几个文件夹里：

* /etc/init.d 放着程序启动关闭重启的脚本
* /etc/rc(0-6).d里的文件都是/etc/init.d文件下的软链接，rc0.d rc1.d … 分别对应着linux不同的 [runlevel](http://wiki.ubuntu.org.cn/%E5%90%AF%E5%8A%A8)
* /etc/default 里的文件添加一层控制是否启动某个程序的变量

手工设置开机启动程序的步骤是这样的：
1. 在/etc/init.d里写一个启动脚本, 比如：some_program（启动脚本模板后面提供)
2. 使用 sudo update-rc.d some_program defaults 设置开机启动. 可以看到这个命令的工作是把/etc/init.d/some_program 软链接到了 /etc/rc(0-6).d里。
3. 现在重启系统, some_program 就会启动了。

<!-- more -->

很多程序安装好以后已经把启动脚本放在/etc/init.d里面了, 我们要启动它, 首先要试试：

	sudo /etc/init.d/the_program start

如果提示正常则可以通过 sudo update-rc.d the_program defaults 来设置开机启动

如果提示错误，很可能会提示/etc/default/the_program 设置不让启动，需要修改一下/etc/default/the_program文件的配置。

一些有用的命令：
马上启动某个程序

sudo /etc/init.d/the_program start

马上停止某个程序

	sudo /etc/init.d/the_program stop

设置某个已经设置过开机启动的程序不开机启动

	sudo update-rc.d the_program disable

设置某个已经设置开机启动disable的程序开机启动

	sudo update-rc.d the_program enable


init.d里面的脚本模板：（https://github.com/fhd/init-script-template） 

{% codeblock lang:bash %}
#!/bin/sh
### BEGIN INIT INFO
# Provides:         
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

dir=""
user=""
cmd=""

name=`basename $0`
pid_file="/var/run/$name.pid"
stdout_log="/var/log/$name.log"
stderr_log="/var/log/$name.err"

get_pid() {
    cat "$pid_file"   
}

is_running() {
    [ -f "$pid_file" ] && ps `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
     if is_running; then
         echo "Already started"
     else
         echo "Starting $name"
         cd "$dir"
            sudo -u "$user" $cmd > "$stdout_log" 2> "$stderr_log" \
          & echo $! > "$pid_file"
         if ! is_running; then
          echo "Unable to start, see $stdout_log and $stderr_log"
          exit 1
         fi
     fi
     ;;
    stop)
     if is_running; then
         echo "Stopping $name"
         kill `get_pid`
         rm "$pid_file"
     else
         echo "Not running"
     fi
     ;;
    restart)
     $0 stop
     $0 start
     ;;
    status)
     if is_running; then
         echo "Running"
     else
         echo "Stopped"
         exit 1
     fi
     ;;
    *)
     echo "Usage: $0 {start|stop|restart|status}"
     exit 1
     ;;
esac

exit 0
 
{% endcodeblock %}
