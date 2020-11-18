# Hadoop3.2.1安装部署

## 一、配置基本虚拟机开发环境

> - 虚拟机系统为 CentOS-7.8 , 磁盘 30G，内存 4G（若磁盘空间与内存不足会引起出错）
> - 若开启共享文件夹后依旧看不到文件，可执行 sudo vmhgfs-fuse /mnt/hgfs/ ,再执行 su 切换为 root 用户进行操作，最后执行 exit 退出 root 用户
> - 不要在共享文件夹内解压文件，可把文件拷贝到 $HOME 目录后再解压文件

### 1.1. 配置普通用户的 sudo 权限

	- # 切换到 root 用户
	- su
	- # 打开并编辑配置文件，再写入 "cqupt	ALL=(ALL)	ALL"
	- vi /etc/sudoers
	- # 退出 root 用户，回到普通用户
	- exit


### 1.2. 配置网卡 

	- # 打开并编辑配置文件
	- sudo vi /etc/sysconfig/network-scripts/ifcfg-ens33
	- 修改如下所示：
		BOOTPROTO="static"   	#配置静态连接，方便远程控制
		UUID=FF9E4D56-A3AB-8459-4D43-BCB54538D61D  #改为本机的 product_uuid ，可通过执行 sudo cat /sys/class/dmi/id/product_uuid 查看
		ONBOOT="yes"                #yes启用网卡，no禁用网卡
		IPADDR=192.168.64.XX      #ip地址，注意地址要和nat设置中的网关IP同在一个网段
		NETMASK=255.255.255.0     #子网掩码
		GATEWAY=192.168.64.2      #网关地址要和nat网关地址一致
		DNS1=114.114.114.114      #DNS地址要和nat网关地址一致
		HWADDR=00:0c:29:38:d6:1d  #在自己虚拟机上输入命令ip addr即可看到自己的，填上自己的
	- 关闭 NetworkManager
	- sudo systemctl stop NetworkManager && sudo systemctl disable NetworkManager
	- # 重新回载网络配置
		- # Centos 7时 (本文为此系统)
		- sudo systemctl restart network	# 或者 reboot
		- # CentOs 8时
		- sudo nmcli c reload	# 或者 reboot
	- sudo hostnamectl set-hostname <your hostname>    # 设置主机名。重启后生效


### 1.3. VMware配置端口转发

> 编辑->虚拟网络编辑器->NAT设置

### 1.4. 添加域名解析

	- # 打开并编辑配置文件
	- sudo vi /etc/hosts
	- # 添加以下内容
		192.168.64.11	Hadoop-master
		192.168.64.22	Hadoop-slave01
		192.168.64.33	Hadoop-slave02


### 1.5. 配置国内镜像源

	- sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo    
	- sudo yum install -y epel-release    #添加第三方源epel
	- sudo yum clean all    #清除缓存目录下的软件包以及旧的headers
	- sudo yum makecache    #把服务器的包信息下载到本地缓存，配合yum -C search XXX使用就无需联网检索也能查找软件信息

### 1.6 安装必备的组件

> - 带 ? 的指令代表此操作本文未执行

	？- sudo yum update    #更新系统组件，但不更新内核，若要更新内核则使用 yum upgrade 
	- sudo yum install -y bash-completion     #装完重启系统，按tab可以补全命令 
	- sudo yum install -y vim            #安装 vim，提供vim命令
	- sudo yum install -y net-tools
	- sudo yum install -y wget         	#安装 wget，提供wget命令
	- sudo yum install -y git		   	#安装 git 命令
	- sudo yum install -y lrzsz		   	
	- sudo yum install -y gcc		   	#安装 gcc
	- sudo reboot   #重启系统

### 1.6. 关闭防火墙

	sudo systemctl disable firewalld	# 禁止开机启动
	sudo systemctl stop firewalld		# 关闭防火墙

	- # 配置 iptables 规则
	- sudo iptables -F 
	- sudo iptables -P INPUT ACCEPT
	- sudo iptables -P FORWARD ACCEPT
	- sudo iptables -P OUTPUT ACCEPT

### 1.7.关闭 SELinux

> - SELinux安全子系统虽然对系统安全保障起到很好的做用，但由于其过于严格的安全机制往往导致很多软件无法正常安装和使用。一般企业服务器会直接禁用SELinux。

	- 执行 sudo vi /etc/selinux/config ，使文件中：SELINUX=disabled  #禁止开启重启
	- 执行 sudo setenforce 0   # 立即关闭SELinux


### 1.8. 优化虚拟内存需求率

	- # 永久降低虚拟内存需求率
		- # 创建并编辑配置文件
		- sudo vi /etc/sysctl.d/swappiness.conf
		- # 添加以下内容并保存文件
		- vm.swappiness = 0
	- # 使配置文件生效
	- sudo sysctl -p /etc/sysctl.d/swappiness.conf


### 1.9. 永久关闭透明大页面

> - 透明大页面压缩，可能会导致重大性能问题，需要禁用此设置

	- # 打开并编辑配置文件，
	- sudo vim /etc/default/grub
	- # 在GRUB_CMDLINE_LINUX 加入选项 transparent_hugepage=never

	- # 若系统是基于 BIOS 安装，则执行：
	- sudo grub2-mkconfig -o /boot/grub2/grub.cfg	# 虚拟机安装一般为 BIOS
	- # 若系统是基于 UEFI 安装，则执行：
	- sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

	- # 重启生效
	- sudo reboot
	- # 重启后查看效果
		- cat /sys/kernel/mm/transparent_hugepage/enabled	# always madvise [never] ，则表示成功
		- grep AnonHugePages /proc/meminfo		# AnonHugePages:    0 kB，返回值若是，代表成功禁用 THP



### 1.10. 拷贝 JDBC 驱动包


> - 下载链接：[https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.49.tar.gz](https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-5.1.49.tar.gz)


	- # 解压文件
	- sudo tar -zxvf mysql-connector-java-5.1.49.tar.gz 
	- # 将 mysql-connector-java-5.1.49-bin.jar 移动到 /usr/share/java/ 目录 并重命名（去掉版本号）
	- sudo mv ./mysql-connector-java-5.1.49/mysql-connector-java-5.1.49-bin.jar /usr/share/java/mysql-connector-java.jar
	- # 删除其余文件
	- sudo rm -rf /mysql-connector-java-5.1.49/ ./mysql-connector-java-5.1.49.tar.gz


### 1.11. 安装 JDK

#### 1.11.1 安装前需要删除系统自带的 JDK

	- # 查看本机自带的 jdk
	- rpm -qa|grep java
	- # 卸载系统自带的 jdk，一般是带有 openjdk 字段
	- sudo rpm -e --nodeps <java_file_name>	

#### 1.11.2 解压提前先下载好的 rpm 包

> - 如果使用 tar 包安装JDK，请将JDK安装到 /usr/java/ 目录下，并配置环境变量，CDH会默认到此路径下去读取JDK，如果安装到其他路径会出错
> - 下载 rpm 包的链接：[https://archive.cloudera.com/cm6/6.3.1/redhat7/yum/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update181-1.x86_64.rpm](https://archive.cloudera.com/cm6/6.3.1/redhat7/yum/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update181-1.x86_64.rpm)

	- # 安装
	- sudo rpm -ivh oracle-j2sdk1.8-1.8.0+update181-1.x86_64.rpm 

	- # 添加环境变量
		- # 打开并编辑配置文件
		- sudo vim /etc/profile
		- # 添加以下内容：
			# JAVA_HOME
			export JAVA_HOME=/usr/java/jdk1.8.0_181-cloudera   #自己解压后的jdk目录路径
			export CLASSPATH=./:$JAVA_HOME/lib
			export PATH=$PATH:$JAVA_HOME/bin

	- # 临时在此终端上有效，若想永久生效，则需重启
	- source /etc/profile


### 1.12 安装 Mysql	

#### 1.12.1 安装前需要删除系统自带的数据库

	- # 查看本机自带的 mariadb 数据库
	- rpm -qa|grep mariadb
	- # 删除系统自带的 mariadb 数据库
	- sudo rpm -e --nodeps <mariadb_file_name>

#### 1.12.2 下载 mysql 的 rpm    

    sudo wget http://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

#### 1.12.3 安装 mysql 的 rpm  

> 执行完下列命令后，会在 /etc/yum.repos.d/ 目录下生成两个文件 mysql-community.repo和mysql-community-source.repo   

	sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm

#### 1.12.4 修改repo文件（安装5.7，不要8.0）   

	sudo vim /etc/yum.repos.d/mysql-community.repo
		- 将 [mysql57-community] 下的 enabled 设置为1，表示打开5.7
		- 将 [mysql80-community] 下的 enabled 设置为0，表示关闭8.0
		- 修改完保存退出

#### 1.12.5 安装

> - 尽管每个节点都安装了 mysql,但为了简单起见，后面 mysql数据库都配置在 master 节点上

	- # 安装
	- sudo yum -y install mysql-community-server
	- # 安装 mysql 5.7 需要安装此依赖包，不然 后面安装 agent会报错
	- sudo yum -y install mysql-community-libs-compat

#### 1.12.6 编辑配置文件

	- # 删除旧的 InnoDB 日志文件
	- sudo rm -rf /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1
	- # 打开并编辑配置文件
	- sudo rm -rf /etc/my.cnf && sudo vim /etc/my.cnf
	- # 命令模式下输入 :set paste 开启粘贴模式，在进入插入模式复制粘贴以下内容：
			[mysqld]
			default-storage-engine=INNODB
			character-set-server=utf8
			collation-server=utf8_general_ci	
			validate_password = off		#关闭密码策略
			datadir=/var/lib/mysql
			socket=/var/lib/mysql/mysql.sock
			transaction-isolation = READ-COMMITTED
			# Disabling symbolic-links is recommended to prevent assorted security risks;
			# to do so, uncomment this line:
			symbolic-links = 0
			
			key_buffer_size = 32M
			max_allowed_packet = 32M
			thread_stack = 256K
			thread_cache_size = 64
			query_cache_limit = 8M
			query_cache_size = 64M
			query_cache_type = 1
			
			max_connections = 550
			#expire_logs_days = 10
			#max_binlog_size = 100M
			
			#log_bin should be on a disk with enough free space.
			#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
			#system and chown the specified folder to the mysql user.
			log_bin=/var/lib/mysql/mysql_binary_log
			
			#In later versions of MySQL, if you enable the binary log and do not set
			#a server_id, MySQL will not start. The server_id must be unique within
			#the replicating group.
			server_id=1
			
			binlog_format = mixed
			
			read_buffer_size = 2M
			read_rnd_buffer_size = 16M
			sort_buffer_size = 8M
			join_buffer_size = 8M
			
			# InnoDB settings
			innodb_file_per_table = 1
			innodb_flush_log_at_trx_commit  = 2
			innodb_log_buffer_size = 64M
			innodb_buffer_pool_size = 4G
			innodb_thread_concurrency = 8
			innodb_flush_method = O_DIRECT
			innodb_log_file_size = 512M
			
			[mysqld_safe]
			log-error=/var/log/mysqld.log
			pid-file=/var/run/mysqld/mysqld.pid
			
			sql_mode=STRICT_ALL_TABLES
	

#### 1.12.7 启动安装脚本

> - 通过此脚本可修改 root 用户密码，配置远程登陆，删除匿名用户和测试数据库以及刷新权限操作。

	- # 启动 MySQL
	- sudo systemctl restart mysqld && sudo systemctl enable mysqld
	- # 查看默认密码
	- sudo grep "password" /var/log/mysqld.log
	- # 启动安装脚本
	- sudo /usr/bin/mysql_secure_installation
	- # 操作可参考：
		[...]
		Enter password for user root:
		[...]
		New password:
		Re-enter new password:
		Estimated strength of the password: 0 
		Change the password for root ? ((Press y|Y for Yes, any other key for No) : N
		Remove anonymous users? [Y/n] Y
		[...]
		Disallow root login remotely? [Y/n] N
		[...]
		Remove test database and access to it [Y/n] Y
		[...]
		Reload privilege tables now? [Y/n] Y
		All done!



--------------------------------------------

## 二、完全克隆虚拟机

> 对新克隆的虚拟机配置网卡文件，主机名，

> - Hadoop-master     # 主节点
> - Hadoop-slave01    # 节点1
> - Hadoop-slave02    # 节点2
> - backup    # 备份

------------------------------------------

## 三、配置 Hadoop-master

### 3.1 SSH 免密登录

#### 3.1.1 生成 ssh 公钥

	ssh-keygen -t rsa	# 执行后一路回车
	
#### 3.1.2 分发公钥

	ssh-copy-id Hadoop-slave01
	ssh-copy-id Hadoop-slave02

> - 这里需要配置 Hadoop-slaveXX,具体请见 4.1 节
> - 在其他节点重复以上类似操作


### 3.2 NTP 服务器设置

#### 3.2.1 安装 chrony (centos8 默认安装)

	- # 检查系统是否已安装
	- rpm -qa|grep chrony
	- # 若未安装则
	- sudo yum -y install chrony

#### 3.2.2 修改配置文件

	- # 打开并编辑文件
	- sudo vim /etc/chrony.conf
	- # 取消注释 allow 行，并修改为 allow 192.168.0.0/16

#### 3.2.3 启动并设置开机自启

	sudo systemctl restart chronyd && sudo systemctl enable chronyd

#### 3.2.4 启用 NTP 时间同步

	timedatectl set-ntp true

> - 这里需要配置 Hadoop-slaveXX,具体请见 4.2 节

### 3.3 配置 MySQL

#### 3.3.1 创建元数据库

	- # 进入 mysql
	- mysql -uroot –p123456
	- # 创建数据库
		CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
		CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
	- # 退出 MySQL
	- exit

> - 可参考下表

Service | database 
:-:|:-:
Cloudera Manager Server | scm
Activity Monitor | amon 
Reports Manager | rman
Hue | hue
Hive Metastore Server | metastore
Sentry Server | sentry
Cloudera Navigator Audit Server | nav
Cloudera Navigator Metadata Server | navms
Oozie | oozie


##### 3.3.2 创建普通用户并授权

	- # 进入 mysql
	- mysql -uroot –p123456
	- # 创建普通用户 cdh6 以及密码 cdh6
	- CREATE USER 'cdh6'@'%' IDENTIFIED BY 'cdh6'; 	
	- # 授权
		GRANT ALL ON scm.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON amon.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON rman.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON hue.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON metastore.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON sentry.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON nav.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON navms.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
		GRANT ALL ON oozie.* TO 'cdh6'@'%' IDENTIFIED BY 'cdh6' with grant option;
	- # 刷新权限
	- flush privileges; 
	- # 退出 MySQL
	- exit

### 3.4 安装httpd

	- # 查看该centos7是否存在httpd服务
	- rpm -qa|grep httpd
	- # 如果不存在该服务就安装
	- sudo yum install -y httpd
	- # 启动并设置开机自启
	- sudo systemctl start httpd && sudo systemctl enable httpd
	- # 打开火狐浏览器，访问本机的 80 端口，若有测试页，则代表成功
	- http://192.168.64.11:80

#### 3.5 构建本地仓库

##### 3.5.1 下载Clouder Manger 的 tar 包

> - 下载 cm6.3.1-redhat7.tar.gz
	> 下载链接：[https://archive.cloudera.com/cm6/6.3.1/repo-as-tarball/cm6.3.1-redhat7.tar.gz](https://archive.cloudera.com/cm6/6.3.1/repo-as-tarball/cm6.3.1-redhat7.tar.gz)

##### 3.5.2 下载 CDH 的 parcels 包，sha 文件以及 json 文件

> - 下载 CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel 
	> 下载链接：[https://archive.cloudera.com/cdh6/6.3.2/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel](https://archive.cloudera.com/cdh6/6.3.2/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel)
> - 下载 CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha256
	> 下载链接：[https://archive.cloudera.com/cdh6/6.3.2/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha256](https://archive.cloudera.com/cdh6/6.3.2/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha256)
> - 下载 manifest.json 
	> 下载链接：[https://archive.cloudera.com/cdh6/6.3.2/parcels/manifest.json](https://archive.cloudera.com/cdh6/6.3.2/parcels/manifest.json)

##### 3.5.3 配置创建 cm 文件并构建 yum 源

	- # 创建 /var/www/html/cm5/redhat7/x86_64/ 文件夹
	- sudo mkdir -p /var/www/html/cm6/redhat7/x86_64/
	- # 把 cm6.3.1-redhat7.tar.gz 解压到 /var/www/html/cm6/redhat7/x86_64/ 文件夹
	- sudo tar -zxvf cm6.3.1-redhat7.tar.gz -C /var/www/html/cm6/redhat7/x86_64/
	- # 把 allkeys.asc 拷贝到 /var/www/html/cm6/redhat7/x86_64/cm6.3.1/
	- sudo cp allkeys.asc /var/www/html/cm6/redhat7/x86_64/cm6.3.1/
	- # 构建 yum 源
	- sudo vim /etc/yum.repos.d/cloudera-repo.repo
	- # 添加以下内容
		[cloudera-manager]
		name=Cloudera Manager 6.3.1
		baseurl=http://192.168.64.11/cm6/redhat7/x86_64/cm6.3.1/	
		enabled=1
		gpgcheck = 0
	
	- # 分发给其他节点
	- sudo scp /etc/yum.repos.d/cloudera-repo.repo root@Hadoop-slave01:/etc/yum.repos.d/
	- sudo scp /etc/yum.repos.d/cloudera-repo.repo root@Hadoop-slave02:/etc/yum.repos.d/

#### 3.5.4 配置创建 parcels文件

	- # 在/var/www/html下创建一个parcels文件夹
	- sudo mkdir -p /var/www/html/parcels/
	- # 把 CDH 的 parcels 包，sha 文件以及 json 文件全部放进上述文件夹
		- # 注意：把第二个文件的后缀名 .sha256 改成了 .sha
		- sudo cp CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel /var/www/html/parcels/
		- sudo cp CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha256 /var/www/html/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha
		- sudo cp manifest.json /var/www/html/parcels/
	- # 校验文件下载未损坏
	- /usr/bin/sha256sum CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel		# 将得到验证码1
	- cat /var/www/html/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554-el7.parcel.sha	# 将得到验证码2

> 如果2个验证码一样，证明该文件未损坏，可以使用

### 3.6 安装 CM Server 和 Agent


> - 请注意，在本地仓库中，有以下 rpm 包  
	- allkeys.asc
	- cloudera-manager-agent-6.3.1-1466458.el7.x86_64.rpm
	- cloudera-manager-daemons-6.3.1-1466458.el7.x86_64.rpm
	- cloudera-manager-server-6.3.1-1466458.el7.x86_64.rpm
	- cloudera-manager-server-db-2-6.3.1-1466458.el7.x86_64.rpm
	- enterprise-debuginfo-6.3.1-1466458.el7.x86_64.rpm
	- oracle-j2sdk1.8-1.8.0+update181-1.x86_64.rpm
> - 其中，第四个文件是默认数据库，在生产环境中一般不使用，生产环境中是使用MySQL数据库的，故此处不安装
> - 最后一个文件是 jdk 包，本文已安装，故忽略此文件。

	- # 安装
	- sudo yum install cloudera-manager-daemons
	- sudo yum install cloudera-manager-server
	- sudo yum install cloudera-manager-agent

> - 这里需要配置 Hadoop-slaveXX,具体请见 4.3 节

### 3.7 初始化CM 的配置数据库

> -  执行脚本 scm_prepare_database.sh 进行初始化，命令格式:
> - 具体可见：[https://docs.cloudera.com/documentation/enterprise/6/latest/topics/prepare_cm_database.html](https://docs.cloudera.com/documentation/enterprise/6/latest/topics/prepare_cm_database.html)

	- # 执行脚本。参数说明： -h MysqlHost -P MysqlPort dbType dbName dbUser dbPasswd
	- sudo /opt/cloudera/cm/schema//scm_prepare_database.sh -h Hadoop-master -P 3306 mysql scm cdh6 cdh6
	- # 若提示已存在，则删除配置文件
	- sudo rm /etc/cloudera-scm-server/db.mgmt.properties

### 3.8 启动 Cloudera Manager Server / Agent

	- # 启动 CM Server / Agent
	- sudo systemctl start cloudera-scm-server
	- sudo systemctl start cloudera-scm-agent

> - 这里需要配置 Hadoop-slaveXX,具体请见 4.4 节

	- # 查看日志
	- sudo tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log | grep "Started Jetty server"

> - 若日志中出现下面文字，则代表启动成功:
	> - INFO WebServerImpl:com.cloudera.server.cmf.WebServerImpl: Started Jetty server.

	
### 3.9 在浏览器的 web 页面上安装CM

> - 使用地址: http://192.168.64.11:7180/
> - 默认用户：admin   密码为： admin


--------------------------------------

## 四、配置 Hadoop-slaveXX

> 检查虚拟机的ip UUID，主机名等是否正确。

### 4.1 SSH 免密登录

	- # 打开并配置文件
	- sudo vim /etc/ssh/sshd_config
	- # 去掉其中3行的注释，并修改
		开启  PermitRootLogin yes
		开启  PasswordAuthentication yes
	- # 重启 SSH 服务
	- sudo systemctl restart sshd

### 4.2 NTP 服务器设置

#### 4.2.1 安装 chrony (centos8 默认安装)

	- # 检查系统是否已安装
	- rpm -qa|grep chrony
	- # 若未安装则
	- sudo yum -y install chrony

#### 4.2.2 修改配置文件

	- # 打开并编辑文件
	- sudo vi /etc/chrony.conf
	- # 将下列内容注释掉，然后添加 server Hadoop-master iburst
		server 0.centos.pool.ntp.org iburst
		server 1.centos.pool.ntp.org iburst
		server 2.centos.pool.ntp.org iburst
		server 3.centos.pool.ntp.org iburst

#### 4.2.3 启动并设置开机自启

	sudo systemctl restart chronyd && sudo systemctl enable chronyd

#### 4.2.4 查看时间同步源

	chronyc sources -v

### 4.3 安装 CM Agent

	- # 安装
	- sudo yum install cloudera-manager-daemons
	- sudo yum install cloudera-manager-agent
	- # 修改 agent 的服务器地址
		- 打开并编辑配置文件
		- sudo vim /etc/cloudera-scm-agent/config.ini
		- # 将 server_host=localhost 改为 master 节点主机名 Hadoop-master

### 4.4 启动 Agent

	- sudo systemctl start cloudera-scm-agent 


----------------------------------------------
> - 官网安装文档：[https://docs.cloudera.com/documentation/enterprise/6/latest/topics/installation.html#install_cm_cdh](https://docs.cloudera.com/documentation/enterprise/6/latest/topics/installation.html#install_cm_cdh)