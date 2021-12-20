#!/bin/bash

# 判断平台 Darwin(macOS)
os_platform=`uname -s`

# 输入时间戳：10位时间戳

if [[ "${os_platform}" = "Darwin" ]];then
  echo `date -r ${1} +"%Y-%m-%d %H:%M:%S"`
elif [[ "${os_platform}" = "Linux" ]];then
  echo `date -d @${1} +"%Y-%m-%d %H:%M:%S"`
fi
