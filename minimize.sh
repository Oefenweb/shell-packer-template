#!/bin/sh -eux

# TODO: Fix this in preseed.cfg
# See: https://superuser.com/a/920957
swapvolume="$(lvscan | awk '{ print $2 }' | grep swap | sed "s/'//g")";
if [ -n "${swapvolume}" ]; then
  swapoff "${swapvolume}";
  lvremove -f "${swapvolume}";
  sed -i "\|$(basename "${swapvolume}")|d" /etc/fstab;
fi
swapfile='/swap.img';
if [ -f "${swapfile}" ]; then
  swapoff "${swapfile}";
  rm "${swapfile}";
  sed -i "\|"${swapfile}"|d" /etc/fstab;
fi

rootvolume="$(lvscan | awk '{ print $2 }' | grep root | sed "s/'//g")";
if [ -z "${rootvolume}" ]; then
  rootvolume="$(lvscan | awk '{ print $2 }' | grep ubuntu | sed "s/'//g")";
fi
if [ -n "${rootvolume}" ]; then
  lvextend -l +100%FREE "${rootvolume}";
  resize2fs "${rootvolume}";
fi

# Zero out free space on /
partition='/';
count=$(df --sync -kP ${partition} | tail -n1  | awk -F ' ' '{print $4}');
count=$((count - 1));
whitespacefile="${partition}/whitespace";
dd if=/dev/zero of="${whitespacefile}" bs=1M count="${count}" || echo "dd exit code $? is suppressed";
rm "${whitespacefile}";

# Zero out free space on /boot
partition='/boot';
count=$(df --sync -kP ${partition} | tail -n1  | awk -F ' ' '{print $4}');
count=$((count - 1));
whitespacefile="${partition}/whitespace";
dd if=/dev/zero of="${whitespacefile}" bs=1M count="${count}" || echo "dd exit code $? is suppressed";
rm "${whitespacefile}";

swapfile='/swap';
count=$(stat -c '%s' "${swapfile}");
count=$((count / 1024));
swapoff "${swapfile}";
dd if=/dev/zero of="${swapfile}" bs=1024 count="${count}" || echo "dd exit code $? is suppressed";
mkswap "${swapfile}";

sync;
