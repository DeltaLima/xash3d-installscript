#!/bin/bash

## check if variables for installation are predefined otherwise set defaults
for xashvar in BUILD_DIR INSTALL_DIR DS_PORT
do
  # build helpervariable
  xashvarname=XASH_$xashvar
  # 
  if [ -z ${!xashvarname} ]
  then
    case ${xashvar} in
      BUILD_DIR) XASH_BUILD_DIR=$(pwd)/build ;;
      INSTALL_DIR) XASH_INSTALL_DIR=$(pwd)/xash3d ;;
      DS_PORT) XASH_DS_PORT=27015 ;;
    esac
  fi
  
done

## these variables are from github.com/FWGS/xashds-docker, nice to have :) 
hlds_build=8684
amxmod_version=1.8.2
jk_botti_version=1.43
steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
metamod_url="https://github.com/mittorn/metamod-p/releases/download/1/metamod.so"
amxmod_url="http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz"
jk_botti_url="http://koti.kapsi.fi/jukivili/web/jk_botti/jk_botti-$jk_botti_version-release.tar.xz"

# colors for colored output 8)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

showhelp() {
      echo "Usage: $0 [server|client] [install|update] [0.19|0.20]

Description: Script to install an Xash3D engine full game client or dedicated server with game data from steamcmd
Server tested on Debian 11 ; Client tested on Ubuntu 20.04
Origin: https://git.la10cy.net/DeltaLima/xash3d-installscript

You can override following variables default values:
XASH_INSTALL_DIR, XASH_DS_PORT and XASH_BUILD_DIR

Example:

1) Install server version '0.19' into '~/opt/xashds_oldengine'

  XASH_INSTALL_DIR=~/opt/xashds_old $0 server install 0.19

2) Update client version 0.20 located in ~/Games/Xash3D where the build directory is as well
  
  XASH_INSTALL_DIR=~/Games/Xash3D XASH_BUILD_DIR=\$XASH_INSTALL_DIR/build $0 client update 0.20

Resources we are using:
$steamcmd_url
$hlds_url
0.20: https://github.com/FWGS/xash3d-fwgs
0.19: https://gitlab.com/tyabus/xash3d"
      exit 1
}

function message() {
     case $1 in 
     info)
       MESSAGE_TYPE="${GREEN}INFO${ENDCOLOR}"
     ;;
     warn)
       MESSAGE_TYPE="${YELLOW}WARN${ENDCOLOR}"
     ;;
     error)
       MESSAGE_TYPE="${RED}ERROR${ENDCOLOR}"
     ;;
     esac
     echo -e "[${MESSAGE_TYPE}] $2"
}

function checkerror() {
     if [ $1 -gt 0 ]
     then
          message error "Something went wrong, got wrong exit code ${RED}ERROR${ENDCOLOR}"
          message error "Exit here."
          exit 1
     fi
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

message info "Creating directories"
XASH_GIT_DIR="$(echo ${XASH_GIT_URL} | cut -d / -f5)"
if [ ! -d $XASH_INSTALL_DIR ]
then
  mkdir -p $XASH_INSTALL_DIR && message info "created ${YELLOW}${XASH_INSTALL_DIR}${ENDCOLOR}"
  checkerror $?
fi

if [ ! -d $XASH_BUILD_DIR ]
then
  mkdir -p $XASH_BUILD_DIR && message info "created ${YELLOW}${XASH_BUILD_DIR}${ENDCOLOR}"
  checkerror $?
fi

if [ "$XASH_INSTALL_MODE" == "install" ]
then
	message info "Performing apt install"
	sudo dpkg --add-architecture i386
	sudo apt update
	sudo apt-get install -y --no-install-recommends $PACKAGES
fi

message info "Prepare ${YELLOW}${XASH_GIT_DIR}${ENDCOLOR}"
## compile xash3ds
# prepare and configure for compiling
cd $XASH_BUILD_DIR
case $XASH_INSTALL_MODE in
	"install")
    git clone --recursive $XASH_GIT_URL
    checkerror $?
    test -d ${XASH_GIT_DIR} || mkdir -p ${XASH_GIT_DIR}/bin/
    if [ ! -d ${XASH_GIT_DIR}/bin ]
    then
      mkdir -p ${XASH_GIT_DIR}/bin && message info "created ${YELLOW}${XASH_GIT_DIR}/bin${ENDCOLOR}"
      checkerror $?
    fi
    checkerror $?
    case $XASH_INSTALL_VERSION in
      0.19)
        cd ${XASH_GIT_DIR}/bin
      ;;
      0.20)
        cd ${XASH_GIT_DIR}
      ;;
    esac
		
		;;
	"update")
		cd ${XASH_GIT_DIR}
    case $XASH_INSTALL_VERSION in
      0.19)
        cd bin
        cmake --cmake-clean-cache ../
        checkerror $?
        cd ../
        if [ "$(ls -A bin)" ]
        then
          rm -Rf bin/*
          checkerror $?
        fi
        git pull
        checkerror $?
        cd bin        
      ;;
      0.20)
        ./waf clean
        checkerror $?
        if [ "$(ls -A bin)" ]
        then
          rm -Rf bin/*
          checkerror $?
        fi
        checkerror $?
        git pull
        checkerror $?
      ;;
    esac
    

		;;
	*)
		exit 1
		;;
esac

## build 
message info "Compiling ${YELLOW}${XASH_GIT_DIR}${ENDCOLOR}"
case $XASH_INSTALL_VERSION in
  0.19)
    cmake $CMAKE_OPTIONS ../
    checkerror $?
    make -j2 #VERBOSE=1
    checkerror $?    
  ;;
  0.20)
    ./waf configure -T release $WAF_OPTIONS
    checkerror $?
    ./waf -p build
    checkerror $?
    ./waf install --destdir=bin/
    checkerror $?
  ;;
esac



## here we fetch half-life from steam server
if [ "$XASH_INSTALL_MODE" == "install" ]
then
  message info "prepare steamcmd for downloading gamedata"
	mkdir -p $XASH_BUILD_DIR/steam
  checkerror $?
	cd $XASH_BUILD_DIR/steam
	## an steamcmd automation
	echo "login anonymous
force_install_dir $XASH_INSTALL_DIR
app_set_config 90 mod valve
app_update 90
app_update 90
app_update 90 validate
app_update 90 validate
quit" > $XASH_BUILD_DIR/steam/hlds.install
  checkerror $?

	## fetch steamcmd
  message info "getting steamcmd binary"
	curl -L "$steamcmd_url" | tar xzvf - 
  checkerror $?
	## run half-life download from steam server with steamcmd
	## If grep find Error then fetch the hlds zip from github
	message info "downloading gamedata with steamcmd from valve - this takes a while"
	if ./steamcmd.sh +runscript hlds.install | grep Error
	then
	    message warn "${YELLOW}!!${ENDCOLOR} There was an error fetching Half-Life with steamcmd. Fallback download it from github ${YELLOW}!!${ENDCOLOR}"
	    message info "$hlds_url"
	    ## this is just another source you can use instead of steamcmd. 
	    curl -LJO "$hlds_url" 
      checkerror $?
	    unzip "hlds_build_$hlds_build.zip" -d "hlds_build_$hlds_build" 
      checkerror $?
	    cp -R "hlds_build_$hlds_build/hlds_build_$hlds_build"/* $XASH_INSTALL_DIR
      checkerror $?
	fi
fi

## copy xash3d binaries to result
## place Xash3D binaries in result and overwrite all
message info "copy xash3d binaries to ${YELLOW}${XASH_INSTALL_DIR}${ENDCOLOR}"

case $XASH_INSTALL_VERSION in
  0.19)
    cd $XASH_BUILD_DIR/$XASH_GIT_DIR/bin
    case $XASH_INSTALL_TYPE in
      server)
        cp -R engine/xash3d $XASH_INSTALL_DIR/xash
        checkerror $?
      ;;
      client)
        cp -R engine/xash3d mainui/libxashmenu.so vgui_support/libvgui_support.so vgui_support/vgui.so $XASH_INSTALL_DIR
        checkerror $?
      ;;
    esac
  ;;
  0.20)
    cp -R $XASH_BUILD_DIR/$XASH_GIT_DIR/bin/* $XASH_INSTALL_DIR
    checkerror $?
  ;;
esac

# copy icon for desktop file to install dir
if [ "$XASH_INSTALL_TYPE" == "client" ] && [ "$XASH_INSTALL_MODE" == "install" ]
then
  cp ${XASH_BUILD_DIR}/${XASH_GIT_DIR}/game_launch/icon-xash-material.ico ${XASH_INSTALL_DIR}
fi


# it seems that the build actually (21.08.2022) is buggy and does not exec server.cfg by its own
if [ "$XASH_INSTALL_MODE" == "install" ]
then
      case $XASH_INSTALL_TYPE in
        server)
          message info "Creating start.sh script for dedicated server in ${YELLOW}${XASH_INSTALL_DIR}${ENDCOLOR}"
          # all 0.19 xash3d versions are using +port and 0.20 -port 
          case $XASH_INSTALL_VERSION in
            0.19)
              lol="+port"
            ;;
            0.20)
              lol="-port"
            ;;
          esac
          echo "#!/bin/bash
./xash +ip 0.0.0.0 ${lol} ${XASH_DS_PORT} -pingboost 1 -timeout 3 +map boot_camp +exec server.cfg
echo screenname xash_${XASH_INSTALL_VERSION}_${XASH_DS_PORT}" > $XASH_INSTALL_DIR/start.sh
          checkerror $?

          chmod +x $XASH_INSTALL_DIR/start.sh
          checkerror $?
          
          echo "After=network.target

[Service]
User=$(whoami)
WorkingDirectory=${XASH_INSTALL_DIR}
#Type=oneshot
#StandardOutput=journal
ExecStart=${XASH_INSTALL_DIR}/start.sh
ExecStop=/bin/kill -9 \$MAINPID

[Install]
WantedBy=multi-user.target" > $XASH_INSTALL_DIR/xashds_${XASH_INSTALL_VERSION}_${XASH_DS_PORT}.service
          checkerror $?
          
          touch $XASH_INSTALL_DIR/valve/listip.cfg
          touch $XASH_INSTALL_DIR/valve/banned.cfg
          message info "If you need an example config for a public server, have a look into ${YELLOW}https://github.com/FWGS/xashds-docker/tree/master/valve${ENDCOLOR}"
        ;;
        
        client)
          echo "[Desktop Entry]
Name=Xash3D ${XASH_INSTALL_VERSION}
GenericName=Half-Life
Comment=OpenSource Half-Life Engine
Exec=${XASH_INSTALL_DIR}/xash3d
Icon=${XASH_INSTALL_DIR}/icon-xash-material.ico
Terminal=false
Type=Application
StartupNotify=false
Categories=Game;
X-Desktop-File-Install-Version=0.24" > $XASH_INSTALL_DIR/Xash3D_$(echo ${XASH_INSTALL_VERSION} | sed 's/\.//').desktop
          checkerror $?
        ;;
      esac
fi



case $XASH_INSTALL_MODE in
  install)
    message info "${GREEN}DONE!!${ENDCOLOR} Installation completed without erros."
    message info "Your ready to run Xash3D installation is located in"
    message info "${YELLOW}${XASH_INSTALL_DIR}${ENDCOLOR}"
    case $XASH_INSTALL_TYPE in
      client)
        message info "You can run the game with ${YELLOW}'./xash3d'${ENDCOLOR} from the install location"
        message info "To install the game into your applications menu, run:"
        message info "${YELLOW}'desktop-file-install --dir=\$HOME/.local/share/applications ${XASH_INSTALL_DIR}/Xash3D_$(echo $XASH_INSTALL_VERSION | sed 's/\.//').desktop'${ENDCOLOR}"
      ;;
      server)
        message info "You can start the server with ${YELLOW}'./start.sh'${ENDCOLOR} from the install location"
      ;;
    esac
  ;;
  update)
    message info "${GREEN}DONE!!${ENDCOLOR} Update completed without errors."
  ;;
esac
