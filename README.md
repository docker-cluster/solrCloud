# solrCloud

## 说明

端口映射: 30005-30008:30005-30008, 32181-32183:2181

规格：二主二备(solr*4, zookeeper*3)

网络：solr-cloud

smartcn中文分词fieldType：cn_text

## 部署

``` bash
git clone https://github.com/docker-cluster/solrCloud.git
cd solrCloud
chmod +x setup.sh
./setup.sh
```

## 测试

浏览器访问 服务器ip:30005/solr -> Cloud
