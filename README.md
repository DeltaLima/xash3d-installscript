# xash3ds-installscript

Origin of this is https://git.la10cy.net/DeltaLima/xash3ds-installscript

This script install github.com/FGWS/xash3d-fgws automatically under Ubuntu 20.04 and Debian 11 (those i tested so far).

To install the server run following command in the directory where you checked this git into
```
bash install-xash3ds.sh
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

This script is based on the work of https://github.com/FWGS/xashds-docker/ and https://github.com/FGWS/xash3d-fgws
