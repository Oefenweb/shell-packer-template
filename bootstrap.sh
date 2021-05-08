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

  python_version="$(python3 --version 2>&1 | awk '{print $2}')";
  python_version_major_minor="$(echo "${python_version}" | cut -c 1-3)";

  pip_download_url='https://bootstrap.pypa.io/pip/get-pip.py';
  if [ "${python_version_major_minor}" == '3.5' ]; then
    pip_download_url='https://bootstrap.pypa.io/pip/3.5/get-pip.py';
  fi

  curl -sL "${pip_download_url}" | python3 -;
  pip3 install "${ANSIBLE_VERSION_STRING}";
else
  apt-get -y install python python-dev;

  pip_download_url='https://bootstrap.pypa.io/pip/2.7/get-pip.py';

  curl -sL "${pip_download_url}" | python2 -;
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
