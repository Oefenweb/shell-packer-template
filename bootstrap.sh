#!/bin/sh -eux

# ansible
apt-get -y update;
apt-get -y install curl build-essential libffi-dev libssl-dev;

ANSIBLE_VERSION_STRING='ansible';
if [ "${ANSIBLE_VERSION}" != 'latest' ]; then
  ANSIBLE_VERSION_STRING="${ANSIBLE_VERSION_STRING}==${ANSIBLE_VERSION}";
fi

if [ "${PYTHON_VERSION}" = '3' ]; then
  apt-get -y install python3 python3-dev;
  curl -sL https://bootstrap.pypa.io/get-pip.py | python3 -;
  pip3 install "${ANSIBLE_VERSION_STRING}";
else
  apt-get -y install python python-dev;
  curl -sL https://bootstrap.pypa.io/get-pip.py | python2 -;
  pip2 install "${ANSIBLE_VERSION_STRING}";
fi

mkdir -p /etc/ansible;
cat << EOF > /etc/ansible/ansible.cfg
[defaults]
interpreter_python = /usr/bin/python${PYTHON_VERSION}
EOF

# sudoers
sed -i \
  -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' \
  -e 's/%sudo\s*ALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g' \
  /etc/sudoers \
;
