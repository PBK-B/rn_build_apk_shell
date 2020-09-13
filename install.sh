#!/bin/bash

userPath=`cd ~ && pwd`

shellRootPath="${userPath}/data/ops/"

# 判断脚本安装路径是否存在不存在就创建
if ! [ -x "${shellRootPath}" ]; then
    mkdir -p "${shellRootPath}"
fi


# 判断 wget 是否安装
is_code_app_112233="wget"
if ! [ -x "$(command -v $is_code_app_112233)" ]; then
  # echo "Error: $appName is not installed." >&2
  if ! [ -x "$(command -v brew)" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew install "$is_code_app_112233"
fi

# 开始安装脚本
wget -nv -O "${shellRootPath}bale_apk.sh" https://github.com/PBK-B/rn_build_apk_shell/blob/master/script/bale_apk.sh


# echo .bash_profile file
if [ -x "${userPath}/.bash_profile" ]; then
    if [ `cat "${userPath}/.bash_profile" | grep -c "/bin/bash ${shellRootPath}bale_apk.sh"` -eq '0' ]; then
        echo "" >> "${userPath}/.bash_profile"
        echo "# 哈希坊专用打包脚本" >> "${userPath}/.bash_profile"
        echo "alias dabao=\"/bin/bash ${shellRootPath}bale_apk.sh\"" >>  "${userPath}/.bash_profile"
    fi

    if [ `cat "${userPath}/.bash_profile" | grep -c "wget -O ${shellRootPath}bale_apk.sh"` -eq '0' ]; then
        echo '# 更新 Android 打包脚本' >> "${userPath}/.bash_profile"
        echo "alias dabao_update=\"wget -O ${shellRootPath}bale_apk.sh https://github.com/PBK-B/rn_build_apk_shell/blob/master/script/bale_apk.sh\"" >> "${userPath}/.bash_profile"
    fi
fi


# echo .zshrc file
if [ -x "${userPath}/.zshrc" ]; then
    if [ `cat "${userPath}/.zshrc" | grep -c "/bin/bash ${shellRootPath}bale_apk.sh"` -eq '0' ]; then
        echo "" >> "${userPath}/.zshrc"
        echo "# 哈希坊专用打包脚本" >> "${userPath}/.zshrc"
        echo "alias dabao=\"/bin/bash ${shellRootPath}bale_apk.sh\"" >>  "${userPath}/.zshrc"
    fi
        
    if [ `cat "${userPath}/.zshrc" | grep -c "wget -O ${shellRootPath}bale_apk.sh"` -eq '0' ]; then
        echo '# 更新 Android 打包脚本' >> "${userPath}/.zshrc"
        echo "alias dabao_update=\"wget -O ${shellRootPath}bale_apk.sh https://github.com/PBK-B/rn_build_apk_shell/blob/master/script/bale_apk.sh\"" >> "${userPath}/.zshrc"
    fi
fi


source "${userPath}/.bash_profile" && echo "安装成功！"
