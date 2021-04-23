echo "adding fix for MinervaNeue skin"
cat <<EOT >> /bitnami/mediawiki/LocalSettings.php
wfLoadExtension( 'MobileFrontend' );
wfLoadSkin( 'MinervaNeue' );
EOT
