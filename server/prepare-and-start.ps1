# 必要ならサードパーティーライブラリを準備して KonomiTV.py を起動する

# 問題があれば実行を停止
$ErrorActionPreference = "Stop"

# ハッシュチェックを省略したいときは $*SHA256 変数をコメントアウトする

$cpythonTgzUri = "https://github.com/indygreg/python-build-standalone/releases/download/20251031/cpython-3.11.14+20251031-x86_64-pc-windows-msvc-install_only_stripped.tar.gz"
$cpythonSHA256 = "4109dfc4a4a76260c8b71343c2557db6405544edf23d890349b605771423d729"
$poetryVersion = "1.8.5"

$ffmpegZipUri = "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-12-31-14-28/ffmpeg-n7.1.3-22-g40b336e650-win64-gpl-shared-7.1.zip"
$ffmpegSHA256 = "de4b3b27d2f27a4c923ec8d982dda935edb78542528c4599008f3053a71958bd"

$qsvencc7zUri = "https://github.com/rigaya/QSVEnc/releases/download/8.04/QSVEncC_8.04_x64.7z"
$qsvenccSHA256 = "d63d9ca6c8d9b0cdeddde9c2bd99660f52e97ff1766baf5a18d0f8cd3cd0dbfe"

$nvencc7zUri = "https://github.com/rigaya/NVEnc/releases/download/9.09/NVEncC_9.09_x64.7z"
$nvenccSHA256 = "7499deae6a96269730bf2c47f48d3772ea47781fdbaa26117a97da746aaedb80"

$vceencc7zUri = "https://github.com/rigaya/VCEEnc/releases/download/9.01/VCEEncC_9.01_x64.7z"
$vceenccSHA256 = "5838b3831f6865cf84ee4a0ec928b77e2e6336142907be9649343df4416c95b7"

$tsreadexZipUri = "https://github.com/xtne6f/tsreadex/releases/download/master-240517/tsreadex-master-240517.zip"
$tsreadexSHA256 = "472897e084dad6146a4ea327fb9267dd09775d3bc68248f676249f1de08c7fdb"

$psisiarcZipUri = "https://github.com/xtne6f/psisiarc/releases/download/master-230324/psisiarc-master-230324.zip"
$psisiarcSHA256 = "9e9fb304383ebb35fcfc9679182509e4069535e97a809f343bf0f6db59412d0b"

$psisimuxZipUri = "https://github.com/xtne6f/psisimux/releases/download/master-250405/psisimux-master-250405.zip"
$psisimuxSHA256 = "c63bed61bed5c271edfeaed47ec3e4c2704d982e3764f6fa66975361daf664eb"

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
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $cpythonTgzUri -OutFile dltmp.tar.gz
    $ProgressPreference = "Continue"
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
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $ffmpegZipUri -OutFile dltmp.zip
    $ProgressPreference = "Continue"
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
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $qsvencc7zUri -OutFile dltmp.7z
    $ProgressPreference = "Continue"
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
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $nvencc7zUri -OutFile dltmp.7z
    $ProgressPreference = "Continue"
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
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $vceencc7zUri -OutFile dltmp.7z
    $ProgressPreference = "Continue"
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
.\thirdparty\Python\python.exe -m poetry run python -X utf8 KonomiTV.py
