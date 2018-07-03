# salt-ssh远程部署使用说明
### 1. 确保被管机ip-hostname列表文件`host_ip.txt`与此脚本在同一目录下
### 2. **使用命令`sh auto.sh <master(本机) IP地址>` 运行此脚本**
### ~~3. 成功安装后使用命令`halt --r` 重启master~~
### 4. 重启后，使用命令`salt-ssh '*' -i test.ping`测试连通性并接受证书
### 5. 若返回结果为True，使用命令`salt-ssh '*' state.sls minions.install`远程部署salt-minion
### 6. 成功后使用命令`salt-key -L` 查看待通过密钥
### 7. 使用命令`salt-key -A`接受全部密钥或用命令`salt-key -a <密钥名>`接受选择密钥
### 8. 再次查看密钥情况，都变为绿色accepted状态则说明远程部署成功
### 9. 使用命令`salt '*' test.ping`等测试minion是否部署成功
# Done
