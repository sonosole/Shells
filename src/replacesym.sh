#!/bin/bash

# 如果 /xxpath/下有文件
# 1_a.txt
# 2_a.txt
# 2_a.wav
# 那么执行 replacesym.sh /xxpath "txt" "_a" "" 后有：
# 1.txt
# 2.txt
# 2_a.wav
# 达到删除文件名中的"_a"效果

if [ $# -ne 4 ];then
	echo "────────────────────────────────────────────────"
	echo " [用法] sh replacesym.sh path type oldstr newstr"
	echo "────────────────────────────────────────────────"
	echo " 替换文件名中的某些字符, 如替换所有 this 为 that"
	echo " path   -- 操作文件所在路径，例如 /home/abc/"
	echo " type   -- 操作的文件类型，例如 wav,txt 等"
	echo " oldstr -- 想替换的老符号，例如 JERRY"
	echo " newstr -- 新符号，可以是空字符以达到删除的目的"
	echo "────────────────────────────────────────────────"
	exit 1
fi

# [0] 按顺序读取变量
path=$1 	  # 文件路径
type=$2 	  # 文件类型
oldstr=$3   # 文件名中的老字符
newstr=$4   # 替换老符号的新符号

# [1] path为非法目录则退出
if [ ! -d $path ]; then
    echo "\033[31m $path is not a dir...\e[0m"
    exit 1
fi

# [2] 确保路径的尾字符是 "/"
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

# [3] 遍历path下的文件，然后用新字符串替换老字符串
find ${path} -name "*."${type} -print0 | xargs -0 -n 1 | while read src
do
	echo $src | grep -e "$oldstr" > /dev/null 2>&1
	if [ $? = 0 ];then
		# $? 是上一个操作是否成功的标志，成功则为0
	    des=$(echo $src | sed  "s/$oldstr/$newstr/g")
	    /bin/mv -i ${src} ${des}  > /dev/null 2>&1
	    echo "[old name] " $src
	    echo "[new name] " $des
	    echo " "
	fi
done
