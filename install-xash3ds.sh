#!bin/bash

hlds_build=8308
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

XASH3D_BASEDIR=$(pwd)/build
mkdir -p $XASH3D_BASEDIR/result

# Prerequisits satisfied?
sudo dpkg --add-architecture i386
apt-get install -y --no-install-recommends build-essential  ca-certificates  cmake  curl  git  gnupg2 g++-multilib lib32gcc1-s1 libstdc++6:i386 python unzip xz-utils zip

## compile xash3ds
# go to build directory
cd $XASH3D_BASEDIR
git clone --recursive https://github.com/FWGS/xash3d
mkdir -p xash3d/build

cd xash3d/build
cmake -DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ../
make
mv engine/xash3d $XASH3D_BASEDIR/result/xashds

## get half-life data from steam
mkdir -p $XASH3D_BASEDIR/steam
cd $XASH3D_BASEDIR/steam
echo "login anonymous
force_install_dir $XASH3D_BASEDIR/result
app_set_config 90 mod valve
app_update 90
app_update 90
app_update 90 validate
app_update 90 validate
quit" > $XASH3D_BASEDIR/steam/hlds.install

curl -sL "$steamcmd_url" | tar xzvf - 
./steamcmd.sh +runscript hlds.install

## get half-life data from steam
curl -sLJO "$hlds_url" 
unzip "hlds_build_$hlds_build.zip" -d "hlds_build_$hlds_build" 
cp -R "hlds_build_$hlds_build/hlds"/* $XASH3D_BASEDIR/result/


touch $XASH3D_BASEDIR/result/valve/listip.cfg
touch $XASH3D_BASEDIR/result/valve/banned.cfg
echo "./xash3ds +ip 0.0.0.0:27015 -pingboost 1" > $XASH3D_BASEDIR/result/start.sh
chmod +x $XASH3D_BASEDIR/result/start.sh
cd $XASH3D_BASEDIR/result