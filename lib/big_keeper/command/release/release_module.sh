#!/bin/bash

cd $(dirname $0)

diff=`git diff`


if [ ${#diff} != 0 ];
then
    echo "还有东西没有提交"
    exit 1
fi

echo "--------tag list--------"
git tag -l
echo "--------tag list--------"

echo "根据上面的tag输入新tag"
read thisTag

# 获取podspec文件名
podSpecName=`ls|grep ".podspec$"|sed "s/\.podspec//g"`
echo $podSpecName

# 修改版本号
sed -i "" "s/s.version *= *[\"\'][^\"]*[\"\']/s.version=\"$thisTag\"/g" $podSpecName.podspec

pod cache clean --all

pod lib lint --allow-warnings --verbose --use-libraries


# 验证失败退出
if [ $? != 0 ];then
    exit 1
fi


git commit $podSpecName.podspec -m "update podspec"
git push
git tag -m "update podspec" $thisTag
git push --tags

pod repo push specs $podSpecName.podspec --allow-warnings
