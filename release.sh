#!/usr/bin/env bash

message() {
  local str color bgcolor strlen boxwidth end bgcolorcode fontcolorcode
  str=${1}
  strlen=${#1}
  boxwidth=100
  if [ -z "$1" ]; then echo "undefined message"; exit; fi
  if [ -z "$2" ]; then bgcolorcode="0"; else bgcolorcode=${2}; fi
  if [ -z "$3" ]; then fontcolorcode="7"; else fontcolorcode=${3}; fi
  if [ -z "$4" ]; then boxwidth=120; else boxwidth={4}; fi
  bgcmd="tput setab $bgcolorcode"
  bgcolor=$($bgcmd)
  colcmd="tput setaf $fontcolorcode"
  color=$($colcmd)
  normal=$(tput sgr0)
  end=$(( $boxwidth-$strlen )); for i in $(seq 1 $end); do str="$str "; done
  whites=""; for i in $(seq 1 $boxwidth); do whites="$whites "; done
  echo "${color}${bgcolor}" >/dev/tty
  echo "$whites" >/dev/tty
  echo "$str" >/dev/tty
  echo "$whites${normal}" >/dev/tty
}

testinstall() {
  message "  testinstall" 2 0
  echo ""
  apt remove gitextractor
  echo ""
  apt update
  echo ""
  apt install gitextractor
  echo ""
}

release() {
  buildroot=${1}
  cd $buildroot
  cd debs/dists/stable/main/shell
  message "  release party!" 0 7
  apt-ftparchive packages . > Packages
  gzip -c Packages > Packages.gz
  apt-ftparchive release . > Release
  gpg --clearsign --default-key 4A3BB067C63F9CD72C5BEC309CCC9F225AD4ACDD -o InRelease Release
  gpg --default-key 4A3BB067C63F9CD72C5BEC309CCC9F225AD4ACDD -abs -o Release.gpg Release

  cd $buildroot
}

buildpackage() {
  buildroot=${1}
  cd $buildroot
  message "  build package" 0 7
  fakeroot dpkg -b debsource debs/dists/stable/main/shell/gitextractor.deb > /dev/null 2>&1
}

clearrepository() {
  buildroot=${1}
  cd $buildroot
  message "  delete old deb package" 0 7
  rm debs/dists/stable/main/shell/*
}

generatemd5sums() {
  buildroot=${1}
  cd $buildroot
  message "   generate md5sums" 0 7
  cd debsource
  find {etc,usr,var} -type f -exec md5sum "{}" + > DEBIAN/md5sums
  cd $buildroot
}

main() {
  local buildroot
  buildroot=`pwd`
  clearrepository $buildroot
  generatemd5sums $buildroot
  buildpackage $buildroot
  release $buildroot
  testinstall
}

main
