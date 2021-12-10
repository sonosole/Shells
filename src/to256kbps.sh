#!/bin/bash

if [ $# -ne 3 ];then
	  echo "──────────────────────────────────────────────────────────"
    echo " [用法] sh to256kbps.sh xxpath xxtype prefix"
    echo "──────────────────────────────────────────────────────────"
    echo " 原路径下，转化含音频的文件为 16kHz-16bit 的 wav 文件"
    echo " xxpath -- 文件路径，如 /home/xxx/"
    echo " xxtype -- 文件类型，wav mp3 mp4 3gp 等之一"
    echo " prefix -- 文件转换后的前缀，a.wav -> _x_a.wav"
    echo "──────────────────────────────────────────────────────────"
    echo " [用例] sh to256kbps.sh /data/XYZ/ wav _new_"
    echo "──────────────────────────────────────────────────────────"
    exit 1
fi


# [0] 按顺序读取变量
path=$1 # 文件路径
type=$2 # 文件类型，wav mp3 等之一
pref=$3 # 文件转换后的前缀，a.wav -> _x_a.wav"
indx=1  # 操作次数

# [1] path为非法目录则退出
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


# [3] 遍历path下的文件，然后原地转换格式
find ${path} -name "*"${type} -print0 | xargs -0 -n 1 | while read old
do
    PATH=${old%/*}           # 保留路径 /home/data/abc.mp3 -> /home/data
    FILE=${old##*/}          # 去掉路径 /home/data/abc.mp3 -> abc.mp3
    NAME=${FILE%.*}          # 去掉后缀 abc.mp3 -> abc

    new=${PATH}"/"${pref}${NAME}".wav"  # 加路径加前缀
    echo "[${indx}]" convert $old "─►" $new "@256kbps"
    /usr/bin/ffmpeg -i $old -ac 1 -ar 16000 -ab 256k -f wav $new -loglevel quiet < /dev/null
    let indx=indx+1
done
