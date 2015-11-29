# use OSX keychain for git creds
git config --global credential.helper osxkeychain

# fix PEAR permission problems
chmod -R ug+w /usr/local/Cellar/php56/5.6.16/lib/php
pear config-set php_ini /usr/local/etc/php/5.6/php.ini system

# To have launchd start mysql at login:
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents