#!/bin/bash

# WordPress Installation Script for cPanel servers

############################################

# Specify these variables, should be self-explanatory:
DESTDIR=/home/user/public_html
CPANEL=user
MYSQLDB=user_wp1
MYSQLUSER=user_wp1

############################################

# Generate a random pw for the MySQL db user
MYSQLUSERPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

# Download and extract the WP tarball, clean it up afterwards
wget -qO-  https://wordpress.org/latest.tar.gz | tar --strip-components=1 -xz -C $DESTDIR
rm -f $DESTDIR/latest.tar.gz

# Set up the initial wp-config file
mv $DESTDIR/wp-config-sample.php $DESTDIR/wp-config.php

# Set up the default WP .htaccess file

cat >> $DESTDIR/.htaccess << "EOF"
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

# Make sure everything is chowned to the cPanel user
chown -R $CPANEL:$CPANEL $DESTDIR/* $DESTDIR/.*

# Create MySQL db & user
uapi --user=$CPANEL Mysql create_user name=$MYSQLUSER password=$MYSQLUSERPASS
uapi --user=$CPANEL Mysql create_database name=$MYSQLDB
uapi --user=$CPANEL Mysql set_privileges_on_database user=$MYSQLUSER database=$MYSQLDB privileges=ALL

# Update Salts in the wp-config file
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s $DESTDIR/wp-config.php

# Update wp-config file with MySQL info
echo "DB info in the wp-config.php file"
sed -i 's/database_name_here/'"$MYSQLDB"'/' $DESTDIR/wp-config.php
sed -i 's/username_here/'"$MYSQLUSER"'/' $DESTDIR/wp-config.php
sed -i 's/password_here/'"$MYSQLUSERPASS"'/' $DESTDIR/wp-config.php
grep DB_ $DESTDIR/wp-config.php

echo "*************************************************************"
echo "WP installed, visit the site to complete the installation"
echo "*************************************************************"
