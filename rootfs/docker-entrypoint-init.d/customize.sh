# Note, using "cat <<'EOT'" means that the heredoc contents are a string literal -- substitution is disabled.

echo "customize.sh -- set url config"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
$wgScriptExtension  = ".php";
EOT

echo "customize.sh -- set contact information"
sed -i -e 's/$wgEmergencyContact/#$wgEmergencyContact/' /bitnami/mediawiki/LocalSettings.php
sed -i -e 's/$wgPasswordSender/#$wgPasswordSender/' /bitnami/mediawiki/LocalSettings.php
cat <<EOT >> /bitnami/mediawiki/LocalSettings.php
\$wgEmergencyContact = "${MEDIAWIKI_EMERGENCY_CONTACT_EMAIL}";
\$wgPasswordSender   = "${MEDIAWIKI_WIKI_EMAIL}";
EOT

echo "customize.sh -- set shared memory settings"
sed -i -e 's/$wgMainCacheType = CACHE_NONE;/$wgMainCacheType = CACHE_DB;/' /bitnami/mediawiki/LocalSettings.php

echo "customize.sh -- enable imagemagik"
sed -i -e 's/#$wgUseImageMagick/$wgUseImageMagick/' /bitnami/mediawiki/LocalSettings.php
sed -i -e 's/#$wgImageMagickConvertCommand/$wgImageMagickConvertCommand/' /bitnami/mediawiki/LocalSettings.php

echo "customize.sh -- upload & image converter"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
# Image Converter
$wgSVGConverter = 'ImageMagick';

# Image converter path
$wgSVGConverterPath = '/usr/bin';

# allow all uploads
$wgStrictFileExtensions = false;
$wgFileExtensions = array_merge( $wgFileExtensions,
	    array( 'doc', 'xls', 'mpp', 'pdf', 'ppt', 'xlsx', 'jpg',
	            'tiff', 'odt', 'odg', 'ods', 'odp','ipynb', 'txt'
		 ));
$wgFileBlacklist = array_diff( $wgFileBlacklist, array ('py') );

$wgVerifyMimeType = false;
$wgCheckFileExtensions = false;
# $wgDisableUploadScriptChecks = true

# Query string length limit for ResourceLoader. You should only set this if
# your web server has a query string length limit (then set it to that limit),
# or if you have suhosin.get.max_value_length set in php.ini (then set it to
# that value)
$wgResourceLoaderMaxQueryLength = -1;

EOT

echo "customize.sh -- customize pages"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
## allow changing page titles
$wgRestrictDisplayTitle =false;

## allow subpages
$wgNamespacesWithSubpages[NS_MAIN] = true;

$wgArticlePath = "/wiki/$1";
$wgUsePathInfo = true;
$wgPhpCli = "/opt/bitnami/php/bin/php";
EOT

echo "customize.sh -- customize email"
cat <<EOT >> /bitnami/mediawiki/LocalSettings.php
\$wgSMTP = array(
	'host' => 'smtp.gmail.com',
        'IDHost' => 'google.com',
        'port' => 25,
        'username' => '${MEDIAWIKI_WIKI_EMAIL}',
);
EOT


echo "customize.sh -- editor extensions"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php

wfLoadExtension( 'MultimediaViewer' );
wfLoadExtension( 'ParserFunctions' );
$wgPFEnableStringFunctions = true;

wfLoadExtension( 'Math' );

## Visual Editor
#
wfLoadExtension( 'VisualEditor' );

// OPTIONAL: Enable VisualEditor in other namespaces
// By default, VE is only enabled in NS_MAIN
$wgVisualEditorNamespaces[] = NS_MAIN;

//enable VisualEditor source mode
$wgVisualEditorEnableWikitext = true;
$wgVisualEditorEnableDiffPage = true;

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
$wgVisualEditorEnableExperimentalCode = true;

$wgVirtualRestConfig['modules']['parsoid'] = array(
  // URL to the Parsoid instance
      // Use port 8142 if you use the Debian package
      'url' => 'http://localhost:8000',
      // Parsoid "domain", see below (optional)
      'domain' => 'localhost',
      // Parsoid "prefix", see below (optional)
      'prefix' => 'localhost'
);

$wgSessionsInObjectCache = true;
$wgVirtualRestConfig['modules']['parsoid']['forwardCookies'] = true;

// add the tool bar to source editor
wfLoadExtension( 'WikiEditor' );

EOT

echo "customize.sh -- semantic mediawiki"
cat <<EOT >> /bitnami/mediawiki/LocalSettings.php

enableSemantics( '${MEDIAWIKI_HOST}' );
require_once __DIR__ . '/extensions/SemanticBundle/SemanticBundle.php';
EOT

echo "customize.sh -- group permissions"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
// make hard to read
$wgGroupPermissions['*']['read'] = false;
# Disable anonymous editing
$wgGroupPermissions['*']['edit'] = false;
# Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;
EOT


echo "customize.sh -- simple plugins"
sed -i -e "s/wfLoadSkin( 'MinervaNeue' );/#wfLoadSkin( 'MinervaNeue' );/" /bitnami/mediawiki/LocalSettings.php
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
//cite
wfLoadExtension( 'Cite' );
//wfLoadExtension( 'Cite/ProcessCite.php' );
//wfLoadExtension( 'Cite/PMID/PMID.php' );
//$wgCiteBookReferencing = true;
//$wgCiteResponsiveReferences = true

//
wfLoadExtension( 'Scribunto' );
$wgScribuntoDefaultEngine = 'luastandalone';

wfLoadExtension( 'TemplateData' );
wfLoadExtension( 'TemplateStyles' );

wfLoadExtension( 'Citoid' );
// If the wiki is being served over https, the https
// // protocol is required in the citoid service url; otherwise the
// // browser will block the request.
//$wgCitoidFullRestbaseURL = 'https://en.wikipedia.org/api/rest_v1/data/citation/mediawiki';
//$wgCitoidServiceUrl = 'https://localhost:1970/api';
$wgCitoidFullRestbaseURL= 'https://en.wikipedia.org/api/rest_';

//code
wfLoadExtension( 'CodeMirror' );
$wgDefaultUserOptions['usecodemirror'] = 1;

//Mobile
wfLoadExtension( 'MobileFrontend' );
wfLoadSkin( 'MinervaNeue' );
$wgMFDefaultSkinClass = 'SkinMinerva';

wfLoadExtension( 'NotebookViewer' );

//google docs
wfLoadExtension( 'GoogleDocs4MW' );

//semantic media wiki results formats
$srfgFormats[] = 'graph';

//widgets
require_once "$IP/extensions/Widgets/Widgets.php";

//gadgets
wfLoadExtension( 'Gadgets' );

//tweeki skin
wfLoadSkin( 'Tweeki' );
//$wgDefaultSkin = "tweeki";


wfLoadExtension( 'PdfHandler' );
EOT


echo "customize.sh -- Google Login"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php
// google login
wfLoadExtension( 'GoogleLogin' );
$wgAuthManagerAutoConfig['primaryauth'] = [];
$wgGLSecret = 'xxxxx';
$wgGLAppId = 'xxxxxx';
$wgGLAllowedDomains = array('example.com', 'example2.com');
$wgWhitelistRead = array( 'Special:GoogleLoginReturn' );
$wgGLAllowedDomainsDB = false;
$wgInvalidUsernameCharacters = '#€';
$wgUserrightsInterwikiDelimiter = "%";
$wgGLAuthoritativeMode = true;
$wgGroupPermissions['*']['autocreateaccount'] = true;
$wgShowExceptionDetails= true;

EOT

echo "customize.sh -- Debugging Rules"
cat <<'EOT' >> /bitnami/mediawiki/LocalSettings.php

////////////////////////////////////////////////////////////////////////////////
// Debugging Rules

//$wgShowExceptionDetails = true;
//$wgDebugToolbar = true;
//$wgShowDebug = true;
//$wgDevelopmentWarnings = true;
//error_reporting( -1 );
//ini_set( 'display_errors', 1);
//error_reporting(E_ALL);

// $wgSessionCacheType = CACHE_DB;

EOT


echo "customize.sh -- Running post-startup command(s)"
cd /opt/bitnami/mediawiki/maintenance && php update.php


cat << EOF
customize.sh -- Finished.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
POST RUN MANUAL STEPS
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
You must do the following to correctly install Mediawiki:
- configure the Google Login extension by modifying the following lines:
    \$wgGLSecret = 'xxxxx';
    \$wgGLAppId = 'xxxxxx';
    \$wgGLAllowedDomains = array('example.com', 'example2.com');

- then run the following script:
    cd extensions/GoogleLogin/maintenance && php updatePublicSuffixArray.php

EOF
