#!/bin/bash

#<hb>***************************************************************************
#
# backup docker volume into archive
#
# USAGE: copy_to_volume.sh <volume_name> <archive_name.tar.gz>
#
# Example: copy_to_volume.sh super_volume backup.tar.gz
#
#<he>***************************************************************************

show_help()
{
    sed -e '1,/^#<hb>/d' -e '/^#<he>/,$d' $0 | cut -c 3-
}

FL=$1
VOLUME=$2
DEST=$3

[[ -z $FL ]]     && echo "ERROR: filename is not given" && show_help && exit
[[ -z $VOLUME ]] && echo "ERROR: volume name is not given" && show_help && exit
[[ -z $DEST ]]   && DEST="/"

[[ ! -f $FL ]]   && echo "ERROR: file '$FL' not found" && exit

docker volume inspect $VOLUME >/dev/null 2>&1
err=$?

[[ $err -ne 0 ]] && echo "ERROR: volume '$VOLUME' not found" && exit $err

echo "INFO: copy file '$FL' to volume '$VOLUME'"

tar -czf - $FL | docker run --rm -i -v $VOLUME:/to alpine ash -c "cd /to ; tar -xzpf -"
#docker run --rm -v $VOLUME:/from alpine ash -c "cd /from ; tar -czf - . " > $FL
err=$?

[[ $err -ne 0 ]] && echo "ERROR: $err - failed to copy file '$FL' to volume '$VOLUME'" && exit $err

echo "INFO: copy file '$FL' to volume '$VOLUME' - done"
