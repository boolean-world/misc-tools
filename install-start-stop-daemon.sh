#!/bin/bash
#Script to install start-stop-daemon on CentOS/Fedora.

die() {
	echo $1
	exit 1
}

set -e

if [[ $EUID -ne 0 ]]; then
	die "Please run this script as root."
fi

if which start-stop-daemon &> /dev/null; then
	die "start-stop-daemon is already installed!"
fi

tools=(gcc make xz)
install_pkgs=()

for ((i = 0; i < ${#tools[@]}; i++)); do
	if ! which ${tools[i]} &> /dev/null; then
		install_pkgs+=(${tools[i]})
	fi
done

if [[ ${#install_pkgs[@]} -ne 0 ]]; then
	yum install ${install_pkgs[@]} -y
fi

cd /tmp
wget http://http.debian.net/debian/pool/main/d/dpkg/dpkg_1.16.18.tar.xz -O dpkg_1.16.18.tar.xz
tar -xf dpkg_1.16.18.tar.xz
cd dpkg-1.16.18
./configure --disable-dselect --disable-rpath --disable-update-alternatives --disable-install-info --disable-unicode
cd lib
make
cd ../utils
make
cp start-stop-daemon /usr/bin/start-stop-daemon

echo "Installed start-stop-daemon at /usr/bin/start-stop-daemon."

if [[ ${#install_pkgs[@]} -ne 0 ]]; then
	echo "The following packages were installed: ${install_pkgs[@]}"
	read -n 1 -p "Remove [y/N]?" choice
	if [[ $choice == y ]]; then
		yum remove ${install_pkgs[@]} -y
		echo
	fi
fi
