#!/bin/bash
# ----- 配置区 ------

# apk 输出目录 /Users/bin/ 推荐修改为你的用户目录
userPath=$(cd ~ && pwd)
apkRootPath="${userPath}/Desktop/打包输出/"
ipaRootPath="${apkRootPath}ipa/"

# ops 根路径
opsPath="/data/ops/"
if ! [ -x "$opsPath" ]; then
    opsPath="${userPath}/data/ops/"
fi

# 代码根路径
codeRootPath="/data/app/"
if ! [ -x "$codeRootPath" ]; then
    codeRootPath="${userPath}/data/app/"
fi

runAPK() {

    # 判断 log 文件夹是否存在
    [ ! -d "${opsPath}android_dabao" ] && mkdir -p "${opsPath}android_dabao"
    logPath="${opsPath}android_dabao/${appNameCode}.log"

    # 判断安装包输出路径是否存在不存在就创建
    if ! [ -x "$apkRootPath" ]; then
        mkdir -p "$apkRootPath"
    fi

    # 进入项目目录
    cd $appCodePath

    # 执行 yarn
    echo ""
    yarn
    echo ""

    echo -e "info Running jetifier to migrate libraries to AndroidX. 翻译：你别无选择，我就是要修复 Android X，不爽可以打刘公子."
    ./node_modules/jetifier/bin/jetify { stdio: 'inherit' }

    cd ./android

    echo -e "\n\033[32m开始构建《 ${appNameCode} 》 Android APK 安装包！🦕 \033[0m"
    echo -e "查看详细 apk archive 打包输出可在新终端执行：$ open ${logPath}\n"

    ./gradlew assembleRelease >$logPath && cp "./app/build/outputs/apk/release/app-release.apk" "$apkPath"

    dabao_log=$(cat $logPath)

    # 判断是否打包成功
    if [ $(echo $dabao_log | grep -c "BUILD SUCCESSFUL in") -eq '0' ]; then
        rm -rf ./android/*.hprof && echo -e "\033[31m\n打包失败！\033[0mlog文件路径：$logPath \n"
        exit 1
    else
        echo -e "\033[32m\n《 ${appName} 》打包成功！\napk 输出路径：${apkPath} \033[0m\n"

        uploadAPK
    fi

}

runIPA() {

    # 判断 log 文件夹是否存在
    [ ! -d "${opsPath}ios_dabao" ] && mkdir -p "${opsPath}ios_dabao"

    logPathArchive="${opsPath}ios_dabao/${appNameCode}_Archive.log"
    logPathExport="${opsPath}ios_dabao/${appNameCode}_Export.log"

    # 判断安装包输出路径是否存在不存在就创建
    if ! [ -x "$apkRootPath" ]; then
        mkdir -p "$apkRootPath"
    fi

    # 进入项目目录
    cd $appCodePath

    # 执行 yarn
    echo ""
    yarn
    echo ""

    echo -e "\033[32m开始构建《 ${appNameCode} 》 IOS ipa 安装包！🦕 \033[0m"
    echo -e "查看详细 ipa archive 构建日志可在新终端执行：$ open ${logPathArchive}"
    echo -e "查看详细 ipa export 导出日志可在新终端执行：$ open ${logPathExport}\n"

    archive_ipa >$logPathArchive

    export_ipa >$logPathExport

}

uploadAPK() {
    # TODO Upload APK or IPA function

    # apkPath : Android APK file Path（Android APK 文件路径）
    # ipaPath : IOS ipa file Path（IOS IPA 文件路径）
    # appName : App Name (软件名称)
    # appNameCode : App Name (软件名称代码)
    # appVersion : App version (软件版本号)
    # testVersion : Test Version (用户输入的第几次测试)

    if [ ! "$is_all" = "true" ]; then
        # 判断是否全部执行默认
        echo -e -n "\033[32m打包成功，是否上传 APK 到小火箭内测分发平台？ Y/n ( 默认 Y ): \033[0m"
        read is_up
    fi
    
    if [[ "$is_up" == "Y" ]] || [[ "$is_up" == "y" ]] || [ ! -n "$is_up" ]; then
        if [ "$is_ipa" = true ]; then
            # this is IOS ipa (这里是选择了打包 ios 的 ipa)
            echo "开始上传 ipa"
        else
            # this is Android apk (这里是选择了打包 android 的 apk)
            echo "开始上传 apk"
        fi
    else
        echo "你选择了不执行上传安装包！"
    fi

}

function clean_ipa() {
    xcodebuild clean -UseModernBuildSystem=YES -workspace "$appCodePath/ios/$appNameCode.xcworkspace" -scheme "$appNameCode"
}

function archive_ipa() {
    xcodebuild archive -UseModernBuildSystem=YES -workspace "$appCodePath/ios/$appNameCode.xcworkspace" -scheme "$appNameCode" -archivePath "$ipaRootPath$appNameCode"
}

function export_ipa() {
    xcodebuild -UseModernBuildSystem=YES -exportArchive -archivePath "$ipaRootPath$appNameCode/$appNameCode.xcarchive" -exportPath "$ipaRootPath$appNameCode/$appNameCode" -exportOptionsPlist "${opsPath}ios_dabao/etc/${appNameCode}/exportOptions.plist"

    ipaExportPath="$ipaRootPath$appNameCode/$appNameCode.ipa"
    if [ -d "$ipaExportPath" ]; then
        /bin/cp -f "$ipaExportPath" "$ipaPath"
        echo -e "\033[32m\n《 ${appName} 》打包成功！\napk 输出路径：${ipaPath} \033[0m\n"
        uploadAPK
    else
        echo -e "\033[31m\n打包失败！\033[0mExport log 文件路径：$logPathExport \n"
        exit 1
    fi

}

# 参数获取区
for i in "$@"; do
    # 判断是否全部执行默认
    if [ "$i" = "-all" ]; then
        is_all="true"
    fi

    # 判断是否打包 IOS ipa，默认打包 apk
    if [ "$i" = "-ipa" ]; then
        is_ipa=true
    fi
done

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

# 将代码路径转换为绝对路径
appCodePath="$(cd ${appCodePath} && pwd)/"
if [ "$appCodePath" == "/" ]; then
    echo "项目路径异常"
    exit 1
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

appName=$(cat ${appCodePath}/app.json | jq -r '.DisplayName')
appVersion=$(cat ${appCodePath}/app.json | jq -r '.Version')
appNameCode=$(cat ${appCodePath}/app.json | jq -r '.name')

if [ "$appVersion" == "" ]; then
    appVersion="1.0"
    echo -e "APP 版本获取失败，将使用默认版本 1.0 如需指定请修改 ${appCodePath}/app.json 中的 Version 参数，如果 app.json 中不存在 Version 参数请自行添加。\n"
fi

echo -e "你要打包的 APP 是 《\033[34m $appName \033[0m》"
echo -e "APP 版本为：\033[34m $appVersion \033[0m"
echo -e "代码路径为：\033[34m $appCodePath \033[0m"

if [ "$is_ipa" = true ]; then
    appModeStr="IOS ipa 安装包"
else
    appModeStr="Android apk 安装包"
fi

if [ ! "$is_all" = "true" ]; then
    # 判断是否全部执行默认
    echo -e -n "\033[32m确认打包 $appModeStr Y/n ( 默认 Y ): \033[0m"
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
    ipaPath="$ipaRootPath${appNameCode}v${appVersion}_0${testVersion}.ipa"

    # 执行打包脚本
    if [ "$is_ipa" = true ]; then
        runIPA
    else
        runAPK
    fi

else
    echo "取消，你选择了不执行打包！"
fi
