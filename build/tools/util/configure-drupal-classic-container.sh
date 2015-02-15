#!/bin/bash

DIR=`dirname $0`
CURDIR=`pwd`

#
# Make sure apt is up-to-date and the distro has all current versions of packages installed
#
apt-get update
apt-get upgrade -y

#
# Here we install common tools.
#
apt-get install -y nano git openssh-server openssh-client debconf-utils man

#
# Install MySQL (MariaDB)
#
apt-get install -y software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://mirror.stshosting.co.uk/mariadb/repo/10.0/ubuntu trusty main'

apt-get -y update
apt-get install -y mariadb-server mariadb-client
update-rc.d mysql defaults
cat "$DIR/config/my.cnf" > /etc/mysql/my.cnf
#service mysql start

#
# Install Apache Httpd
#
apt-get install -y apache2 apache2-utils
update-rc.d apache2 defaults
#service apache2 start

#
# Install PHP + APC
#
apt-get install -y php5 php-apc php5-mysql php5-gd php-pear

#
# Install Java 7 (required by Tomcat and Solr)
#
apt-get install -y openjdk-7-jre

#
# Install Tomcat 7
#
apt-get install -y tomcat7 tomcat7-admin
update-rc.d tomcat7 defaults
cat "$DIR/config/tomcat-users.xml" > /etc/tomcat7/tomcat-users.xml

#
# Install Solr
#
wget "http://apache.mirror.anlx.net/lucene/solr/4.10.3/solr-4.10.3.tgz" -O /tmp/solr-4.10.3.tgz
cd /tmp
tar -xzf /tmp/solr-4.10.3.tgz
cp /tmp/solr-4.10.3/dist/solrj-lib/* /usr/share/tomcat7/lib/
cp /tmp/solr-4.10.3/example/lib/ext/* /usr/share/tomcat7/lib/
cp /tmp/solr-4.10.3/example/resources/log4j.properties /var/lib/tomcat7/conf/
chgrp tomcat7 /var/lib/tomcat7/conf/log4j.properties
cp /tmp/solr-4.10.3/dist/solr-4.10.3.war /var/lib/tomcat7/webapps/solr.war
chown tomcat7:tomcat7 /var/lib/tomcat7/webapps/solr.war

cp "$DIR/config/tomcat-solr.xml" /etc/tomcat7/Catalina/localhost/solr.xml
mkdir /var/lib/solr
rsync -av rsync -av /tmp/solr-4.10.3/example/solr/ /var/lib/solr/
chown -R tomcat7:tomcat7 /var/lib/solr
chmod -R u+rw /var/lib/solr
chmod go-rwx /var/lib/solr
cd "$CURDIR"
unlink /tmp/solr-4.10.3.tgz
