# xash3ds-installscript

Origin of this is https://git.la10cy.net/DeltaLima/xash3d-installscript

This script install an ready to run Half-Life Xash3D Game client or dedicated server under Debian 11/12 and Ubuntu 20.04 (those i tested so far) by downloading game data from steam directly with the free steamcmd tool from valve.
Just run the script and play :) 

```
Usage: ./install-xash3d.sh [server|client] [install|update] [0.19|0.20]

Description: Script to install an Xash3D engine full game client or dedicated server with game data from steamcmd
Server tested on Debian 11 ; Client tested on Ubuntu 20.04
Origin: https://git.la10cy.net/DeltaLima/xash3d-installscript

You can override following variables default values:
XASH_INSTALL_DIR, XASH_DS_PORT and XASH_BUILD_DIR

Example:


1) Install client version 0.20 located in ~/Games/Xash3D where the build directory is as well
  
  XASH_INSTALL_DIR=~/Games/Xash3D XASH_BUILD_DIR=$XASH_INSTALL_DIR/build ./install-xash3d.sh client install 0.20
  
2) Install server version '0.19' into '~/opt/xashds_oldengine'

  XASH_INSTALL_DIR=~/opt/xashds_old ./install-xash3d.sh server update 0.19


Resources we are using:
https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
https://github.com/DevilBoy-eXe/hlds/releases/download/8684/hlds_build_8684.zip
0.20: https://github.com/FWGS/xash3d-fwgs
0.19: https://gitlab.com/tyabus/xash3d
```

To install the server run following command in the directory where you checked this git into
```
./install-xash3ds.sh server install [Version]
```

To install the FULL PLAYABLE client with all game data (steamcmd thx <3) run this
Version 0.19 is actually broken as client, please use `0.20`
```
./install-xash3ds.sh client install 0.20 
```

Your server or gamefiles (you can run server first and then rerun afterwards with client to get the full package) are in
```
/path/to/repo/xash3ds-installscript/build/result
```

from there you can run the server 
```
./start.sh
```

or the game to have a frag
```
./start-xash3d.sh
```

You can easly update both, client and server (example client):
```
./install-xash3d.sh client update [Version]
```

Have a look on my servers at https://HL.LA10CY.NET :) Happy fragging!

This script is based on the work of https://github.com/FWGS/xashds-docker/ and https://github.com/FWGS/xash3d-fwgs and https://gitlab.com/tyabus/xash3d
