#!/bin/bash

#<hb>***************************************************************************
#
# copy a file into docker volume
#
# USAGE: copy_to_volume.sh <file_name> <volume_name>
#
# Example: copy_to_volume.sh hello_world.txt super_volume
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
[[ -z $DEST ]]   && DEST=""

[[ ! -f $FL ]]   && echo "ERROR: file '$FL' not found" && exit

docker volume inspect $VOLUME >/dev/null 2>&1
err=$?

[[ $err -ne 0 ]] && echo "ERROR: volume '$VOLUME' not found" && exit $err

[[ -n $DEST ]] && suffix=" to '$DEST'"

echo "INFO: copy file '$FL' to volume '$VOLUME'${suffix}"

tar -czf - $FL | docker run --rm -i -v $VOLUME:/to alpine ash -c "cd /to ; tar -xzpf -; [[ -n $DEST ]] && mv $FL $DEST"
err=$?

[[ $err -ne 0 ]] && echo "ERROR: $err - failed to copy file '$FL' to volume '$VOLUME'" && exit $err

echo "INFO: copy file '$FL' to volume '$VOLUME'${suffix} - done"
