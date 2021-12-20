#!/bin/bash

# comment=$1;
# if [ ! -n "$comment" ];then
#   read -p "请输入提交日志: " comment
# fi
# if [ ! -n "$comment" ];then
#   echo "\031[34m输入错误!\033[0m"
#   exit 1
# fi

comment="saved at "$(date +%Y%m%d-%H:%M:%S) # 当期时间作为github提交日志

git add . & wait
git commit -m "$comment" & wait
git pull & wait
git push & wait

# 判断是否成功
if [ $? -ne 0 ]
then
  echo -e "\031[34m保存失败!\033[0m"
  exit 1
else
  echo -e "\033[34m保存成功!\033[0m"
  exit 0
fi