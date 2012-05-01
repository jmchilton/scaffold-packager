#!/bin/bash


SCAFFOLD_PACKAGE_NAME=${SCAFFOLD_PACKAGE_NAME:-scaffold}
# Should be Scaffold, Scaffold_Q+, or Scaffold_Q+S
SCAFFOLD_APP=${SCAFFOLD_APP:-"Scaffold_Q+"}
SCAFFOLD_VERSION=${SCAFFOLD_VERSION:-"3.4.9"}

SCAFFOLD_DOWNLOAD_NAME="Install_${SCAFFOLD_APP}_${SCAFFOLD_VERSION}_UNIX_x64.zip"
SCAFFOLD_LINK="http://www.proteomesoftware.com/download/${SCAFFOLD_DOWNLOAD_NAME}"
if [ ! -e $SCAFFOLD_DOWNLOAD_NAME ];
then
wget $SCAFFOLD_LINK
fi


sed -e "s|PWD|$PWD|g" scaffold_installer_input.template > scaffold_installer_input

unzip -u $SCAFFOLD_DOWNLOAD_NAME
INSTALL_SCRIPT="Install_Scaffold_${SCAFFOLD_VERSION}_UNIX_x64.sh"
chmod +x $INSTALL_SCRIPT
unset DISPLAY
mkdir -p contents/usr/local/
rm -rf contents/usr/local/Scaffold3

sh $INSTALL_SCRIPT < scaffold_installer_input

echo "Checking for fpm..."
type fpm
if [ "$?" != "0" ];
then
echo "fpm is required. Please install ruby and then fpm via `gem install fpm`"
    exit 1
fi

SCRIPT_DIR=$(readlink -f `dirname $0`)
SCAFFOLD_PACKAGE_TYPE=${SCAFFOLD_PACKAGE_TYPE:-"deb"} # Consult fpm documentation for other options
CONTENTS_DIR=$SCRIPT_DIR/contents
echo "Installing Scaffold locally to $CONTENTS_DIR"

# -a all
echo "Packaging scaffold"
fpm -s dir -t $SCAFFOLD_PACKAGE_TYPE -n "${SCAFFOLD_PACKAGE_NAME}" -v $SCAFFOLD_VERSION -C $CONTENTS_DIR .