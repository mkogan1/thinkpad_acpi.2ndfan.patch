#!/bin/bash
set -x

# kernel version number from currently running kernel!

KVER=`uname -r |cut -d- -f1`
#wget https://www.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
rm -rf ./linux-$KVER
#rm linux-$KVER.tar.xz
if [[ ! -e linux-$KVER.tar.xz ]]; then
  axel -a https://www.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
fi
#nice ionice tar xJvf linux-$KVER.tar.xz
nice ionice tar xJf linux-$KVER.tar.xz
cd linux-$KVER
nice make mrproper |& ccze -Aonolookups
cp /usr/lib/modules/$(uname -r)/build/.config ./
cp /usr/lib/modules/$(uname -r)/build/Module.symvers ./
nice ionice make oldconfig -j$(nproc) |& ccze -Aonolookups
nice ionice make EXTRAVERSION=`uname -r|sed "s/$KVER//"` modules_prepare -j$(nproc) |& ccze -Aonolookups
patch -p1 < ../thinkpad_acpi.2ndfan.patch/thinkpad_acpi.2ndfan.patch
#exit 1
nice ionice make M=drivers/platform/x86 -j$(nproc) |& ccze -Aonolookups
rm ../thinkpad_acpi.ko
cp -v drivers/platform/x86/thinkpad_acpi.ko ../
modinfo ../thinkpad_acpi.ko |& ccze -Aonolookups
#make clean
cd ..
#rm -rf linux-$KVER linux-$KVER.tar.xz
exit 0

xz -f drivers/platform/x86/thinkpad_acpi.ko
mkdir /usr/lib/modules/`uname -r`/updates
cp -f drivers/platform/x86/thinkpad_acpi.ko.xz /usr/lib/modules/`uname -r`/updates
depmod -a
rmmod thinkpad_acpi
modprobe thinkpad_acpi

