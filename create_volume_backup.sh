#!/bin/bash

#<hb>***************************************************************************
#
# backup docker volume into archive
#
# USAGE: create_volume_backup.sh <volume_name> [<archive_name.tar.gz>]
#
# Example: create_volume_backup.sh super_volume backup.tar.gz
#
#<he>***************************************************************************

show_help()
{
    sed -e '1,/^#<hb>/d' -e '/^#<he>/,$d' $0 | cut -c 3-
}

VOLUME=$1
FL=$2

[[ -z $VOLUME ]] && echo "ERROR: volume name is not given" && show_help && exit
[[ -z $FL ]]     && FL="${VOLUME}.tar.gz"

docker volume inspect $VOLUME >/dev/null 2>&1
err=$?

[[ $err -ne 0 ]] && echo "ERROR: volume '$VOLUME' not found" && exit $err

echo "INFO: backup volume '$VOLUME' to $FL"

docker run --rm -v $VOLUME:/from alpine ash -c "cd /from ; tar -czf - . " > $FL
err=$?

[[ $err -ne 0 ]] && echo "ERROR: $err - failed to back up volume '$VOLUME'" && exit $err

echo "INFO: backup volume '$VOLUME' to $FL - done"
