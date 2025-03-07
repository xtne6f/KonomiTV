# 必要ならサードパーティーライブラリを準備して KonomiTV.py を起動する

# 問題があれば実行を停止
$ErrorActionPreference = "Stop"

# ハッシュチェックを省略したいときは $*SHA256 変数をコメントアウトする

$cpythonTgzUri = "https://github.com/indygreg/python-build-standalone/releases/download/20250106/cpython-3.11.11+20250106-x86_64-pc-windows-msvc-install_only.tar.gz"
$cpythonSHA256 = "97757f83efab82161955628ba7d7b580dbf86547e0f5955a591c813ea57c7bbe"
$poetryVersion = "1.8.5"

$ffmpegZipUri = "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2024-12-31-13-02/ffmpeg-n7.1-62-gb168ed9b14-win64-gpl-shared-7.1.zip"
$ffmpegSHA256 = "1719510152cd8e9d064fcb65f981680aae8364ced6373724422c7dcd47aca059"

$qsvencc7zUri = "https://github.com/rigaya/QSVEnc/releases/download/7.81/QSVEncC_7.81_x64.7z"
$qsvenccSHA256 = "4df254171b936220fe80bd9d55e0ae5c25f566fdb025eef56536443de335a3ba"

$nvencc7zUri = "https://github.com/rigaya/NVEnc/releases/download/7.82/NVEncC_7.82_x64.7z"
$nvenccSHA256 = "56e4bac3ce6e26f040b6e5597611d719ab27a1193a6474799b92dc656f481dcd"

$vceencc7zUri = "https://github.com/rigaya/VCEEnc/releases/download/8.30/VCEEncC_8.30_x64.7z"
$vceenccSHA256 = "dd2a5d1a20eed40a4ff41d133740acfe15191dfb59aff3c71afbf10127c977d8"

$tsreadexZipUri = "https://github.com/xtne6f/tsreadex/releases/download/master-240517/tsreadex-master-240517.zip"
$tsreadexSHA256 = "472897e084dad6146a4ea327fb9267dd09775d3bc68248f676249f1de08c7fdb"

$psisiarcZipUri = "https://github.com/xtne6f/psisiarc/releases/download/master-230324/psisiarc-master-230324.zip"
$psisiarcSHA256 = "9e9fb304383ebb35fcfc9679182509e4069535e97a809f343bf0f6db59412d0b"

$psisimuxZipUri = "https://github.com/xtne6f/psisimux/releases/download/master-240131/psisimux-master-240131.zip"
$psisimuxSHA256 = "f390228e22fc9fc9b458226d28819dcce68e1e6af3c7116cbab4484d7ecc8834"

# 7z.exe のあるフォルダを PATH に追加
$Env:Path += ";C:\Program Files\7-Zip;C:\Program Files (x86)\7-Zip"

$null = gcm 7z.exe -ErrorAction SilentlyContinue
$exists7z = $?

if (!$exists7z) {
    throw "Error: 7-Zip is not found."
}

pushd -LiteralPath $PSScriptRoot\thirdparty

if (!(Test-Path ..\..\config.yaml)) {
    "config.yaml が見つかりません。 config.example.yaml を元に各自で作成してください。"
    throw "Error: config.yaml is not found."
}

if (Test-Path Python) {
    "Python already exists. skipped."
} else {
    "Preparing Python..."
    Invoke-WebRequest $cpythonTgzUri -OutFile dltmp.tar.gz
    if ($cpythonSHA256 -and ((Get-FileHash dltmp.tar.gz -Algorithm SHA256).Hash -ne $cpythonSHA256)) {
        throw "Hash error."
    }
    7z.exe e dltmp.tar.gz dltmp.tar
    rm dltmp.tar.gz
    7z.exe x -oPython dltmp.tar
    rm dltmp.tar
    mv Python\python\* Python
    rm Python\python

    if (Test-Path ..\.venv) {
        rm -Recurse ..\.venv
        "Virtualenv (.venv) is cleared."
    }
    .\Python\python.exe -m pip install poetry==$poetryVersion
    "Done."
}

if (Test-Path FFmpeg) {
    "FFmpeg already exists. skipped."
} else {
    "Preparing FFmpeg..."
    Invoke-WebRequest $ffmpegZipUri -OutFile dltmp.zip
    if ($ffmpegSHA256 -and ((Get-FileHash dltmp.zip -Algorithm SHA256).Hash -ne $ffmpegSHA256)) {
        throw "Hash error."
    }
    7z.exe e -oFFmpeg dltmp.zip */LICENSE.txt */bin/*.dll */bin/ffmpeg.exe */bin/ffprobe.exe
    rm dltmp.zip
    "Done."
}

if (Test-Path QSVEncC) {
    "QSVEncC already exists. skipped."
} else {
    "Preparing QSVEncC..."
    Invoke-WebRequest $qsvencc7zUri -OutFile dltmp.7z
    if ($qsvenccSHA256 -and ((Get-FileHash dltmp.7z -Algorithm SHA256).Hash -ne $qsvenccSHA256)) {
        throw "Hash error."
    }
    7z.exe e -oQSVEncC dltmp.7z
    rm dltmp.7z
    pushd QSVEncC
    if (Test-Path QSVEncC64.exe) {
        mv QSVEncC64.exe QSVEncC.exe
    }
    popd
    "Done."
}

if (Test-Path NVEncC) {
    "NVEncC already exists. skipped."
} else {
    "Preparing NVEncC..."
    Invoke-WebRequest $nvencc7zUri -OutFile dltmp.7z
    if ($nvenccSHA256 -and ((Get-FileHash dltmp.7z -Algorithm SHA256).Hash -ne $nvenccSHA256)) {
        throw "Hash error."
    }
    7z.exe e -oNVEncC dltmp.7z
    rm dltmp.7z
    pushd NVEncC
    if (Test-Path NVEncC64.exe) {
        mv NVEncC64.exe NVEncC.exe
    }
    popd
    "Done."
}

if (Test-Path VCEEncC) {
    "VCEEncC already exists. skipped."
} else {
    "Preparing VCEEncC..."
    Invoke-WebRequest $vceencc7zUri -OutFile dltmp.7z
    if ($vceenccSHA256 -and ((Get-FileHash dltmp.7z -Algorithm SHA256).Hash -ne $vceenccSHA256)) {
        throw "Hash error."
    }
    7z.exe e -oVCEEncC dltmp.7z
    rm dltmp.7z
    pushd VCEEncC
    if (Test-Path VCEEncC64.exe) {
        mv VCEEncC64.exe VCEEncC.exe
    }
    popd
    "Done."
}

if (Test-Path tsreadex) {
    "tsreadex already exists. skipped."
} else {
    "Preparing tsreadex..."
    Invoke-WebRequest $tsreadexZipUri -OutFile dltmp.zip
    if ($tsreadexSHA256 -and ((Get-FileHash dltmp.zip -Algorithm SHA256).Hash -ne $tsreadexSHA256)) {
        throw "Hash error."
    }
    7z.exe e -otsreadex dltmp.zip Readme.txt x86/tsreadex.exe
    rm dltmp.zip
    "Done."
}

if (Test-Path psisiarc) {
    "psisiarc already exists. skipped."
} else {
    "Preparing psisiarc..."
    Invoke-WebRequest $psisiarcZipUri -OutFile dltmp.zip
    if ($psisiarcSHA256 -and ((Get-FileHash dltmp.zip -Algorithm SHA256).Hash -ne $psisiarcSHA256)) {
        throw "Hash error."
    }
    7z.exe e -opsisiarc dltmp.zip Readme.txt x86/psisiarc.exe
    rm dltmp.zip
    "Done."
}

if (Test-Path psisimux) {
    "psisimux already exists. skipped."
} else {
    "Preparing psisimux..."
    Invoke-WebRequest $psisimuxZipUri -OutFile dltmp.zip
    if ($psisimuxSHA256 -and ((Get-FileHash dltmp.zip -Algorithm SHA256).Hash -ne $psisimuxSHA256)) {
        throw "Hash error."
    }
    7z.exe e -opsisimux dltmp.zip Readme.txt x86/psisimux.exe
    rm dltmp.zip
    "Done."
}

pushd -LiteralPath $PSScriptRoot

.\thirdparty\Python\python.exe -m poetry env use $(Convert-Path .\thirdparty\Python\python.exe)
.\thirdparty\Python\python.exe -m poetry install --only main --no-root
.\thirdparty\Python\python.exe -m poetry run python -X utf8 KonomiTV.py --notifyicon
