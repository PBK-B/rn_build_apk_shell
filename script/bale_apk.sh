#!/bin/bash
# ----- 配置区 ------

# apk 输出目录 /Users/bin/ 推荐修改为你的用户目录
userPath=`cd ~ && pwd`
apkRootPath="${userPath}/Desktop/打包输出/"

# 代码根路径
codeRootPath="/data/app/"
if ! [ -x "$codeRootPath" ]; then
    codeRootPath="${userPath}/data/app/"
fi

runAPK(){

    # 判断安装包输出路径是否存在不存在就创建
    if ! [ -x "$apkRootPath" ]; then
        mkdir "$apkRootPath"
    fi

    # 进入项目目录
    cd $appCodePath

    # 执行 yarn
    yarn

    # 判断 moduleFix 路径是否存在不存在就不修复 module
    if [ -f "./moduleFix/" ]; then
        echo -e "\033[33mfix node_module ...\033[0m"
        /bin/cp -rf ./moduleFix/* ./node_modules/
    fi

    echo "info Running jetifier to migrate libraries to AndroidX. 翻译：你别无选择，我就是要修复 Android X，不爽可以打刘公子."
    ./node_modules/jetifier/bin/jetify { stdio: 'inherit' }

    cd ./android

    ./gradlew assembleRelease > $logPath && cp "./app/build/outputs/apk/release/app-release.apk" "$apkPath"

    dabao_log=`cat $logPath`

    # 判断是否打包成功
    if [ `echo $dabao_log | grep -c "BUILD SUCCESSFUL in"` -eq '0' ]; then
        rm -rf ./android/*.hprof && echo -e "\033[31m\n打包失败！\033[0mlog文件路径：$logPath \n"
    else
        echo -e "\033[32m\n《 ${appName} 》打包成功！\napk 输出路径：${apkPath} \033[0m\n"

        if [ ! "$is_all" = "true" ]; then
            # 判断是否全部执行默认
            echo -e -n "\033[32m打包成功，是否上传 APK 到服务器？ Y/n ( 默认 Y ): \033[0m"
            read is_up
        fi

        if [[ "$is_up" == "Y" ]] || [[ "$is_up" == "y" ]] || [ ! -n "$is_up" ]; then

            # 进入项目目录
            cd $appCodePath && node ./bash/nodejs/cos_upload_apk.js release

        else
            echo "你选择了不执行上传安装包！"
        fi
    fi

}


# 判断是否全部执行默认
if [ "$2" = "-all" ] ; then
    is_all="true"
fi

# 判断项目是否存在
if [ ! -n "$1" ]; then
    echo "未输入项目路径！脚本结束…"
    exit 1
fi

appCodePath="$1"

if ! [ -f "${appCodePath}app.json" ]; then
    echo "输入的项目路径：${appCodePath} 不存在！开始拼接路径…"
    appCodePath="${codeRootPath}${1}/"
    if ! [ -f "${appCodePath}app.json" ]; then
        echo "项目路径：${appCodePath}，项目不存在！（ 请修改脚本中的代码根路径 ）"
        exit 1
    fi
fi

# 判断 jq 是否安装
is_code_app_112233="jq"
if ! [ -x "$(command -v $is_code_app_112233)" ]; then
  # echo "Error: $appName is not installed." >&2
  if ! [ -x "$(command -v brew)" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew install "$is_code_app_112233"
fi



appName=`cat ${appCodePath}/app.json | jq -r '.DisplayName'`
appVersion=`cat ${appCodePath}/app.json | jq -r '.Version'`
appNameCode=`cat ${appCodePath}/app.json | jq -r '.name'`

opsPath="${userPath}/data/ops/"

# 判断 log 文件夹是否存在
if [ ! -d "${opsPath}android_dabao" ]; then
  mkdir -p "${opsPath}android_dabao"
fi

logPath="${opsPath}android_dabao/${appNameCode}.log"

echo -e "你要打包的 APP 是 《\033[34m $appName \033[0m》"
echo -e "APP 版本为：\033[34m $appVersion \033[0m"
echo -e "代码路径为：\033[34m $appCodePath \033[0m"

if [ ! "$is_all" = "true" ]; then
    # 判断是否全部执行默认
    echo -e -n "\033[32m确认打包 Y/n ( 默认 Y ): \033[0m"
    read is_run
fi

if [[ "$is_run" == "Y" ]] || [[ "$is_run" == "y" ]] || [ ! -n "$is_run" ]; then

    # 获取是第几次测试
    if [ ! "$is_all" = "true" ]; then
        # 判断是否全部执行默认
        echo -e -n "\033[32m第几次测试包？输入 0 ~ 99 ( 默认 0 ): \033[0m"
        read testVersion
    fi
    if [ ! -n "$testVersion" ]; then
        testVersion="0"
    fi

    apkPath="$apkRootPath${appName}v${appVersion}_0${testVersion}.apk"

    # 执行打包脚本
    runAPK

else
    echo "你选择了不执行打包！"
fi