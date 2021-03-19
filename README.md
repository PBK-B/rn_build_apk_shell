# React Native Bale shell
> 这是一个用于 React Native 项目的快捷打包脚本，支持 Android 和 ios 自动化构建

> React Native for Android build APK and IOS IPA of shell script

### Install 🔨
``` /bin/bash -c "$(curl -fsSL https://github.com/PBK-B/rn_build_apk_shell/blob/master/install.sh)" ```

### Use shell 🌈

#### Bale Android
> Build the process manually

``` dabao {ProjectPath or ProjectName} ```

> Automatic build process

``` dabao {ProjectPath or ProjectName} -all```

#### Bale IOS
> Bale IOS ipa Need First Get exportOptions.plist file copy to ```~/data/ops/ios_dabao/etc/{ProjectName}/exportOptions.plist```
> 打包 IOS ipa 需要先获取 exportOptions.plist 文件复制到 ```~/data/ops/ios_dabao/etc/{ProjectName}/exportOptions.plist```


> Build the process manually

``` dabao {ProjectPath or ProjectName} -ipa ```

> Automatic build process

``` dabao {ProjectPath or ProjectName} -ipa -all```

### Demonstrate 🍗
``` dabao /data/app/{Project Path}/ ```
or
``` dabao {Project Name} ```

### Update 🥥
``` dabao_update ```

### Problem? 🐙
[How to get exportOptions.plist file?](https://www.google.com/search?q=How+to+get+exportOptions.plist+file%3F&oq=How+to+get+exportOptions.plist+file%3F)

[怎么获取 exportOptions.plist 文件？](https://cn.bing.com/search?q=%E5%A6%82%E4%BD%95%E8%8E%B7%E5%8F%96+exportOptions.plist+%E6%96%87%E4%BB%B6)
