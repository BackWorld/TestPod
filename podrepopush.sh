#!/bin/sh

#  不需要验证-自动发布组件.sh
#  KooScript
#
#  Created by weiyanwu on 2018/7/10.
#  Copyright © 2018年 koolearn. All rights reserved.



echo "|------------------------------------|"
echo "|         0.检查PodSpecs目录           |"
echo "|------------------------------------"

current_Folder=$(pwd)

remote_specs="git@github.com:BackWorld/PodSpecs.git"

SpecsFolder="/Users/"$USER"/PodSpecs"

echo "SpecsFolder="$SpecsFolder

echo "检查PodSpecs目录"

if [ ! -d "$SpecsFolder" ]; then
echo "PodSpecs目录不存在"
echo "[  cd /Users/"$USER "  ]"
cd "/Users/"$USER
echo "[  git clone "$remote_specs "  ]"
git clone $remote_specs

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

else
echo "PodSpecs已经存在"
echo "目录"$SpecsFolder
cd $SpecsFolder
echo "[  cd "$SpecsFolder"  ]"
echo "同步PodSpecs"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi
fi



cd $current_Folder

echo "|------------------------------------|"
echo "|        1.获取podspec文件名称         |"
echo "|------------------------------------"

echo "[  cd "$current_Folder"  ]"

#获取podspec文件名称
podspec_fileName=$(find *.podspec)
echo "podspec_fileName = "$podspec_fileName
libName=`echo $podspec_fileName | cut -d \. -f 1`


echo "|------------------------------------|"
echo "|               2.更新lib             |"
echo "|------------------------------------"

echo "[  git status  ]"
git status
echo "[  git add .   ]"
git add .
echo "[  git commit  ]"
git commit -m '更新'$libName
echo "[  git pull    ]"
git pull origin master
echo "[  git push    ]"
git push origin master


#获取当前的版本号
last_version=$(cat $podspec_fileName | grep -E -o "([0-9]{1,3}[\.]){2}[0-9]{1,3}"|head -n 1)

echo "|------------------------------------|"
echo "|             3.增加版本号             |"
echo "|------------------------------------"

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

echo "|------------------------------------|"
echo "|     4.替换版本号，更新lib             |"
echo "|------------------------------------"

sed -i "" "/.version/s/$last_version/$new_version/" "$podspec_fileName"

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "更新lib"

echo "[  git status  ]"
git status
echo "[  git add .  ]"
git add .
echo "[  git commit  ]"
git commit -m '更新版本到'$new_version
echo "[  git pull  ]"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "[  git push  ]"
git push origin master

echo "|------------------------------------|"
echo "|             5.添加tag               |"
echo "|------------------------------------"

echo ""
#绑定tag
echo "[  git tag  ]"
git tag "$new_version"

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "[  git push --tags  ]"
git push --tags

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi


echo "|------------------------------------|"
echo "|     6.拷贝.podspec到PodSpecs工程      |"
echo "|------------------------------------"

new_version_Folder=$SpecsFolder"/"$libName"/"$new_version
echo "new_version_Folder = "$new_version_Folder

libName_Folder=$SpecsFolder"/"$libName
echo "libName_Folder = "$libName_Folder

if [ ! -d "$libName_Folder" ]; then
echo $libName_Folder"不存在"
echo "创建"$libName_Folder
mkdir $libName_Folder
if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi
fi

cd $libName_Folder
echo "[  cd  ]"$libName_Folder
mkdir $new_version
echo "[  mkdir  ]"$new_version

cd $current_Folder
echo "[  cp "$podspec_fileName $new_version_Folder"/"$podspec_fileName"  ]"
cp $podspec_fileName $new_version_Folder"/"$podspec_fileName


echo "|------------------------------------|"
echo "|             7.更新PodSpecs           |"
echo "|------------------------------------"

cd $SpecsFolder
echo "cd "$SpecsFolder

echo "[  git status  ]"
git status
echo "[  git add .  ]"
git add .
echo "[  git commit  ]"
git commit -m "[Update] $libName ($new_version)"
echo "[  git pull  ]"
git pull origin master

if [ $? -ne 0 ]
then
echo "失败！"
exit 1
fi

echo "[  git push  ]"
git push origin master


echo "|------------------------------------|"
echo "|             发布成功！               |"
echo "|            "$new_version"          |"
echo "|------------------------------------"

