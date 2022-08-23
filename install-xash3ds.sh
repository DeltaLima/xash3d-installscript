#!/bin/bash

hlds_build=8684
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"


case $1 in 
"client")
      CLIENT=true
      PACKAGES="git curl build-essential gcc-multilib g++-multilib python python2 libsdl2-dev:i386 libfontconfig-dev:i386 libfreetype6-dev:i386"
      WAF_OPTION="--enable-utils --enable-stb"
      export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig
;;
"server")
CLIENT=false
      XASHDS_PORT=27015
      CLIENT=false
      PACKAGES="build-essential  ca-certificates  cmake  curl  git  gnupg2 g++-multilib lib32gcc1-s1 libstdc++6:i386 python unzip xz-utils zip"
      WAF_OPTION="-d"
;;
*)
      echo "Usage: ./$0 [server|client]"
      echo ""
      echo "Description: Script to install an Xash3D-FWGS client or Xash3D dedicated server with game data from steamcmd"
      echo "Server tested on Debian 11 ; Client tested on Ubuntu 20.04"
      echo "Origin: https://git.la10cy.net/DeltaLima/xash3ds-installscript"
      echo ""
      echo "Resources we are using:"
      echo $steamcmd_url
      echo $hlds_url
      echo https://github.com/FWGS/xash3d-fwgs
      exit 1
;;
esac

echo "= Creating directories ="
XASH3D_BASEDIR=$(pwd)/build
mkdir -p $XASH3D_BASEDIR/result


echo "= Performing apt install ="
sudo dpkg --add-architecture i386
sudo apt update
sudo apt-get install -y --no-install-recommends $PACKAGES

echo "= Compiling xash3d-fwgs ="
## compile xash3ds
# go to build directory
cd $XASH3D_BASEDIR
git clone --recursive https://github.com/FWGS/xash3d-fwgs
mkdir -p xash3d-fwgs/bin/
cd xash3d-fwgs
## old if you use deprecated xash3d
## cmake -DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ../
## make

./waf configure -T release $WAF_OPTION
./waf build
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

echo "= fetching hlds with steamcmd ="
## fetch steamcmd
curl -L "$steamcmd_url" | tar xzvf - 
## run half-life download from steam server with steamcmd
## If grep find Error then fetch the hlds zip from github
if ./steamcmd.sh +runscript hlds.install | grep Error
then
    echo "= !! There was an error fetching hlds with steamcmd. Fetching it from github !! ="
    echo $hlds_url
    ## this is just another source you can use instead of steamcmd. 
    curl -LJO "$hlds_url" 
    unzip "hlds_build_$hlds_build.zip" -d "hlds_build_$hlds_build" 
    cp -R "hlds_build_$hlds_build/hlds_build_$hlds_build"/* $XASH3D_BASEDIR/result/
fi

## copy xash3d binaries to result
## place Xash3D binaries in result and overwrite all
echo "= copy xash3d binaries to build/result"
cp -R $XASH3D_BASEDIR/xash3d-fwgs/bin/* $XASH3D_BASEDIR/result/

touch $XASH3D_BASEDIR/result/valve/listip.cfg
touch $XASH3D_BASEDIR/result/valve/banned.cfg
# it seems that the build actually (21.08.2022) is buggy and does not exec server.cfg by its own
if [ "$1" == "server" ]
then
      echo "= Creating start.sh script for dedicated server in build/result ="
      echo "./xash +ip 0.0.0.0 -port $XASHDS_PORT -pingboost 1 -timeout 3 +map boot_camp +exec server.cfg" > $XASH3D_BASEDIR/result/start.sh
      chmod +x $XASH3D_BASEDIR/result/start.sh
      echo "= If you need an example config for a public server, have a look into https://github.com/FWGS/xashds-docker/tree/master/valve ="
fi

echo "= DONE! If everything went well an no errors occured you can just run your game/server from $XASH3D_BASEDIR/result/ ="
echo "= starting server: ./start.sh ; starting game client ./xash3d ="