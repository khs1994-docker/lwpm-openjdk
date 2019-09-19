Import-Module downloader
Import-Module unzip
Import-Module command
Import-Module cleanup
Import-Module exportPath

$lwpm=ConvertFrom-Json -InputObject (get-content $PSScriptRoot/lwpm.json -Raw)

$stableVersion=$lwpm.version
$preVersion=$lwpm.preVersion
$githubRepo=$lwpm.github
$homepage=$lwpm.homepage
$releases=$lwpm.releases
$bug=$lwpm.bug
$name=$lwpm.name
$description=$lwpm.description

Function install_after(){

}

Function install($VERSION=0,$isPre=0){
  if(!($VERSION)){
    $VERSION=$stableVersion
  }

  # $url="https://mirrors.huaweicloud.com/openjdk/${VERSION}/openjdk-${VERSION}_windows-x64_bin.zip"
  $url=$lwpm.url

  if($isPre){
    $VERSION=$preVersion
  }else{
  }

  $filename="openjdk-${VERSION}_windows-x64_bin.zip"
  $unzipDesc="openjdk-${VERSION}_windows-x64_bin"

  # _exportPath "/path"

  if($(_command java)){
    $CURRENT_VERSION=(java --version).split(" ")[1]

    if ($CURRENT_VERSION -eq $VERSION){
        echo "==> $name $VERSION already install"
        return
    }
  }

  # 下载原始 zip 文件，若存在则不再进行下载
  _downloader `
    $url `
    $filename `
    $name `
    $VERSION

  # 验证原始 zip 文件 Fix me

  # 解压 zip 文件 Fix me
  # _cleanup "$unzipDesc"
  _unzip $filename $unzipDesc

  # 安装 Fix me

  _mkdir "${env:ProgramData}\openjdk"
  Copy-item -r -force "$unzipDesc\jdk-${VERSION}\" "${env:ProgramData}\openjdk\"
  # Start-Process -FilePath $filename -wait
  # _cleanup "$unzipDesc"

  [environment]::SetEnvironmentvariable("JAVA_HOME", "${env:ProgramData}\openjdk\jdk-${VERSION}", "User")
  [environment]::SetEnvironmentvariable("JAVA_HOME", "${env:ProgramData}\openjdk\jdk-${VERSION}", "Process")
  [environment]::SetEnvironmentvariable("CLASSPATH", ".;$env:JAVA_HOME\lib\dt.jar;$env:JAVA_HOME\lib\tools.jar;", "User")

  _exportPath "$env:JAVA_HOME\bin"

  install_after

  echo "==> Checking ${name} ${VERSION} install ..."
  # 验证 Fix me
  java --version
}

Function uninstall($prune=0){
  _cleanup "${env:ProgramData}\openjdk"
  # user data
  if($prune){
    # _cleanup ""
  }
}

Function getInfo(){
  echo "
Package: $name
Version: $stableVersion
PreVersion: $preVersion
LatestVersion: $latestVersion
HomePage: $homepage
Releases: $releases
Bugs: $bug
Description: $description
"
}

Function bug(){
  return $bug
}

Function homepage(){
  return $homepage
}

Function releases(){
  return $releases
}
