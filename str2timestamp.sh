#!/bin/bash

# 判断平台 Darwin(macOS)
os_platform=`uname -s`

# 输入字符串格式：%Y-%m-%d %H:%M:%S

if [[ "${os_platform}" = "Darwin" ]];then
  echo `date -j -f "%Y-%m-%d %H:%M:%S" "${1}" +%s`
elif [[ "${os_platform}" = "Linux" ]];then
  echo `date -d "${1}" +%s`
fi