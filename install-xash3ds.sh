#!bin/bash

hlds_build=8308
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

XASH3D_BASEDIR=$(pwd)/build/xashds
mkdir -p $XASH3D_BASEDIR

sudo dpkg --add-architecture i386
apt-get install -y --no-install-recommends build-essential  ca-certificates  cmake  curl  git  gnupg2 g++-multilib lib32gcc1 libstdc++6:i386 python unzip xz-utils zip
git clone --recursive https://github.com/FWGS/xash3d
mkdir -p xash3d/build

cd xash3d/build
cmake -DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ../
make
mv engine/xash3d XASH3D_BASEDIR/xash3ds

echo "login anonymous
force_install_dir ./xashds
app_set_config 90 mod valve
app_update 90
app_update 90
app_update 90 validate
app_update 90 validate
quit" > ../../build/hlds.install

cd ../../build
curl -sL "$steamcmd_url" | tar xzvf - 
./steamcmd.sh +runscript hlds.install

curl -sLJO "$hlds_url" 
unzip "hlds_build_$hlds_build.zip" -d "/opt/steam/hlds_build_$hlds_build" 
mv "hlds_build_$hlds_build/hlds"/* xashds/ 
rm -rf "hlds_build_$hlds_build" "hlds_build_$hlds_build.zip"

touch $XASH3D_BASEDIR/valve/listip.cfg
touch $XASH3D_BASEDIR/valve/banned.cfg

cd $XASH3D_BASEDIR