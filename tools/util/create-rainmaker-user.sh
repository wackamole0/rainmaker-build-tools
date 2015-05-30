#!/bin/bash

#
# Keep track of this files location as we will need it for relatively referencing other scripts from its directory
# that we need to run.
#
DIR=`dirname $0`

groupadd -g 1002 rainmaker
useradd -m -g rainmaker -s /bin/bash -u 1002 --password='$6$n1P/KnGE$MwndzwLiUnxCb3kn71GueAzR1un2XDKOCfQ476lQCcJruTO3lcpfopjtuFozdlNuv2eLihbc5mc5SEl9hHZM81' rainmaker

mkdir /home/rainmaker/.ssh
chown rainmaker:rainmaker /home/rainmaker/.ssh
chmod u+rwx /home/rainmaker/.ssh
chmod go-rwx /home/rainmaker/.ssh

cp "$DIR/../config/root/rainmaker_id_rsa" /home/rainmaker/.ssh/id_rsa
chown rainmaker:rainmaker /home/rainmaker/.ssh/id_rsa
chmod ugo-rwx /home/rainmaker/.ssh/id_rsa
chmod u+rw /home/rainmaker/.ssh/id_rsa

cp "$DIR/../config/root/rainmaker_id_rsa.pub" /home/rainmaker/.ssh/id_rsa.pub
chown rainmaker:rainmaker /home/rainmaker/.ssh/id_rsa.pub
chmod ugo-rwx /home/rainmaker/.ssh/id_rsa.pub
chmod u+rw /home/rainmaker/.ssh/id_rsa.pub

cp "$DIR/../config/root/rainmaker_authorized_keys" /home/rainmaker/.ssh/authorized_keys
chown rainmaker:rainmaker /home/rainmaker/.ssh/authorized_keys
chmod ugo-rwx /home/rainmaker/.ssh/authorized_keys
chmod u+rw /home/rainmaker/.ssh/authorized_keys

cp "$DIR/../config/root/rainmaker.sudoers" /etc/sudoers.d/rainmaker
chown root:root /etc/sudoers.d/rainmaker
chmod ugo-rwx /etc/sudoers.d/rainmaker
chmod ug+r /etc/sudoers.d/rainmaker
