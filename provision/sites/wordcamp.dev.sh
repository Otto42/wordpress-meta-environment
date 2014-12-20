#!/bin/bash

SITE_DIR="/srv/www/wordcamp.dev"

if [ ! -d $SITE_DIR ]; then
	printf "\nProvisioning wordcamp.dev\n"

	# Setup WordPress
	wp core download --path=$SITE_DIR/wordpress
	cp /vagrant/config/wordpress-config/sites/wordcamp.dev/wp-config.php                   $SITE_DIR

	# Check out WordCamp.org source code
	svn co https://meta.svn.wordpress.org/sites/trunk/wordcamp.org/public_html/wp-content/ $SITE_DIR/wp-content
	git clone https://github.com/Automattic/camptix.git                                    $SITE_DIR/wp-content/plugins/camptix
	svn co https://plugins.svn.wordpress.org/camptix-network-tools/trunk/                  $SITE_DIR/wp-content/plugins/camptix-network-tools
	svn co https://plugins.svn.wordpress.org/email-post-changes/trunk/                     $SITE_DIR/wp-content/plugins/email-post-changes
	svn co https://plugins.svn.wordpress.org/tagregator/trunk/                             $SITE_DIR/wp-content/plugins/tagregator

	# Setup mu-plugin for local development
	cp /vagrant/config/wordpress-config/sites/wordcamp.dev/sandbox-functionality.php       $SITE_DIR/wp-content/mu-plugins/

	# Install 3rd-party plugins
	PLUGINS=( akismet buddypress bbpress camptix-pagseguro camptix-payfast-gateway core-control debug-bar debug-bar-console debug-bar-cron jetpack wp-multibyte-patch wordpress-importer )
	for i in "${PLUGINS[@]}"
	do :
		wp plugin install $i --path=$SITE_DIR/wordpress
	done

else
	printf "\nUpdating wordcamp.dev\n"

	svn up $SITE_DIR/wp-content
	svn up $SITE_DIR/wp-content/plugins/camptix-network-tools
	svn up $SITE_DIR/wp-content/plugins/email-post-changes
	svn up $SITE_DIR/wp-content/plugins/tagregator
	git -C $SITE_DIR/wp-content/plugins/camptix pull origin master
	wp core   update       --path=$SITE_DIR/wordpress
	wp plugin update --all --path=$SITE_DIR/wordpress
	wp theme  update --all --path=$SITE_DIR/wordpress

fi
