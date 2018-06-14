# cpanelwordpressinstall
Short and simple bash script to install WordPress on a cPanel server

Uses the cPanel API to set up the MySQL database & user

Yes, you can run this as root since it chowns everything to the cPanel user

Just make sure to specify the variables as indicated at the top of the script

Tip:  If MySQL uses prefixes, get the cPanel user's MySQL prefix with this.  Replace $CPANEL with the username.

uapi --user=$CPANEL Mysql get_restrictions  | grep prefix | awk '{ print $2 }'
