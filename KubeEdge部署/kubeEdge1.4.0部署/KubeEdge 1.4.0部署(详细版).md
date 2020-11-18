## 环境（各个系统皆由 UEFI 方式安装）
-----------------------------------
配置网络

### cloud-side:

> - cloudside : Win10 + Ubuntu16.04 双系统，双网卡，8G RAM + 50G 磁盘空间（在win10上提前分出空闲磁盘） ip:192.168.43.10 
> - docker 19.03.11, go 1.13.10,kubernetes 1.18.6-00 
> - 执行第一、二、三、四章

---------------------------------
### edge-side : 
> - Up Board 板，4G RAM,64G eMMC，Ubuntu 16.04，ip 192.168.43.11 
> - docker 19.03.11, go 1.13.10
> - 执行第一、二、五章，以及第三章的第一节安装 docker

-------------------------------------------
## 一、下载并安装Ubuntu 16.04
### 1，下载安装 UltraISO
### 2. 下载 Ubuntu 16.04 安装镜像，并制作启动盘

> 注： 

> - 若 Up board 第一次安装系统，则插入启动盘并上电即可。若不然，在板子上电后，点按或者长安 F7。
> - 本PC机装 双系统时，可按 F8 进入系统选择界面。
> - 跳出选择界面后，选择启动盘启动。后面安装时注意，请选最后一项进行自定义分区安装。
> - 自定义分区: 
> - 1) efi分区：1G，主分区，EFI系统分区
> 	
> 	> - 若是装双系统，会有win10自己的 efi 分区。当卸载 Ubuntu时，在win10 上利用 easyUEFI 删除Ubuntu启动项, 然后删除 Ubuntu 的磁盘和 efi分区
> - 2）"/" 分区： PC机：35G Up Board: 40G,主分区。
> - 3）"/home" 分区，PC机：15G Up Board: 20G，逻辑分区
> - 4）由于安装 kubernetes 集群要禁用 swap，故这里不分 swap 分区，
> - 4）UEFI方式安装的 Linux 系统，不需要 "/boot" 分区

> - 推荐带 GUI 的基本服务器安装，以减少 shell 命令操作。如果提示安装组件，则选择必要的组件， 比如基本开发工具等
> - 本文用户名：cqupt   计算机名：cloud-side 与 edge-side。
> - 安装过程中未设置 root 密码，系统会生成随机密码，执行以下代码更改密码 

	- sudo passwd root  # 执行后，输入两次设立的新密码即可

## 一、 安装 Ubuntu 16.04 基本开发环境

### 1. 配置连接网络环境

	- hostnamectl set-hostname <your hostname>    # 设置主机名。重启后生效，这里是 cloud-side 或 edge-side
	- # 删除 /etc/hosts 文件中的 127.0.1.1 所在行，并添加以下内容：
		192.168.64.10	cloud-side
		192.168.64.11	edge-side
	
	- # 为内网网卡配置网关等信息
	- # 获取连接内网的网卡名称，本文的局域网网卡名称为： enp2s0
	- ifconfig		# 若没有此命令则 使用 ip addr 
	- # 修改网卡配置（本文使用方式一）
		
		方式一：配置 NetworkManager，配置信息参考方式二。
		方式二：修改 /etc/network/interfaces 配置文件。添加以下信息
			auto	<网卡名称>
			iface	<网卡名称> inet static
			address	<your ip >	# cloud-side:192.168.64.10	edge-side:192.168.64.11
			netmask	255.255.255.0
			gateway	192.168.64.1		# 本文设为 192.168.64.1
			dns-nameservers 114.114.114.114
			
	- # 重启
	- reboot

> 注：两个方式是相冲突的，详细见：[https://www.cnblogs.com/lcword/p/5917348.html](https://www.cnblogs.com/lcword/p/5917348.html)

### 2.  解决重启后不能联网（本文采用方式一）

> 开机后若不能联网，可执行 route -n 查看默认路由，可见有线网卡的优先级高于无线网卡。要么不设置有线网卡的网关（路由也叫网关），只保留无线网卡的路由。要么每次开机后更改两个默认路由的优先级。

#### 2.1 方式一：

 使用 NetworkManager 取消有线网卡的网关。但确保系统存在至少一个系统默认路由，不然k8s可能无法运行。

#### 2.2 方式二：

	- # 重启后优先级会改变，所以每次重启都需要改优先级以能够连上公网
	- sudo route del default gw <网关地址> <无线网卡名>	# 先删除此默认路由，删除默认路由时，网卡名可省略。
	- sudo route add default gw <网关地址> dev <无线网卡名>	metric <优先级数字>	#再添加默认路由，并设优先级，数字越小，级别越高

### 2. 配置系统镜像源

	> - 推荐阿里云的镜像站
	> - 系统设置 -> 软件与更新 -> ubuntu 软件 -> 下载自：[...] -> 选择阿里云镜像站

### 3. 更新系统并安装必备的组件 	

	- sudo apt-get update		#更新
	- sudo apt-get upgrade  	#更新
	- sudo apt-get install -y bash-completion     # 安装 bash-completion，装完重启系统，按tab可以补全命令 
	- sudo apt-get install -y vim           # 安装 vim，提供vim命令
	- sudo apt-get install -y net-tools     # 该组件提供dig，nslookup，ifconfig等命令，方便初始化网络环境
	- sudo apt-get install -y wget         	# 安装 wget，提供wget命令
	- sudo apt-get install -y git		   	# 安装 git 命令
	- sudo apt-get install -y gcc		   	# 安装 gcc
	- sudo apt-get install -y openssh-server	#安装 ssh ，以便远程登陆
	- sudo apt-get install -y ipset ipvsadm		# ipvs 依赖包 （本文安装 未使用 ipvs 模式，故未安装）
	- sudo apt-get install -y conntrack		# k8s,kubeedge 需要


### 4. 永久关闭防火墙

	- #关闭防火墙
	- sudo ufw disable
	
	- # 清空 iptables 规则
	- sudo iptables -F 
	- sudo iptables -P INPUT ACCEPT
	- sudo iptables -P FORWARD ACCEPT
	- sudo iptables -P OUTPUT ACCEPT


### 5. 永久关闭 swap

	- # 推荐安装系统时选择自定义分区，不分 swap 分区，
	- # 如果已存在 swap 分区则
		- sudo sed -i '/ swap / s/^/#/' /etc/fstab	#永久关闭，重启生效
		- sudo swapoff -a	#临时关闭
		- # 查看 swap 分区,sawp 行全零表示已关闭
		- sudo free -m
	- # 打开并编辑
	- sudo vim /etc/default/grub
		- 设置 GRUB_DEFAULT=2，设置默认启动Windows，2为系统启动菜单中Windows所在行数（从0开始）
		- 设置 GRUB_CMDLINE_LINUX上追加"cgroup_enable=memory swapaccount=1"
	- sudo update-grub
	- reboot

#### 6. 永久禁用 SELinux

> #### ubuntu 默认不安装 SELinux，若已安装则需永久禁用，方法略。
>


### 5. 解决 GitHub 的 raw.githubusercontent.com 无法连接问题

#### 5.1 方式一：

	- # 打开并编辑文件
	- sudo vim /etc/hosts
	- # 直接写入以下信息:
		151.101.76.133	raw.githubusercontent.com
		140.82.114.3    github.com
		151.101.40.249	github.global.ssl.fastly.net


#### 5.2 方式二：

	- # 通过 http://ipaddress.com 首页,输入 raw.githubusercontent.com 等网址查询到真实IP地址
	- # 然后把 "<你查到的 ip>	<查询的网址>" 写入 /etc/hosts 文件。


--------------------------------------------------

## 二、 安装 Go

### 1. 下载文件并解压

> - 注：需要提前查看 ，后续安装的 kubeedge 支持哪些版本，这里安装 go 1.13.10

	- sudo wget https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz
	- sudo tar -C /usr/local/ -zxvf go1.13.10.linux-amd64.tar.gz

### 2. 配置环境变量

1）执行编辑文件

	- sudo vim /etc/profile

2) 向文件末尾添加以下内容：

	export 	GOROOT=/usr/local/go
	export 	GOPATH=$HOME/go
	export	GOBIN=$GOPATH/bin
	export	PATH=$PATH:GOBIN:$GOROOT/bin

3） 临时重载配置文件

	source /etc/profile	 # 只能临时在此终端上有效，若想永久生效，需重启

### 3. 创建 go 的工作区目录

	sudo mkdir $HOME/go

### 4. 配置 /etc/sudoers 文件

	- # 执行编辑该文件， 
	- sudo vim /etc/sudoers
	- # 在 Defaults   secure_path 追加 “ /usr/local/go/bin ”
	- # 设置在 Defaults	env_keep+="GOPATH" 
	- # 在 "root		ALL:(ALL:ALL) ALL" 的下面一行添加: 
			cqupt	ALL:(ALL:ALL) ALL	# cqupt 为我的用户名


	- # 查看版本
	- go version


---------------------------------------------------------
## 三、 安装 kubernetes 集群（ kubeadm 方式）

### 1. 安装 docker  

#### 1.1 关闭 ipv6

	- #执行下列代码，编辑文件
	- sudo vim /etc/sysctl.d/99-sysctl.conf 
	
	- #在文件中追加下面的配置
		net.ipv6.conf.all.disable_ipv6 = 1
		net.ipv6.conf.default.disable_ipv6 = 1
		net.ipv6.conf.lo.disable_ipv6 = 1
	
	- # 执行下列命令。执行配置文件
	- sudo sysctl -p /etc/sysctl.d/99-sysctl.conf

#### 1.2 配置内核参数

	- # 先加载 br_netfilter 
	- sudo modprobe br_netfilter
	
	- # 新建并编辑配置文件，
	- sudo vim  /etc/sysctl.d/k8s.conf
	- # 添加下列内容
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1	
		net.ipv4.ip_forward=1
	
	- # 执行 sudo sysctl -p /etc/sysctl.d/k8s.conf 或者 sudo sysctl --system 运行配置文件

#### 1.3 加载 ip_vs 模块（本文采用方式一 安装 kuberntes，故跳过此步）
	- # kubernetes 的 kube-proxy 的 ipvs 模式需要加载此模块，而 iptables 模式不需要.
	- # 若是安装方式一 安装 kuberntes 则直接跳过此步。
		modprobe -- ip_vs
		modprobe -- ip_vs_rr
		modprobe -- ip_vs_wrr
		modprobe -- ip_vs_sh
		modprobe -- nf_conntrack_ipv4
	
	lsmod | grep -e ip_vs -e nf_conntrack_ipv4  # 查看是否开启这些模块


#### 1.4 关闭 dnsmasq

> - dnsmasq 服务会创建一个 DNS 服务，会向 /etc/resov.conf 写入一条 nameserver 127.0.1.1 的记录。最终导致在安装 kubernetes 的 CoreDNS 服务启动失败。

	# 打开编辑配置文件
	- sudo vim /etc/NetworkManager/NetworkManager.conf
	
	[main]
	plugins=ifupdown,keyfile,ofono
	#dns=dnsmasq 	# 把这行注释掉
	
	[ifupdown]
	managed=true	# 设置 managed=true，以使用 NetworkManager 管理网卡
	
	# 重启NetworkManager
	- sudo systemctl restart NetworkManager.service

#### 1.5 正式安装 docker 

> 注： 需要检查kubernetes 和docker版本的兼容性

	- # 安装必要的一些系统工具
	- sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
	- # 安装GPG证书
	- curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
	- # 写入软件源信息
	- sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
	- #更新并安装Docker-CE
	- sudo apt-get -y update
	- # 查看可安装版本
	- sudo apt-cache madison docker-ce
	- #选择指定版本安装，不指定则安装最新版本
	- # sudo apt-get -y install docker-ce=<version>
	- sudo apt-get -y install docker-ce
	- # 验证是否安装成功
	- sudo docker version
	
	- # 设置开机启动
	- sudo systemctl enable docker.service
	
	- # 查看pod的日志
	- sudo docker ps 	# 获取pod的 container_id
	- sudo docker logs <container_id>

#### 1.6 更换 docker 镜像源

	— # 创建并编辑配置文件
	- sudo vim /etc/docker/daemon.json
	- # 写入以下中科院的 docker 镜像源
	- # 添加 "iptables":false ，使得 docker 不再操作 iptables，完全由 k8s 的 kube-proxy 来操作 iptables
	- # 设置 docker 存储驱动为 overlay2 ，需要Linux kernel 版本在 4.0以上，docker 大于1.12
		{
			"registry-mirrors":["https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"],
			"iptables":false,
			"storage-driver": "overlay2"
		}
	- # 重启 docker 
	- sudo systemctl daemon-reload
	- sudo systemctl restart docker
	- # 查看 docker 状态
	- sudo systemctl status docker

### 2. 配置国内Kubernetes源

	- # 安装依赖
	- sudo apt-get install -y apt-transport-https
	
	- # 加载key
	- curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
	
	- #先执行以下命令以建立文件
	- sudo vim /etc/apt/sources.list.d/kubernetes.list
	
	- # 往 kubernetes.list 添加下列内容：
	- deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
	
	- # 更新
	- sudo apt-get update


### 3. 安装指定版本的kubeadm、kubelet 以及 kubectl

> 注： 

> - 需要查看后续待安装的 kubeedge 与 kubernetes的兼容性：[https://github.com/kubeedge/kubeedge#kubernetes-compatibility](https://github.com/kubeedge/kubeedge#kubernetes-compatibility) 

	- # 查看可安装版本
	- sudo apt-cache madison kubeadm
	- #安装指定版本 kubeadm、kubelet kubectl，这里安装 kubernets 1.18.6-00 
	- sudo apt-get install  kubelet=1.18.6-00 kubeadm=1.18.6-00 kubectl=1.18.6-00
	- sudo apt-mark hold kubelet kubeadm kubectl


### 4. 在 cloud-side 上部署 k8s 的 master 节点 (本文采用方式一)

#### 4.1 方式一：
##### 4.1.1 kubeadm init 初始化

1） 执行以下命令

	- # 本文安装时，阿里云镜像站未更新v1.18.6的镜像,于是采用下面镜像源替代：
	- # registry.cn-shanghai.aliyuncs.com/k8sgcrio_containers
	
	sudo kubeadm init --kubernetes-version=1.18.6 \
	--apiserver-advertise-address=192.168.64.10 \
	--image-repository registry.aliyuncs.com/google_containers \
	--pod-network-cidr=10.244.0.0/16 

2） 其中定义 pod 的网段:

	若添加的网络组件为 flannel, 则设置--pod-network-cidr=10.244.0.0/16 	# 本文使用 flannel
	若添加的网络组件为 calico, 则设置--pod-network-cidr=192.168.0.0/16

> - api server 地址就是 master 本机IP地址。
> - 由于 kubeadm 默认从官网 k8s.grc.io 下载所需镜像，国内无法访问，因此需要通过 -–image-repository 指定阿里云镜像仓库地址。
> - 若执行 kubeadm init 出错或强制终止，需要再执行下列命令进行清理:
	- sudo kubeadm reset
	- systemctl stop kubelet
	- systemctl stop docker
	- sudo rm -rf $HOME/.kube/config
	- sudo rm -rf /etc/cni/
	- sudo rm -rf  /var/lib/kubelet/*
	- sudo rm -rf  /var/lib/cni/
	- ifconfig cni0 down
	- ifconfig docker0 down
	- ip link delete cni0
	- systemctl start docker
	- systemctl start kubelet

> - 集群初始化成功后会生成一段脚本，需要保存，其它节点加入 Kubernetes 集群时需要执行此脚本。
> - 默认 token 的有效期为24小时，当过期之后，该 token 就不可用了。如丢失可使用如下命令进行找回： 
	> - kubeadm token create --print-join-command

#### 4.2 方式二：

##### 4.2.1 创建 kubeadm-config.yaml

	- # 注意：如果不加 --component-configs KubeProxyConfiguration,KubeletConfiguration ，则默认只加载 InitConfiguration、ClusterConfiguration 两部分。
	- # kubeadm-config.yaml组成部署说明：
		> InitConfiguration： 用于定义一些初始化配置，如初始化使用的token以及apiserver地址等
		> ClusterConfiguration：用于定义apiserver、etcd、network、scheduler、controller-manager等master组件相关配置项
		> KubeletConfiguration：用于定义kubelet组件相关的配置项
		> KubeProxyConfiguration：用于定义kube-proxy组件相关的配置项

> -  具体可见 [https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/ "kubeadm config")

	sudo kubeadm config print init-defaults --component-configs KubeProxyConfiguration,KubeletConfiguration > $HOME/kubeadm-config.yaml

##### 4.2.2 配置 kubeadm-config.yaml文件

> - 设置 advertise-address 为 cloud-side 的 ip ,本文为：192.168.64.10
> - 设置主节点名为：cloud-side
> - 设置镜像源 imageRepostory : registry.aliyuncs.com/google_containers
> - 更改 kubernetesVersion : v1.18.6
> - 在 serviceSubnet:10.96.0.0/12 下面添加 podSubnet: 192.168.0.0/16  # 若是安装flannel 则是10.244.0.0/16
> - 在 kind: KubeProxyConfiguration 所在行下面的 mode:"",改为 mode: ipvs   # 启用 ipvs 模式
> - dry-run 模式验证语法：sudo kubeadm init --config $HOME/kubeadm-config.yaml --dry-run


##### 4.2.3 安装主节点

	sudo kubeadm init --comfig $HOME/kubeadm-config.yaml



#### 4.3 配置 kubectl 认证信息

> 若 非 root 用户（本文使用非root用户安装）：

	- sudo mkdir -p $HOME/.kube 
	- sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
	- sudo chown $(id -u):$(id -g) $HOME/.kube/config

> 若 root 用户：

	- echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
	- source ~/.bash_profile


#### 4.4 安装网络插件（本文安装 calico）


####  若安装 calico :

#### 配置 NetworkManager

	- # 创建配置文件
	- sudo vim /etc/NetworkManager/conf.d/calico.conf
	- # 添加以下内容：
	    [keyfile]
	    unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
	 
	- # 重启 NetworkManager
	- sudo systemctl daemon-reload
	- sudo systemctl restart NetworkManager.service

详情请见calico官网：https://docs.projectcalico.org/maintenance/troubleshoot/troubleshooting#configure-networkmanager

##### 1）准备配置文件

	- # 下载 calico.yaml 文件
	sudo wget https://docs.projectcalico.org/v3.15/manifests/calico.yaml 
	- # 打开文件，并跳到第 620 行。注意：不要敲入制表符（指键盘的 tab 键），不然会报错，全部用空格。
	- 1. calico默认开启的 ipip 模式，若要采用 BGP模式则修改 CALICO_IPV4POOL_IPIP 字段的 value 值为 "Off"。
	- 2. 在多网卡下，若要使用指定网卡，需在字段 CLUSTER_TYPE 字段下面 添加 IP_AUTODETECTION_METHOD 字段，设 value: 为"interface=<需要指定的网卡名>"，也可以使用正则表达式，如："interface=en.*"
	- sudo vim $HOME/calico.yaml
	
	- #在kubeedge1.4版本安装成功后，会在边缘节点也安装网络插件，但是由于edgecore暂不支持网络插件（也没必要支持），pod状态会变成Error，可手动在calico.yaml文件中注入环境变量后使状态显示为Running。边缘节点网络插件状态异常不会影响kubectl logs边缘节点pod，可跳过此步。
	- # 在每个镜像的环境变量中添加如下内容，注意替换自己的cloudcoreIP。
	    - name: KUBERNETES_SERVICE_HOST
	      value: "192.168.64.10"
	    - name: KUBERNETES_SERVICE_PORT
	      value: "6443"
	    - name: KUBERNETES_SERVICE_PORT_HTTPS
	      value: "6443"
	- # 4个镜像一共5处，镜像命名分别为：upgrade-ipam、install-cni、flexvol-driver、calico-node、calico-kube-controllers，第三处没有环境变量，我们手动添加即可，如下所示:
	- name: flexvol-driver
	  image: calico/pod2daemon-flexvol:v3.14.1
	  env:
	    - name: KUBERNETES_SERVICE_HOST
	      value: "192.168.64.10"
	    - name: KUBERNETES_SERVICE_PORT
	      value: "6443"
	    - name: KUBERNETES_SERVICE_PORT_HTTPS
	      value: "6443"

##### 2）应用配置文件 

	kubectl apply -f $HOME/calico.yaml

##### 3） 观察所有 pods 状态

	watch kubectl get pods --all-namespaces	-owide	# 直到全部显示 Running,再按 CTRL + C 退出


#### 4.5 查看集群信息

	kubectl get cs		#获取集群状态
	kubectl get nodes --show-labels  #获取集群全部节点信息
	kubectl get pods -n kube-system    		#查看 kube-system 名字空间里的所有pod状态
	kubectl logs -n kube-system <pod_id>   	#查看 kube-system 名字空间里的 <pod_id> 的状态
	kubectl label nodes <node-name> <label-key>=<label-value>
	kubectl label nodes <node-name> <label-key>-
	kubectl label nodes <node-name> <label-key>=<label-value> --overwrite
	kubeadm version		#查看 kubeadm 版本

#### 若安装 flannel：

##### 下载官方 yaml 文件

	sudo wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#### 配置网卡信息

	- # flanneld启动参数加上 –iface=<iface-name> 或者 --iface-regex=eth*|ens*
	- sudo vim kube-flannel.yml
	- 本文中的网卡名为 enp2s0,配置如下：
		......
		containers:
		      - name: kube-flannel
		        image: quay.io/coreos/flannel:v0.12.0-amd64
		        command:
		        - /opt/bin/flanneld
		        args:
		        - --ip-masq
		        - --kube-subnet-mgr
		        - --iface-regex=eth*|ens*      //添加此行
		......
	
	- # quay.io网站目前国内无法访问,可以去 https://github.com/coreos/flannel/releases 官方仓库下载镜像
	- # 下载 flanneld-v0.12.0-amd64.docker 导入到 docker 中
	- docker load < flanneld-v0.12.0-amd64.docker
	- # 应用配置文件
	- kubectl apply -f kube-flannel.yml
	- # 观察所有 pods 状态
	- watch kubectl get pods --all-namespaces
	- #在kubeedge1.4版本安装成功后，会在边缘节点也安装网络插件，但是由于edgecore暂不支持网络插件，pod状态会变成Error，但这不影响应用的部署。

> - 注：
> - kubernetes 的官方文档： [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ "Creating a single control-plane cluster with kubead") 
> - 关于 calico 网络插件的安装可见：[https://docs.projectcalico.org/getting-started/kubernetes/quickstart](https://docs.projectcalico.org/getting-started/kubernetes/quickstart "Quickstart for Calico on Kubernetes")

---------------------------------------------------

## 四、 安装 KubeEdge 的 cloud-side

> - 这里采用基于 keadm 工具安装 KubeEdge，且使用官网编译好的 keadm 和 kubeedge 二进制包。
> - 采用源码编译安装 KubeEdge，可参考链接：
> - [https://blog.csdn.net/subfate/article/details/106463852](https://blog.csdn.net/subfate/article/details/106463852 "KubeEdge 1.3.0 部署")

### 1. 配置 ssh 

	- # 在 edge-side 上 编辑 ssh 配置文件
	- sudo vim /etc/ssh/sshd_config		# 编辑 PermitRootLogin 和 PasswordAuthentication 两项为 yes，保存并退出
	- # 重启 ssh 服务
	- sudo systemctl restart ssh.service
	
	- # 在 cloud-side 执行下列命令,即可在 cloud-side 远程登陆 edge-side
	- ssh-keygen -t rsa		# 执行后一直按回车即可
	- ssh-copy-id root@192.168.64.11	# 或者 ssh-copy-id root@edge-side
	- # 即可登陆 edge-side 
	- ssh root@192.168.64.11	# 每次远程登陆结束后，输入 exit 即可回到当前本机。

### 2，生成支持kubectl logs命令的证书

```
- # 确保 kubernetes 的 ca.crt 和 ca.key 文件存在。若是通过 kubeadm 安装 kubernetes ，则这些文件在 /etc/kubernetes/pki/ 目录。
- # 设置CLOUDCOREIPS环境变量，设置环境变量以指定所有cloudcore的IP地址，可以设置设置多个IP地址，"中间用空格隔开"
- export CLOUDCOREIPS="192.168.64.10"
- # 生成证书
- sudo wget -P /etc/kubeedge/ https://raw.githubusercontent.com/kubeedge/kubeedge/master/build/tools/certgen.sh 
- sudo chmod +x /etc/kubeedge/certgen.sh
- sudo -E /etc/kubeedge/certgen.sh stream
- # 设置NAT端口转发
- # 可执行 sudo netstat -tunlp 查看端口信息.
- sudo iptables -t nat -A OUTPUT -p tcp  --dport 10350 -j DNAT --to ${CLOUDCOREIPS}:10003
```



### 2. 从 GitHub上下载 KubeEdge 压缩文件

	- # 如果自己下载很慢可去某宝找代下，把下载的 kubeedge-v1.4.0-linux-amd64.tar.gz 放在 /etc/kubeedge/
	- sudo cp ./kubeedge-v1.4.0-linux-amd64.tar.gz /etc/kubeedge/

### 3. 从 GitHub上下载 keadm 压缩文件

	- # 把下载的 keadm-v1.4.0-linux-amd64.tar.gz 解压，把 keadm 二进制文件放进 /usr/bin/
	- tar -zxvf ./keadm-v1.4.0-linux-amd64.tar.gz
	- sudo mv ./keadm-v1.4.0-linux-amd64/keadm/keadm /usr/bin/
	- sudo rm -rf ./keadm-v1.4.0-linux-amd64/

### 4. 创建 kubeedge cloud 节点

	- # 注意：--kube-config 只能是 kubernetes 放 kubectl 认证信息的目录，可见第三章的第 4.2 节
	- sudo keadm init --kubeedge-version=1.4.0 --kube-config=$HOME/.kube/config --advertise-address=192.168.64.10
	- # 如果出错或强制终止，需要再执行时需要先执行 sudo keadm reset --kube-config=$HOME/.kube/config 重置。

### 5. 查看日志

	- # 查看日志，按 ctrl+c 退出
	- tail -f /var/log/kubeedge/cloudcore.log


### 6. 编辑脚本文件

	- # 创建并编辑脚本文件
	- sudo vim /etc/systemd/system/cloudcore.service
	- # 添加以下内容：
		[Unit]
		Description=cloudcore.service
	
		[Service]
		Type=simple
	    RestartSec=10
		Restart=always
		ExecStart=/usr/local/bin/cloudcore
	
		[Install]
		WantedBy=multi-user.target
	
	- # 设置开机自启
	- sudo systemctl enable cloudcore.service

### 7. 编辑 yaml 文件

```
- # 打开并编辑配置文件
- sudo vim /etc/kubeedge/config/cloudcore.yaml
- # 设置 cloudStream 为 true
	...
	modules:
	  cloudStream:
	    enable: true
	...
```

### 8. 重启

```
reboot
```



------

## 五、 安装 KubeEdge 的 edge-side

### 1. 提前准备 KubeEdge 和 keadm 压缩文件

	- # 把下载的 kubeedge-v1.4.0-linux-amd64.tar.gz 放在 /etc/kubeedge/
	- # 把下载的 keadm-v1.4.0-linux-amd64.tar.gz 解压，把 keadm 二进制文件放进 /usr/bin/

### 2. 在 cloud-side 上运行命令,以获取 token

	- # 执行下列代码后将得到 token，保存到 token.txt 文件
	- keadm gettoken --kube-config=$HOME/.kube/config > $HOME/token.txt
	- # 使用 scp 远程发给 edge-side 的 /home/cqupt/ 目录。
	- sudo scp ~/token.txt root@192.168.64.11:/home/cqupt/

### 3. 在 edge-side 上执行下列命令以加入 kubeedge 集群

	- # 打印 token.txt 的内容，即 cloud-side 生成的 token 值。
	- cat ~/token.txt
	- # 下面指令中 "--token=" 的等号右边填写打印出的 token 值。
	- sudo keadm join --kubeedge-version=1.4.0 \
	                      --cloudcore-ipport=192.168.64.10:10000 \
	                      --edgenode-name=edge-side \
	                      --interfacename=enp1s0 \
	                      --runtimetype=docker \
	                      --token=[yourToken]

### 4. 查看日志 

	- # 最好查看日志，按 ctrl+c 退出
	- journalctl -u edgecore.service -b

### 5. 编辑脚本文件

> 注: KubeEdge 1.4.0 开始, edgecore 默认为 system service,但其脚本文件还需修改。

	- # 打开并编辑脚本文件
	- sudo vim /etc/systemd/system/edgecore.service
	- # [Service] 中添加 “Restart=always”，即若非正常退出，则会总是自动重启
	- # edgecore 启动前需等 docker 正常运行，否则会启动失败。
		[Unit]
		Description=edgecore.service
	
		[Service]
		Type=simple
	    RestartSec=10
		Restart=always
		ExecStart=/etc/kubeedge/edgecore
	
		[Install]
		WantedBy=multi-user.target

### 4. 配置 yaml 文件

	- # 打开并编辑配置文件
	- sudo vim /etc/kubeedge/config/edgecore.yaml
	- # 设置 edgeStream 为 true
	- # 设置 interfaceName 为自己的网卡名
	- # 将server改为 cloudcore IP:10004
		...
		modules:
		  edgeHub:
		    quic:
	           server:192.168.64.10:1001
		...
		modules:
		  edgeStream:
		    enable: true
		...
		modules:
	      edged:
	        server: 192.168.64.10:10004


### 5. 配置 mosquitto 配置文件

```
- # 由于 KubeEdge 使用多个端口，故需用配置文件。服务端添加多端口：
- # 创建并编辑配置文件
- sudo vim /etc/mosquitto/conf.d/port.conf
- # 添加以下内容：
    port 1883
    listener 1884
```

### 6. 重启

	reboot

--------------------------------

官方安装文档：[https://github.com/kubeedge/kubeedge/blob/master/docs/setup/keadm.md](https://github.com/kubeedge/kubeedge/blob/master/docs/setup/keadm.md)

---------------------------------

别人的教程
[https://github.com/JingruiLea/blogs/blob/master/%E5%AE%89%E8%A3%85kubeedge.md](https://github.com/JingruiLea/blogs/blob/master/%E5%AE%89%E8%A3%85kubeedge.md "Kubeedge安装,配置,HelloWorld")

https://blog.csdn.net/subfate/article/details/106463852

https://blog.csdn.net/qq_42484239/article/details/106738965?utm_medium=distribute.wap_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.nonecase&amp;depth_1-utm_source=distribute.wap_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-3.nonecase



---------------------------------------------

