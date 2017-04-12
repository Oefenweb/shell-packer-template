#!/bin/sh -eux

# ansible
apt-get -y update;
apt-get -y install curl python python-dev build-essential libffi-dev libssl-dev;
curl -sL https://bootstrap.pypa.io/get-pip.py | python -;
pip install ansible;

# sudoers
sed -i \
  -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' \
  -e 's/%sudo\s*ALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g' \
  /etc/sudoers \
;
