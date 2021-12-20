#!/bin/bash

title=$1;
if [ ! -n "$title" ];then
  read -p "请输入文章名称: " title
fi
if [ ! -n "$title" ];then
  echo "\031[34m输入错误!\033[0m"
  exit 1
fi

# -e filename 如果 filename存在，则为真 
# -d filename 如果 filename为目录，则为真 
# -f filename 如果 filename为常规文件，则为真 
# -L filename 如果 filename为符号链接，则为真 
# -r filename 如果 filename可读，则为真 
# -w filename 如果 filename可写，则为真 
# -x filename 如果 filename可执行，则为真 
# -s filename 如果文件长度不为0，则为真 
# -h filename 如果文件是软链接，则为真

current_time=$(date +%Y%m%d) # 当期执行时间
if [ ! -d "source/images/$current_time" ]; then
  mkdir "source/images/$current_time"
  echo "创建文件夹：source/images/$current_time"
fi

hexo new post $title & wait

# 判断是否成功
if [ $? -ne 0 ]
then
  echo -e "\031[34m新建文章失败!\033[0m"
  exit 1
else
  echo -e "\033[34m新建文章成功!\033[0m"
  exit 0
fi