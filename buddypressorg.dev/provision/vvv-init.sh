#!/bin/bash
SITE_DOMAIN="buddypressorg.dev"
BASE_DIR=$( dirname $( dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ) )
PROVISION_DIR="$BASE_DIR/$SITE_DOMAIN/provision"
SITE_DIR="$BASE_DIR/$SITE_DOMAIN/public_html"
WPCLI_PLUGINS="akismet bbpress-no-admin camptix email-post-changes syntaxhighlighter"

source $BASE_DIR/helper-functions.sh
wme_create_logs "$BASE_DIR/$SITE_DOMAIN/logs"

if [ ! -d $SITE_DIR ]; then
	printf "\n#\n# Provisioning $SITE_DOMAIN\n#\n"

	wme_import_database "buddypressorg_dev" $PROVISION_DIR

	# Set up WordPress
	wp core download --path=$SITE_DIR/wordpress --allow-root
	cp $PROVISION_DIR/wp-config.php $SITE_DIR

	# bb-base theme
	svn co https://meta.svn.wordpress.org/sites/trunk/buddypress.org/public_html/wp-content/ $SITE_DIR/wp-content

	# BuddyPress /trunk
	svn co https://plugins.svn.wordpress.org/buddypress/trunk $SITE_DIR/wp-content/plugins/buddypress

	#bbPress /trunk
	svn co https://plugins.svn.wordpress.org/bbpress/trunk $SITE_DIR/wp-content/plugins/bbpress

	# Other plugins
	wp plugin install $WPCLI_PLUGINS --path=$SITE_DIR/wordpress --allow-root

	# Extra env. set up.
	mkdir $SITE_DIR/wp-content/mu-plugins
	cp $PROVISION_DIR/sandbox-functionality.php $SITE_DIR/wp-content/mu-plugins/

else
	printf "\n#\n# Updating $SITE_DOMAIN\n#\n"

	wp core   update --path=$SITE_DIR/wordpress --allow-root
	wp plugin update --path=$SITE_DIR/wordpress --allow-root --all
	svn up $SITE_DIR/wp-content
	svn up $SITE_DIR/wp-content/plugins/buddypress
	svn up $SITE_DIR/wp-content/plugins/bbpress

fi
