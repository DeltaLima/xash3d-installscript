#!bin/bash

hlds_build=8308
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

if [ -z "$1" ]
then
    XASHDS_PORT=27015
else
    XASHDS_PORT=$1
fi

if [ "$2" == "client" ]
then
    CLIENT=true
else 
    CLIENT=false
fi



XASH3D_BASEDIR=$(pwd)/build
mkdir -p $XASH3D_BASEDIR/result

# Prerequisits satisfied?
sudo dpkg --add-architecture i386
apt-get install -y --no-install-recommends build-essential  ca-certificates  cmake  curl  git  gnupg2 g++-multilib lib32gcc1-s1 libstdc++6:i386 python unzip xz-utils zip

## compile xash3ds
# go to build directory
cd $XASH3D_BASEDIR
git clone --recursive https://github.com/FWGS/xash3d-fwgs
mkdir -p xash3d-fwgs/bin/
cd xash3d-fwgs
## old if you use deprecated xash3d
## cmake -DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ../
## make
if [ $CLIENT = false ]
then 
    WAF_OPTION=""
else
    WAF_OPTION="-d"
fi

WAF_OPTION

./waf configure -T release $WAF_OPTION
./waf make
./waf install --destdir=bin/


## here we fetch half-life from steam server
mkdir -p $XASH3D_BASEDIR/steam
cd $XASH3D_BASEDIR/steam
## an steamcmd automation
echo "login anonymous
force_install_dir $XASH3D_BASEDIR/result
app_set_config 90 mod valve
app_update 90
app_update 90
app_update 90 validate
app_update 90 validate
quit" > $XASH3D_BASEDIR/steam/hlds.install

## fetch steamcmd
curl -sL "$steamcmd_url" | tar xzvf - 
## run half-life download from steam server with steamcmd
./steamcmd.sh +runscript hlds.install
## place Xash3D binaries in result and overwrite all
cp -R $XASH3D_BASEDIR/xash3d-fgws/bin/* $XASH3D_BASEDIR/result/
## this is just another source you can use instead of steamcmd. 
## curl -sLJO "$hlds_url" 
## unzip "hlds_build_$hlds_build.zip" -d "hlds_build_$hlds_build" 
## cp -R "hlds_build_$hlds_build/hlds"/* $XASH3D_BASEDIR/result/


touch $XASH3D_BASEDIR/result/valve/listip.cfg
touch $XASH3D_BASEDIR/result/valve/banned.cfg
echo "./xash +ip 0.0.0.0 -port $XASHDS_PORT -pingboost 1 -timeout 3 +map boot_camp" > $XASH3D_BASEDIR/result/start.sh
chmod +x $XASH3D_BASEDIR/result/start.sh
cd $XASH3D_BASEDIR/result