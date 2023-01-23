#!/bin/bash

filter=$1
#while true; do
#  kubectl top pods --containers|sort -rk1 |grep mysql
#  #echo "---"
#  kubectl top pods --containers|sort -rk1 |grep flights  
#  echo "---------------------------------------------"
#  sleep 2
#done

#echo "kubectl top pods --containers|sort -rk1 |grep "${filter}""

while true; do
  kubectl top pods --containers|sort -rk1 |grep "${filter}"
  #echo "---------------------------------------------"
  sleep 2
done

#while true; do 
#  kubectl top pods --containers|sort -rk1 |grep "mysqldb-v1-6d9489bd-rvjdc 	mysqldb"
#  echo "---------------------------------------------"
#  sleep 2
#done

#kubectl top pods --containers|sort -rk1 |grep "mysqldb-v1-6d9489bd-rvjdc 	istio-proxy"
