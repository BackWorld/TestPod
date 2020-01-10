#!/bin/sh

#  不需要验证-自动发布组件.sh
#  KooScript
#
#  Created by weiyanwu on 2018/7/10.
#  Copyright © 2018年 koolearn. All rights reserved.


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "+++++++++++++++++++++++++++++++   0.检查PodSpecs目录    +++++++++++++++++++++++++++++++++"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

current_Folder=$(pwd)


SpecsFolder="/Users/"$USER"/PodSpecs"

echo "SpecsFolder="$SpecsFolder

echo "----------    检查PodSpecs目录存不存在"

if [ ! -d "$SpecsFolder" ]; then
echo "----------    如果不存在就创建父级目录 然后git clone  ----------"
echo "创建"$SpecsFolder
cd "/Users/"$USER
git clone git@github.com:BackWorld/PodSpecs.git

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

else
echo "PodSpecs已经存在"
echo "目录"$SpecsFolder
cd $SpecsFolder
echo "cd "$SpecsFolder
echo "同步PodSpecs"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi
fi



cd $current_Folder
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    1.获取podspec文件名称  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "cd "$current_Folder

#获取podspec文件名称
podspec_fileName=$(find *.podspec)
echo "podspec_fileName = "$podspec_fileName
libName=`echo $podspec_fileName | cut -d \. -f 1`

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    2.更新lib  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "----------    更新lib  ----------"
echo "----------    git status  ----------"
git status
echo "----------    git add .   ----------"
git add .
echo "----------    git commit  ----------"
git commit -m '更新'$libName
echo "----------    git pull    ----------"
git pull origin master
echo "----------    git push    ----------"
git push origin master





#获取当前的版本号
last_version=$(cat $podspec_fileName | grep -E -o "([0-9]{1,3}[\.]){2}[0-9]{1,3}"|head -n 1)
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    3.增加版本号  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "last_version = "$last_version
#分割当前的版本号
v1=`echo $last_version | cut -d \. -f 1`
v2=`echo $last_version | cut -d \. -f 2`
v3=`echo $last_version | cut -d \. -f 3`
echo "v1 = "$v1
echo "v2 = "$v2
echo "v3 = "$v3
#增加版本号
if [ $v3 -lt 9 ]; then
v3=$[v3+1]
else
v3=0
if [ $v2 -lt 9 ]; then
v2=$[v2+1]
else
v2=0
v1=$[v1+1]
fi
fi

new_version=$v1"."$v2"."$v3
echo "new_version = "$new_version
#替换版本号
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    4.替换版本号，更新lib    --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "----------    替换版本号  ----------"

sed -i "" "/.version/s/$last_version/$new_version/" "$podspec_fileName"

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo ""
echo ""
echo ""
echo "----------    更新lib  ----------"

echo "----------    git status  ----------"
git status
echo "----------    git add .  ----------"
git add .
echo "----------    git commit  ----------"
git commit -m '更新版本到'$new_version
echo "----------    git pull  ----------"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "----------    git push  ----------"
git push origin master
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    5.添加tag  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
#绑定tag
echo "----------    git tag  ----------"
git tag "$new_version"

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "----------    git push --tags  ----------"
git push --tags

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    6.拷贝.podspec到PodSpecs工程  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
new_version_Folder=$SpecsFolder"/"$libName"/"$new_version
echo "new_version_Folder = "$new_version_Folder

libName_Folder=$SpecsFolder"/"$libName
echo "libName_Folder = "$libName_Folder

if [ ! -d "$libName_Folder" ]; then
echo "----------    如果不存在就创建父级目录----------"
echo "创建"$libName_Folder
mkdir $libName_Folder
if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi
fi

cd $libName_Folder
echo "----------    cd  ----------"$libName_Folder
mkdir $new_version
echo "----------    mkdir  ----------"$new_version

cd $current_Folder
echo "----------    拷贝"$podspec_fileName"到新版本目录  ----------"$new_version_Folder"/"$podspec_fileName
cp $podspec_fileName $new_version_Folder"/"$podspec_fileName


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "--------------------------    7.更新PodSpecs  --------------------------"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
cd $SpecsFolder
echo "cd "$SpecsFolder

echo ""
echo ""
echo ""
echo "----------    更新PodSpecs  ----------"
echo "----------    git status  ----------"
git status
echo "----------    git add .  ----------"
git add .
echo "----------    git commit  ----------"
git commit -m "[Update] $libName ($new_version)"
echo "----------    git pull  ----------"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "----------    git push  ----------"
git push origin master

echo ""
echo ""
echo ""
echo "========发布成功！  new_version = "$new_version"========"
echo ""
echo ""
echo ""
