
## 1. 获得示例代码

	- # 可以 git clone , 也可以下载 zip 压缩包
	- git clone https://github.com/kubeedge/examples.git

## 2. temperature-mapper代码的修改

	- # 修改temperature-mapper/main.go中的代码，主要修改以下三部分：
		1）添加模块
		2）注释硬件相关的代码
		3）增加温度生成的代码（通过随机函数生成）
		4）配置MQTT服务器的地址


### 3. 创建device model和device
#### 3.1 创建device model

	- # 打开并编辑
	- sudo vim ./crds/devicemodel.yaml
	- # 修改后内容：
		apiVersion: devices.kubeedge.io/v1alpha2	# v1alpha1 改为 v1alpha2
		kind: DeviceModel
		metadata:
		  name: temperature-model
		  namespace: default
		spec:
		  properties:
		    - name: temperature-status
		      description: Temperature collected from the edge device
		      type:
			string:
			  accessMode: ReadOnly
			  defaultValue: ''
	- # 部署device model
	- kubectl apply -f ./crds/devicemodel.yaml

#### 3.2 修改device.yaml文件的边缘节点名称
	- # 打开并修改
	- sudo vim ./crds/device.yaml
	- # 修改后内容：
		apiVersion: devices.kubeedge.io/v1alpha2	#把 v1alpha1 改为 v1alpha2
		kind: Device
		metadata:
		  name: temperature
		  labels:
		    description: 'temperature'
		    manufacturer: 'test'
		spec:
		  deviceModelRef:
		    name: temperature-model
		  nodeSelector:
		    nodeSelectorTerms:
		      - matchExpressions:
			  - key: 'name'		# 改为边缘节点的标签的 key
			    operator: In
			    values:
			      - edge-side	# 改为边缘节点的标签的 value
		status:
		  twins:
		    - propertyName: temperature-status
		      desired:
			metadata:
			  type: string
			value: ''
		
	- # 部署 device.yaml
	- kubectl apply -f ./crds/device.yaml
### 4. 构建temperature-mapper镜像
#### 4.1  构建temperature-mapper镜像 （master节点）

	- cd /kubeedge-example/examples/kubeedge-temperature-demo/
	- # 修改 dockerfile 文件,存在外部网站，国内访问时可能会超时，添加以下内容：
		FROM alpine:3.10
		RUN echo -e http://mirrors.ustc.edu.cn/alpine/v3.10/main/ > /etc/apk/repositories
	- sudo docker build -t kubeedge-temperature-mapper:test ./ --network=host
	- sudo docker save -o kubeedge-temperature-mapper.tar kubeedge-temperature-mapper:test


#### 4.2 

	- # 拷贝temperature-mapper镜像到边缘节点edge-side （master节点）
	- sudo scp ./kubeedge-temperature-mapper.tar cqupt@edge-side:/home/cqupt/

#### 4.3  load temperature-mapper镜像（edge节点）

	- sudo docker load -i kubeedge-temperature-mapper.tar

### 5. 部署temperature mapper（master节点）
#### 5.1 修改deployment.yaml文件

	- sudo vim ./ployment.yaml
	- # 边缘节点名称,镜像名称
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: temperature-mapper
	  labels:
	    app: temperature
	spec:
	  replicas: 1
	  selector:
	    matchLabels:
	      app: temperature
	  template:
	    metadata:
	      labels:
		app: temperature
	    spec:
	      hostNetwork: true
	      nodeSelector:
		name: "edge-side"
	      containers:
	      - name: temperature
		image: kubeedge-temperature-mapper:test
		imagePullPolicy: IfNotPresent
		securityContext:
		  privileged: true

#### 5.2 部署temperature-mapper

	- # 给边缘节点添加标签
	- # 格式：sudo kubectl label nodes <node-name> <label-key>=<label-value>
	- sudo kubectl label nodes edge-side name=edge-side
	- # 部署temperature mapper
	- kubectl create -f ./deployment.yaml


### 6. 观察temperature的变化情况（master节点）

	- # 多次执行以下命令，将会看到temperature的变化：
	- kubectl get device temperature -o yaml



参考博客：https://blog.csdn.net/weixin_44738411/article/details/107049358



















