#!/bin/bash

# filename: IonicBuilder.sh
# author: @Patrick Jun
# version: 1.0.0

####################### 配置-start ########################
# 证书地址（绝对路径）
cert_path=""

# 证书账号
cert_user=""

# 证书密码
cert_pass=""

# 输出路径（绝对路径）
store_path="$HOME/Desktop"

# 打包类型（默认debug包）
build_type="debug"

# 打包命令
build_cmd_debug="ionic cordova build android"
build_cmd_release="ionic cordova build android --aot --prod --release"
build_cmd_browser="ionic build --prod --aot --engine browser"

# 输出日志 yes/no
is_verbose="no"
####################### 配置-end ########################

# 帮助描述
showHelp() {
echo -e "
  Ionic打包脚本说明：
  \033[34mIonicBuilder [-可选项 值]\033[0m
      -d,--debug          : （默认）编译debug包，不签名
      -p,--prod           : 编译产品包，并自动签名
      -b,--browser        : 编译html包
      -v,--verbose        : 输出日志(默认不输出)
      -o,-output /path    : 输出路径(默认$HOME/Desktop)
      -n,-name app.apk    : 输出包命名
      -h,--help           : 描述手册
  "
}

##################### 参数处理 ######################
current_exec_path=`pwd` # 当前执行路径
current_time=$(date +%m.%d-%H:%M:%S) # 当期执行时间
configXML="$current_exec_path/config.xml" # 当前项目配置文件
packageId=`head $configXML | grep -Eo 'id=\S+"' | sed 's/id=//g' | sed 's/"//g'`  # 获取包名
packageVersion=`head $configXML | grep -Eo '<widget.+xmlns=' | sed 's/<widget.*version=//g' | sed 's/xmlns=//g' | sed 's/"//g' | sed 's/ //g'`  # 获取版本号
packageName=`head $configXML | grep -Eo '<name>.+<' | sed 's/<name>//g' | sed 's/<//g'`  # 获取app名称

default_name_debug="$packageName-$current_time.apk" # 默认debug包命名
default_name_release="$packageName-v$packageVersion.apk" # 默认签名包命名
default_name_html="$packageName-$current_time" # 默认html包命名

build_cmd=$build_cmd_debug # 打包命令
apk_name=$default_name_debug   # 输出包命名
apk_path=""   # 打包成功的包路径

# 处理命令里的参数
OPTS_TEMP=$(getopt -l debug,prod,help,verbose,out::,name:: -o dphvo::n:: -a -- "$@")
# 重新排列参数的顺序
# 使用eval 的目的是为了防止参数中有shell命令，被错误的扩展。  
# eval set -- "${OPTS_TEMP}"  # TODO 网上示例都要这个，但用了这个就不行，难道mac不同？
while true
do
	case "$1" in
		-d|--debug)
      build_type="debug"
      apk_name=$default_name_debug
      build_cmd=$build_cmd_debug
			shift
			;;
		-p|--prod)
			build_type="prod"
      apk_name=$default_name_release
      build_cmd=$build_cmd_release
			shift
			;;
		-b|--browser)
			build_type="html"
      apk_name=$default_name_html
      build_cmd=$build_cmd_browser
			shift
			;;
		-h|--help)
			showHelp
			# shift
      exit 0
			;;
		-v|--verbose)
			is_verbose="yes"
			shift
			;;
		-o|-output)
			case "$2" in
				"") # 选项 o 带一个可选参数，如果没有指定就为空
					shift 2
					;;
				*)
					store_path=$2
					shift 2
			esac
			;;
		-n|-name)
			case "$2" in
				"") # 选项 n 带一个可选参数，如果没有指定就为空
					shift 2
					;;
				*)
					apk_name=$2
					shift 2
			esac
			;;
		--)
      echo "-- 为什么没有执行这个结束标志"
			shift
			break
			;;
		*) 
			# echo "参数处理完成！"
			# exit 1
      break
			;;
		esac
done




##################### 程序开始 ######################

# 初始部分提示信息
echo -e "\033[34mIonicBuilder working...\033[0m"
echo -e "应用：$packageName\n版本：$packageVersion\n包名：$packageId"

echo -e "\n打包类型：$build_type"
echo -e "打包命令：$build_cmd"
echo -e "即将输出：$store_path/$apk_name"

# 打包并获取结果
if [ $is_verbose = "yes" ]
then
  `$build_cmd > ./IonicBuilder.temp`
else
  `$build_cmd > ./IonicBuilder.temp 2>&1 & wait`
fi

# 获取打包完成的apk路径
if [ $build_type = "prod" ]
then
  apk_path=`tail ./IonicBuilder.temp | grep app-release-unsigned\.apk | head -n 1 | sed 's/ //g'`
elif [ $build_type = "debug" ]
then
  apk_path=`tail ./IonicBuilder.temp | grep app-debug\.apk | head -n 1 | sed 's/ //g'`
else
  apk_path="./www"
fi

# 删除过程缓存文件
rm ./IonicBuilder.temp

if [ -z $apk_path ]
then
  echo -e "\033[31mIonicBuilder Failed!\033[0m"
  exit 1
elif [ $build_type = "prod" ]
then
  echo -e "\033[34mIonicBuilder signing...\033[0m"
  # 开始签名
  jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore $cert_path -storepass $cert_pass $apk_path $cert_user > /dev/null 2>&1

  # 判断签名是否成功
  if [ $? -ne 0 ]
  then
    echo -e "\031[34mIonicBuilder failed!\033[0m"
    exit 1
  else
    echo -e "\033[34mIonicBuilder signed!\033[0m"
  fi

  # 开始移动文件
  echo -e "\033[34mIonicBuilder moving...\033[0m"
  mv $apk_path $store_path/$apk_name
  if [ $? -ne 0 ]
  then
    echo -e "\033[31mFailed\033[0m!"
    exit 1
  else
    echo -e "\033[32mIonicBuilder Success! \033[0m \n  signed apk: $store_path/$apk_name"
    exit 0
  fi
elif [ $build_type = "debug" ]
then
  # 开始移动文件-debug包不经过签名
  echo -e "\033[34mIonicBuilder moving...\033[0m"
  mv $apk_path $store_path/$apk_name
  if [ $? -ne 0 ]
  then
    echo -e "\033[31mFailed\033[0m!"
    exit 1
  else
    echo -e "\033[32mIonicBuilder Success! \033[0m \n  debug apk: $store_path/$apk_name"
    exit 0
  fi
else
  # 开始移动www目录
  echo -e "\033[34mIonicBuilder moving...\033[0m"
  mv $apk_path $store_path/$apk_name
  if [ $? -ne 0 ]
  then
    echo -e "\033[31mFailed\033[0m!"
    exit 1
  else
    echo -e "\033[32mIonicBuilder Success! \033[0m \n  released: $store_path/$apk_name"
    exit 0
  fi
fi


