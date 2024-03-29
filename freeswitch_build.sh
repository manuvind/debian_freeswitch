# #!/bin/sh -e
# #
# # Helper script for building Debian packages
# #
# # FreeSWITCH will be downloaded from Git into ./freeswitch/ and built.
# # The resulting Debian packages will be placed in the current directory.
# #
# # You should run this as an unprivileged user, with sudo permissions
# # to install build dependencies (add your user to the sudo group).
# #
# # Build dependencies:
# # $ apt-get -y install git dpkg-dev devscripts sudo
# # All other dependencies are installed by the script.
# #
# # If modules.conf exists in the current directory then it will be
# # used to select the modules to be built.
# #

# Configuration
BRANCH=v1.2.stable
DCH_DISTRO=UNRELEASED
SIGN_KEY=8D12F5C1

# Version number for Git checkouts needs to be generated
DISTRO=`lsb_release -cs`
FS_VERSION="$(cat freeswitch/build/next-release.txt | sed -e 's/-/~/g')~n$(date +%Y%m%dT%H%M%SZ)-1~${DISTRO}+1"
(cd freeswitch && build/set-fs-version.sh "$FS_VERSION")
(cd freeswitch && dch -b -m -v "$FS_VERSION" --force-distribution -D "$DCH_DISTRO" "Custom build.")

# Optional: if modules.conf exists use this to select which modules to build
#if [ -f modules.conf ]; then cp modules.conf freeswitch/debian; fi

# Bootstrap debian buildsystem
(cd freeswitch/debian && ./bootstrap.sh -c ${DISTRO})

# Install build dependencies
sudo mk-build-deps -i freeswitch/debian/control

# Build
if [ -z "$SIGN_KEY" ]; then
  (cd freeswitch && dpkg-buildpackage -b -uc)
else
  (cd freeswitch && dpkg-buildpackage -b -k$SIGN_KEY)
fi