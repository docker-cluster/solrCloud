#!/bin/bash

echo "***************************start to init solrCloud containers***************************"
local_host="`hostname --fqdn`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`
sed -i "s/{{ HOSTIP }}/$local_ip/g" docker-compose.yml
docker-compose down
docker-compose up -d
echo "***************************solrCloud containers inited***************************"

echo "***************************start to configure solrCloud***************************"
docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd upconfig -confdir /opt/solr/server/solr/configsets/sample_techproducts_configs/conf -confname solrcloud-conf
echo quit | docker exec -i solr-zk1 bin/zkCli.sh -server solr-zk2:2181
chmod a+r ./config/solrconfig.xml ./config/managed-schema
docker cp ./config/solrconfig.xml solr1:/opt/solr/server/solr/configsets/sample_techproducts_configs/conf/solrconfig.xml
docker cp ./config/managed-schema solr1:/opt/solr/server/solr/configsets/sample_techproducts_configs/conf/managed-schema
chmod a-r ./config/solrconfig.xml ./config/managed-schema
docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd putfile /configs/solrcloud-conf/solrconfig.xml /opt/solr/server/solr/configsets/sample_techproducts_configs/conf/solrconfig.xml
docker exec -it solr1 /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost solr-zk1:2181,solr-zk2:2181,solr-zk3:2181 -cmd putfile /configs/solrcloud-conf/managed-schema /opt/solr/server/solr/configsets/sample_techproducts_configs/conf/managed-schema
echo "***************************solrCloud configured done***************************"

echo "***************************start to create collection1***************************"
curl "$local_ip:30008/solr/admin/collections?action=CREATE&name=collection1&numShards=2&replicationFactor=2"
curl "$local_ip:30008/solr/admin/collections?action=RELOAD&name=collection1"
echo "***************************collection1 created***************************"

echo "***************************start to create collection2***************************"
curl "$local_ip:30008/solr/admin/collections?action=CREATE&name=collection2&numShards=2&replicationFactor=2&collection.configName=solrcloud-conf"
curl "$local_ip:30008/solr/admin/collections?action=RELOAD&name=collection2"
echo "***************************collection1 created***************************"

echo "success"

exit 0


