#!/bin/sh

if ! [ -e index.php -a -e mw-config/index.php ]; then
	echo >&2 "MediaWiki not found in $(pwd) - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	tar cf - --one-file-system -C /usr/src/mediawiki . | tar xf -
	echo >&2 "Complete; MediaWiki has been successfully copied to $(pwd)"
fi

exec "$@"