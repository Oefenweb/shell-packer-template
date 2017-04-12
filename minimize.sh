#!/bin/sh -eux

# TODO: Fix this in preseed.cfg
swapvolume="$(lvscan | awk '{ print $2 }' | grep swap | sed "s/'//g")";
swapoff "${swapvolume}";
lvremove -f "${swapvolume}";

rootvolume="$(lvscan | awk '{ print $2 }' | grep root | sed "s/'//g")";
lvextend -l +100%FREE "${rootvolume}";
resize2fs "${rootvolume}";

# Zero out free space on /
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count - 1))
whitespacefile='/whitespace';
dd if=/dev/zero of="${whitespacefile}" bs=1M count="${count}" || echo "dd exit code $? is suppressed";
rm "${whitespacefile}";

# Zero out free space on /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}');
count=$(($count - 1));
whitespacefile='/boot/whitespace';
dd if=/dev/zero of="${whitespacefile}" bs=1M count="${count}" || echo "dd exit code $? is suppressed";
rm "${whitespacefile}";

swapfile='/swap';
count=$(stat -c '%s' "${swapfile}");
count=$(($count / 1024));
swapoff "${swapfile}";
dd if=/dev/zero of="${swapfile}" bs=1024 count="${count}" || echo "dd exit code $? is suppressed";
mkswap "${swapfile}";

sync;
