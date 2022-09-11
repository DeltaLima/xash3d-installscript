#!/bin/bash

hlds_build=8684
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

if [ -z $XASHDS_PORT ]
then
  XASHDS_PORT=27015
fi

showhelp() {
      echo "Usage: ./$0 [server|client] [install|update] [0.19|0.20]"
      echo ""
      echo "Description: Script to install an Xash3D-FWGS client or Xash3D dedicated server with game data from steamcmd"
      echo "Server tested on Debian 11 ; Client tested on Ubuntu 20.04"
      echo "Origin: https://git.la10cy.net/DeltaLima/xash3ds-installscript"
      echo ""
      echo "Resources we are using:"
      echo $steamcmd_url
      echo $hlds_url
      echo "0.20: https://github.com/FWGS/xash3d-fwgs"
      echo "0.19: https://gitlab.com/tyabus/xash3d"
      exit 1
}

case $3 in 
	"0.19")
        XASH_GIT_URL="https://gitlab.com/tyabus/xash3d"
	;;
        
	"0.20")
        XASH_GIT_URL="https://github.com/FWGS/xash3d-fwgs"
	;;
  
	*)
		showhelp
	;;
esac
XASH_INSTALL_VERSION=$3

case $2 in 
	"update")
	;;

	"install")
	;;

	*)
		showhelp
	;;
esac
XASH_INSTALL_MODE=$2

case $1 in 
	"client")
        case $XASH_INSTALL_VERSION in
          0.19)
            CMAKE_OPTIONS='-DXASH_DOWNLOAD_DEPENDENCIES=yes -DXASH_STATIC=ON-DXASH_DLL_LOADER=ON -DXASH_VGUI=ON -DMAINUI_USE_STB=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"'
          ;;
          
          0.20)
            PACKAGES="git curl build-essential gcc-multilib g++-multilib python python2 libsdl2-dev:i386 libfontconfig-dev:i386 libfreetype6-dev:i386"
            WAF_OPTIONS="--enable-utils --enable-stb"
          ;;
        esac
        
	      
	;;
	"server")
        case $XASH_INSTALL_VERSION in
          0.19)
            CMAKE_OPTIONS='-DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"'
          ;;
          0.20)
            PACKAGES="build-essential  ca-certificates  cmake  curl  git  gnupg2 g++-multilib lib32gcc1-s1 libstdc++6:i386 python unzip xz-utils zip"
            WAF_OPTIONS="-d"
          ;;
        esac
	;;
	*)
	showhelp
	;;
esac
XASH_INSTALL_TYPE=$1

export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig

echo "= Creating directories ="
XASH3D_BASEDIR=$(pwd)/build
XASH_GIT_DIR="$(echo ${XASH_GIT_URL} | cut -d / -f5)"
XASH3D_RESULTDIR=$XASH3D_BASEDIR/result
test -d $XASH3D_RESULTDIR || mkdir -p $XASH3D_RESULTDIR

if [ "$XASH_INSTALL_MODE" == "install" ]
then
	echo "= Performing apt install ="
	sudo dpkg --add-architecture i386
	sudo apt update
	sudo apt-get install -y --no-install-recommends $PACKAGES
fi

echo "= Compiling xash3d-fwgs ="
## compile xash3ds
# go to build directory
cd $XASH3D_BASEDIR
case $XASH_INSTALL_MODE in
	"install")
		git clone --recursive $XASH_GIT_URL
		mkdir -p ${XASH_GIT_DIR}/bin/
		cd ${XASH_GIT_DIR}/bin
		;;
	"update")
		cd ${XASH_GIT_DIR}
    case $XASH_INSTALL_VERSION in
      0.19)
        cd bin
        cmake --cmake-clean-cache ../
        cd ../
        rm -Rf bin/*
        git pull
        cd bin        
      ;;
      0.20)
        ./waf clean
        rm bin/*
        git pull
      ;;
    esac
    

		;;
	*)
		exit 1
		;;
esac

##   oldstuff  ##
## old if you use deprecated xash3d 0.19.3
## cmake -DXASH_DEDICATED=ON -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ../
## make
##   oldstuff  ##

## build 

case $XASH_INSTALL_VERSION in
  0.19)
    cmake $CMAKE_OPTIONS ../
    make -j2 #VERBOSE=1
    
  ;;
  0.20)
    ./waf configure -T release $WAF_OPTIONS
    ./waf -p build
    ./waf install --destdir=bin/
  ;;
esac



## here we fetch half-life from steam server
if [ "$XASH_INSTALL_MODE" == "install" ]
then
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
	echo "= This can take a while depending ony your connection ="
	if ./steamcmd.sh +runscript hlds.install | grep Error
	then
	    echo "= !! There was an error fetching hlds with steamcmd. Fetching it from github !! ="
	    echo $hlds_url
	    ## this is just another source you can use instead of steamcmd. 
	    curl -LJO "$hlds_url" 
	    unzip "hlds_build_$hlds_build.zip" -d "hlds_build_$hlds_build" 
	    cp -R "hlds_build_$hlds_build/hlds_build_$hlds_build"/* $XASH3D_RESULTDIR
	fi
fi

## copy xash3d binaries to result
## place Xash3D binaries in result and overwrite all
echo "= copy xash3d binaries to build/result"

case $XASH_INSTALL_VERSION in
  0.19)
    cd $XASH3D_BASEDIR/$XASH_GIT_DIR/bin
    case $XASH_INSTALL_TYPE in
      server)
        cp -R engine/xash3d $XASH3D_RESULTDIR/xash
      ;;
      client)
        cp -R engine/xash3d mainui/libxashmenu.so vgui_support/libvgui_support.so vgui_support/vgui.so $XASH3D_RESULTDIR
      ;;
    esac
  ;;
  0.20)
    cp -R $XASH3D_BASEDIR/$XASH_GIT_DIR/bin/* $XASH3D_RESULTDIR
  ;;
esac



# it seems that the build actually (21.08.2022) is buggy and does not exec server.cfg by its own
if [ "$XASH_INSTALL_MODE" == "install" ]
then
      case $XASH_INSTALL_TYPE in
        server)
          echo "= Creating start.sh script for dedicated server in build/result ="
          case $XASH_INSTALL_VERSION in
            0.19)
              lol="+port"
            ;;
            0.20)
              lol="-port"
            ;;
          esac
          echo "#!/bin/bash
screen -d -m -S xash_${XASH_INSTALL_VERSION}_${XASHDS_PORT} ./xash +ip 0.0.0.0 ${lol} ${XASHDS_PORT} -pingboost 1 -timeout 3 +map boot_camp +exec server.cfg
echo screenname xash_${XASH_INSTALL_VERSION}_${XASHDS_PORT}" > $XASH3D_RESULTDIR/start.sh

          chmod +x $XASH3D_BASEDIR/result/start.sh
          touch $XASH3D_RESULTDIR/valve/listip.cfg
          touch $XASH3D_RESULTDIR/valve/banned.cfg
          echo "= If you need an example config for a public server, have a look into https://github.com/FWGS/xashds-docker/tree/master/valve ="
        ;;
        
        client)
          echo "[Desktop Entry]
Name=Xash3d ${XASH_INSTALL_VERSION}
GenericName=Half-Life
Comment=OpenSource Half-Life Engine v${XASH_INSTALL_VERSION}
Exec=${XASH3D_RESULTDIR}/xash3d
Terminal=false
Type=Application
StartupNotify=false
Categories=Game;
X-Desktop-File-Install-Version=0.24" > $XASH3D_RESULTDIR/Xash3D_${XASH_INSTALL_VERSION}.desktop
        ;;
      esac
fi

echo "= DONE! If everything went well an no errors occured you can just run your game/server from $XASH3D_BASEDIR/result/ ="
echo "= starting server: ./start.sh ; starting game client ./xash3d ="
