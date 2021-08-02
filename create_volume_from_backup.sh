#!/bin/bash

#<hb>***************************************************************************
#
# create docker volume from archive
#
# USAGE: create_volume_from_backup.sh <archive_name.tar.gz> [<volume_name> [-V]]
#
# Example: create_volume_from_backup.sh backup.tar.gz super_volume
#
#<he>***************************************************************************

show_help()
{
    sed -e '1,/^#<hb>/d' -e '/^#<he>/,$d' $0 | cut -c 3-
}

FL=$1
VOLUME=$2
IS_VERBOSE=$3

[[ -z $FL ]]     && echo "ERROR: filename is not given" && show_help && exit
[[ -z $VOLUME ]] && VOLUME=$( basename $FL  | sed "s/\.tar\.gz$//" )

[[ ! -f $FL ]]   && echo "ERROR: file '$FL' does not exist" && show_help && exit

docker volume inspect $VOLUME >/dev/null 2>&1
err=$?

[[ $err -eq 0 ]] && echo "ERROR: volume '$VOLUME' already exists" && exit $err

echo "INFO: create volume '$VOLUME' from $FL"

v_flag=""

[[ -n $IS_VERBOSE ]] && v_flag="v"

cat $FL | docker run --rm -i -v $VOLUME:/to alpine ash -c "cd /to ; tar -xzp${v_flag}f - "
err=$?

[[ $err -ne 0 ]] && echo "ERROR: $err - failed to create volume '$VOLUME'" && exit $err

echo "INFO: create volume '$VOLUME' from $FL - done"
