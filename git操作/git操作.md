### 1. 创建新的仓库

	- # 创建版本库
	- git init
	- # 把文件放进暂存区
	- git add <your_file>
	- # 提交文件到本地库,并提交的备注信息
	- git commit -m "<commit message>"	
	- # 添加远程仓库，并为<url>起别名为 origin，
	- git branch -M master
	- git remote add origin <url>
	- # 提交到远程仓库,<address> 为远程仓库的地址，-u 代表指定origin为默认主机，之后可以不加任何参数使用git push了。
	- git push -u origin master	

### 2. 拉取远程仓库到本地

```
- git clone  <url>		# 克隆远程仓库，<url> 为 GitHub 的仓库链接
- git pull origin master	# 将远程的 origin 主机的 master 分支拉去过来和本地的当前分支进行合并 
```

### 3. 删除文件

	- # 先删除文件
	- # 在通过执行 git status 查看已删除的文件，在执行下面的指令
	- git add <file_name>		# <file_name> 为已删除的文件名。包含路径
	- git commit -m "<commit message>"		# 
	- # 直接利用 git 命令删除，加入--cached 则不会删除工作区文件
	- git rm <file_name>	# <file_name> 为已删除的文件名。包含路径.若删除文件夹则添加参数 -r
	- git commmit -m "<commit message>"		# 本次提交的 备注信息

### 4. 分支

	- git branch -v	# 查看分支
	- git branch <branch_name>	# 创建叫 <branch_name> 的分支
	- git branch -d <branch_name>	# 删除 <branch_name> 分支
	- git checkout <branch_name>	# 切换到 <branch_name> 的分支
	- git branch -b <branch_name>	# 创建并切换到 <branch_name> 的分支
	
	- # 合并分支
	- # 先切换到 master 主分支上
	- git branch master
	- # 合并分支
	- git merge <branch_name>	# 把 <branch_name> 合并到master 主分支里

### 5. 配置签名

	- git config --global user.name "<your_name>"	# <your_name> 为GitHub 的用户名
	- git config --global user.email "<your_email_address>"		# <your_email_address> 为 GitHub 注册的邮箱名

### 6. 查看文件状态

	git status

### 7. 看看仓库日志

	- git log
	- git log --pretty=online
	- git reflog	# 每一次的操作

### 8. 回退版本

	- git reset --hard HEAD^		# 回退到上一次提交
	- git reset --hard HEAD~n		# 回退 n 次操作
	- git reset --hard <version number>		# <version number> 为历史记录的版本号

### 9.还原文件

	git checkout -- <file_name>		# <file_name> 文件名
	git config --global user.email "you@example.com"
	git config --global user.name "Your Name"


