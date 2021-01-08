#!/bin/bash
if [ -z $1 ];then
	echo "请在第一个参数中传入需要生成的随机串个数";
	exit -1;
fi

if [ "$1" -lt 1 ];then
	echo "生成随机串的个数不可以小于1";
	exit -1;
fi

if [ -z $2 ];then
        echo "请在第二个参数传入需要生成的随机串长度";
        exit -1;
fi

if [ "$2" -lt 1 ];then
        echo "生成随机串的长度不可以小于1";
        exit -1;
fi

if [ -z $3 ];then
        echo "请在第三个参数传入需要输出的文件名（可包含目录）";
        exit -1;
fi

function gencode(){
	arr=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
	len=${#arr[*]};
	res="";
	for((i=0; i<$1; i++))
	do
        	time=`date +%s`;
        	rannum=`echo $time$RANDOM + $RANDOM|bc`;
        	pos=`echo $rannum % $len`;
        	res=$res${arr[pos]};
	done
	echo $res
}

j=0;
while(("$j" < $1))
do
	gencode $2 >> $3
	j=`echo "$j" + 1 |bc`
done
