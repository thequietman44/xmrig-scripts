#!/bin/bash

# This script tries to install the packages needed to download/build/run xmrig,
# then downloads and builds from the latest source code. If you have an existing
# build it will move it aside and copy your config.json file to the new build folder.
# I use this to make sure I always have the latest build of xmrig since there are
# often performance improvements.

# This script was written on-the-fly with no regard for best-practice or portability,
# so feel free to refactor using more robust methods :)

if [ $EUID != 0 ]; then

        echo "Running as `whoami`"

        if [ `uname` == "Darwin" ]; then
                # macOS-specific commands
                if [ ! `which brew` ]; then
                        echo "Brew not installed, runhning install script..."
                        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                fi
                brew install cmake libuv libmicrohttpd openssl hwloc
        fi

        # Some version of Ubuntu don't preserve $HOME when using sudo
        # Here we make a note of the original home directory
        echo $HOME > .xmrig-update-home

        echo "Running as `whoami`, elevating to root..."
        sudo "$0" "$@"
        exit $?
else
        # Read back the original home dir path
        XMRIGHOME=`cat .xmrig-update-home`
        # Ubuntu/Debian/generic commands
        apt install -qq git build-essential cmake libuv1-dev libssl-dev libhwloc-dev curl > /dev/null 2>&1
fi

# Get xmrig latest version number
LATEST=`curl -s https://github.com/xmrig/xmrig/blob/master/src/version.h | grep APP_VERSION | awk '{ print $11}' | sed 's/.*<\/span>//g;s/<span.*//g'`
if [ -f $XMRIGHOME/xmrig/build/xmrig ]; then
        INSTALLED=`$XMRIGHOME/xmrig/build/xmrig --version | grep XMRig | awk '{print $2}'`
else
        INSTALLED=""
fi

if [ "$LATEST" == "$INSTALLED" ]; then
        echo "Already running the latest version $INSTALLED"
        exit 0
else
        echo "New version available:    $LATEST"
        echo "Installed version:        $INSTALLED"
fi

# Pause for user confirmation
read -p "Continue with update? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Start in the home directory
cd $XMRIGHOME

if [ -d ~/xmrig ]; then
        echo "Found existing folder ~/xmrig"

        echo "Killing xmrig processes..."
        killall xmrig || echo "xmrig was not running."

        echo "Moving existing folder ~/xmrig to ~/xmrig.old ..."
        mv $XMRIGHOME/xmrig $XMRIGHOME/xmrig.old
fi

echo "Downloading latest source code..."
git clone https://github.com/xmrig/xmrig.git

echo "Change to build directory"
cd xmrig && mkdir build && cd build
echo `pwd`

# Pause briefly to let user review output
sleep 5

echo "Building from source..."
if [ `uname` == "Darwin" ]; then
        # macOS-specific cmake
        cmake .. -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl
else
        cmake ..
fi
make

# Copy old config files
echo "Copying config files from ~/xmrig.old/build/ ..."
cp ../../xmrig.old/build/config* .

echo "Verifying xmrig version..."
./xmrig --version
