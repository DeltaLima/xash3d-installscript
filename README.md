# xash3ds-installscript

Origin of this is https://git.la10cy.net/DeltaLima/xash3ds-installscript

This script install an ready to  play github.com/FGWS/xash3d-fgws automatically under Ubuntu 20.04 and Debian 11 (those i tested so far) by downloading game data from steam directly with the free steamcmd tool from valve.
Just run the script and play :) 

```
Usage: ./install-xash3ds.sh [server|client]

Description: Script to install an Xash3D-FWGS client or Xash3D dedicated server with game data from steamcmd.
Server tested on Debian 11 ; Client tested on Ubuntu 20.04
Origin: https://git.la10cy.net/DeltaLima/xash3ds-installscript

Resources we are using:
https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
https://github.com/DevilBoy-eXe/hlds/releases/download/8684/hlds_build_8684.zip
https://github.com/FWGS/xash3d-fwgs
```

To install the server run following command in the directory where you checked this git into
```
bash install-xash3ds.sh server
```

To install the FULL PLAYABLE client with all game data (steamcmd thx <3) run this
```
bash install-xash3ds.sh client
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
./xash3d
```

Have a look on my servers at https://HL.LA10CY.NET :) Happy fragging!

This script is based on the work of https://github.com/FWGS/xashds-docker/ and https://github.com/FGWS/xash3d-fgws
