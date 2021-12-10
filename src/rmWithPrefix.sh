#!/bin/bash

if [ $# -ne 3 ];then
	  echo "────────────────────────────────────────────────────────────"
    echo " [用法] sh rmWithPrefix.sh prefix xxpath xxtype"
    echo "────────────────────────────────────────────────────────────"
    echo " 在指定目录下，删除含有特定前缀的某类型的所有文件"
    echo " prefix -- 指定前缀，如 _x_"
    echo " xxpath -- 文件路径，如 /home/xxx/"
    echo " xxtype -- 文件类型，wav mp3 mp4 3gp 等之一"
    echo "────────────────────────────────────────────────────────────"
    exit 1
fi


# [0] 按顺序读取变量
pref=$1 # 指定前缀
path=$2 # 文件路径
type=$3 # 文件类型，wav mp3 等之一
indx=1  # 操作次数

# [1] path/dest为非法目录则退出
if [ ! -d $path ]; then
    echo "\033[31m $path is not a dir...\e[0m"
    exit 1
fi


# [2] 确保所有路径的尾字符是 "/"
#     同时确保类型的首字符是 "."
lenPath=${#path}                       # 源路径字符长度
lenType=${#type}                       # 类型字符长度
finalPathStr=${path:lenPath-1:lenPath} # 尾字符
firstTypeStr=${type:0:1}               # 首字符   offset1:offset2

if [ $finalPathStr != '/' ]; then
    path=${path}"/"
fi

if [ $firstTypeStr != '.' ]; then
    type="."${type}
fi


N=${#pref} # 前缀长度

find ${path} -name "*"${type} -print0 | xargs -0 -n 1 | while read old
do
    FILE=${old##*/}          # 去掉路径 /home/data/abc.mp3 -> abc.mp3

    if [ ${FILE:0:N} == ${pref} ]; then
        rm -f $old
        echo "[${indx}]" $old "deleted"
        let indx=indx+1
    fi
done
