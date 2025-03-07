#!/bin/sh
# 必要ならサードパーティーライブラリを準備して KonomiTV.py を起動する

if [ "$1" = install ]; then
    echo 'Installing KonomiTV using pm2 run as the current user...'
    echo 'Use `pm2 {stop|restart} KonomiTV` to temporarily stop or restart.'
    echo
    cd "`dirname $0`" && pm2 start ./thirdparty/Python/bin/python --name KonomiTV -- -m pipenv run python KonomiTV.py && pm2 save
    exit
elif [ "$1" = delete ]; then
    echo 'Deleting KonomiTV from pm2 process list...'
    pm2 delete KonomiTV && pm2 cleardump && pm2 save
    exit
fi

# ffmpeg や HWEncC は環境にあるコマンドのシンボリックリンクを作るだけ

echo "$HOSTTYPE" | grep -q 'arm\|aarch64'
if [ $? -eq 0 ]; then
    cpython_tgz_uri='https://github.com/indygreg/python-build-standalone/releases/download/20250106/cpython-3.11.11+20250106-aarch64-unknown-linux-gnu-install_only.tar.gz'
    cpython_sha256=203b39131137f854441d4583ece8eb6567f113ec9c198bf758427e5971863380
else
    cpython_tgz_uri='https://github.com/indygreg/python-build-standalone/releases/download/20250106/cpython-3.11.11+20250106-x86_64-unknown-linux-gnu-install_only.tar.gz'
    cpython_sha256=0ebbe8f23f48a87c1e2fd80926d4a248acae3fcd9d1228ad289664ad6fbe9745
fi
poetry_version=1.8.5

echo "$HOSTTYPE" | grep -q 'arm\|aarch64'
if [ $? -eq 0 ]; then
    libmediainfo_zip_uri='https://mediaarea.net/download/binary/libmediainfo0/22.09/MediaInfo_DLL_22.09_Lambda_arm64.zip'
    libmediainfo_sha256=2907557ce36b09c4555b03ccec6c1457e3363f70b88fa006426b13b4bf61e766
else
    libmediainfo_zip_uri='https://mediaarea.net/download/binary/libmediainfo0/22.09/MediaInfo_DLL_22.09_Lambda_x86_64.zip'
    libmediainfo_sha256=3c26c005016b5ec18ae16b0ec024677b9e5b53aded5d268a574e4272399ad37a
fi

tsreadex_src_uri='https://github.com/xtne6f/tsreadex/archive/eddc8bca0de99627d3867259e7a6e777cbd3b3c6.tar.gz'

psisiarc_src_uri='https://github.com/xtne6f/psisiarc/archive/6593a0f63aedaaecfac7682b51e267874a8ec549.tar.gz'

psisimux_src_uri='https://github.com/xtne6f/psisimux/archive/1e655cd51dd20a77ce5ecc8fa837dbe20c8fe530.tar.gz'

pre_required_commands='curl sha256sum make g++ unzip'

echo "Checking for pre-required commands ( $pre_required_commands )..."
which $pre_required_commands
if [ $? -ne 0 ]; then
    echo 'Error!'
    exit 1
fi
echo 'OK.'

cd "`dirname $0`" && cd thirdparty || exit

if [ ! -e ../../config.yaml ]; then
    echo 'Error: config.yaml is not found.'
    exit 1
fi

if [ -e Python ]; then
    echo 'Python already exists. skipped.'
else
    echo 'Preparing Python...'
    curl -Lo dltmp.tar.gz "$cpython_tgz_uri"
    sha256sum dltmp.tar.gz | grep -q "^$cpython_sha256" || exit
    tar xzf dltmp.tar.gz
    rm dltmp.tar.gz
    mv python _python
    mv _python Python

    if [ -e ../.venv ]; then
        rm -rf ../.venv
        echo 'Virtualenv (.venv) is cleared.'
    fi
    ./Python/bin/python -m pip install poetry==$poetry_version
    echo 'Done.'
fi

if [ -e FFmpeg ]; then
    echo 'FFmpeg already exists. skipped.'
else
    echo 'Preparing FFmpeg...'
    mkdir FFmpeg
    ln_name=FFmpeg/ffmpeg.elf
    bin_path=`which ffmpeg`
    if [ $? -eq 0 ]; then
        ln -s "$bin_path" $ln_name
    else
        echo '#!/bin/sh' >$ln_name
        echo 'exit 1' >>$ln_name
        chmod +x $ln_name
        echo 'Placed "do-nothing" command.'
    fi
    ln_name=FFmpeg/ffprobe.elf
    bin_path=`which ffprobe`
    if [ $? -eq 0 ]; then
        ln -s "$bin_path" $ln_name
    else
        echo '#!/bin/sh' >$ln_name
        echo 'exit 1' >>$ln_name
        chmod +x $ln_name
        echo 'Placed "do-nothing" command.'
    fi
    echo 'Done.'
fi

echo "$HOSTTYPE" | grep -q 'arm\|aarch64'
if [ $? -eq 0 ]; then
    if [ -e rkmppenc ]; then
        echo 'rkmppenc already exists. skipped.'
    else
        echo 'Preparing rkmppenc...'
        mkdir rkmppenc
        ln_name=rkmppenc/rkmppenc.elf
        bin_path=`which rkmppenc`
        if [ $? -eq 0 ]; then
            ln -s "$bin_path" $ln_name
        else
            echo '#!/bin/sh' >$ln_name
            echo 'exit 1' >>$ln_name
            chmod +x $ln_name
            echo 'Placed "do-nothing" command.'
        fi
        echo 'Done.'
    fi
else
    if [ -e QSVEncC ]; then
        echo 'QSVEncC already exists. skipped.'
    else
        echo 'Preparing QSVEncC...'
        mkdir QSVEncC
        ln_name=QSVEncC/QSVEncC.elf
        bin_path=`which qsvencc`
        if [ $? -eq 0 ]; then
            ln -s "$bin_path" $ln_name
        else
            echo '#!/bin/sh' >$ln_name
            echo 'exit 1' >>$ln_name
            chmod +x $ln_name
            echo 'Placed "do-nothing" command.'
        fi
        echo 'Done.'
    fi

    if [ -e NVEncC ]; then
        echo 'NVEncC already exists. skipped.'
    else
        echo 'Preparing NVEncC...'
        mkdir NVEncC
        ln_name=NVEncC/NVEncC.elf
        bin_path=`which nvencc`
        if [ $? -eq 0 ]; then
            ln -s "$bin_path" $ln_name
        else
            echo '#!/bin/sh' >$ln_name
            echo 'exit 1' >>$ln_name
            chmod +x $ln_name
            echo 'Placed "do-nothing" command.'
        fi
        echo 'Done.'
    fi

    if [ -e VCEEncC ]; then
        echo 'VCEEncC already exists. skipped.'
    else
        echo 'Preparing VCEEncC...'
        mkdir VCEEncC
        ln_name=VCEEncC/VCEEncC.elf
        bin_path=`which vceencc`
        if [ $? -eq 0 ]; then
            ln -s "$bin_path" $ln_name
        else
            echo '#!/bin/sh' >$ln_name
            echo 'exit 1' >>$ln_name
            chmod +x $ln_name
            echo 'Placed "do-nothing" command.'
        fi
        echo 'Done.'
    fi
fi

if [ -e Library/libmediainfo.so ]; then
    echo 'libmediainfo.so already exists. skipped.'
else
    echo 'Preparing libmediainfo.so...'
    curl -Lo dltmp.zip "$libmediainfo_zip_uri"
    sha256sum dltmp.zip | grep -q "^$libmediainfo_sha256" || exit
    mkdir -p Library
    unzip -j dltmp.zip -d Library
    rm dltmp.zip
    mv Library/LICENSE Library/libmediainfo_LICENSE
fi

if [ -e tsreadex ]; then
    echo 'tsreadex already exists. skipped.'
else
    echo 'Preparing tsreadex...'
    mkdir tsreadex && cd tsreadex || exit
    curl -L "$tsreadex_src_uri" | tar xzf -
    cd tsreadex-* && make || exit
    cp tsreadex ../tsreadex.elf
    cp License.txt Readme.txt ..
    cd ..
    rm -rf tsreadex-*
    cd ..
    echo 'Done.'
fi

if [ -e psisiarc ]; then
    echo 'psisiarc already exists. skipped.'
else
    echo 'Preparing psisiarc...'
    mkdir psisiarc && cd psisiarc || exit
    curl -L "$psisiarc_src_uri" | tar xzf -
    cd psisiarc-* && make || exit
    cp psisiarc ../psisiarc.elf
    cp License.txt Readme.txt ..
    cd ..
    rm -rf psisiarc-*
    cd ..
    echo 'Done.'
fi

if [ -e psisimux ]; then
    echo 'psisimux already exists. skipped.'
else
    echo 'Preparing psisimux...'
    mkdir psisimux && cd psisimux || exit
    curl -L "$psisimux_src_uri" | tar xzf -
    cd psisimux-* && make || exit
    cp psisimux ../psisimux.elf
    cp License.txt Readme.txt ..
    cd ..
    rm -rf psisimux-*
    cd ..
    echo 'Done.'
fi

cd ..

./thirdparty/Python/bin/python -m poetry env use "`readlink -f ./thirdparty/Python/bin`/python"
./thirdparty/Python/bin/python -m poetry install --only main --no-root
./thirdparty/Python/bin/python -m poetry run python KonomiTV.py
