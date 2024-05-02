#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if command -v module &> /dev/null; then
    module load singularity
fi

if [[ $1 = "--no-import" ]]; then
    shift
else
    LEAD='### BEGIN IMPORTED CONTENTS'
    TAIL='### END IMPORTED CONTENTS'
    for FILE in passwd group resolv.conf; do
        [ "$(sed -n "1{/^$LEAD/p};q" $SCRIPT_DIR/root.x86_64/etc/$FILE)" ] || sed -i "1s/^/$LEAD\n$TAIL\n/" $SCRIPT_DIR/root.x86_64/etc/$FILE
        cat /etc/$FILE > $SCRIPT_DIR/root.x86_64/etc/$FILE-overlay
        sed -ie "/^$LEAD$/,/^$TAIL$/{ /^$LEAD$/{p; r $SCRIPT_DIR/root.x86_64/etc/$FILE-overlay
                }; /^$TAIL$/p; d }" $SCRIPT_DIR/root.x86_64/etc/$FILE
    done
fi

if [ -S /var/lib/sss/pipes/nss ]; then
    SSS_BIND="--bind /var/lib/sss/pipes/nss:/var/lib/sss/pipes/nss"
else
    SSS_BIND=""
fi

if [ -d /scratch ]; then
    SCRATCH_BIND="--bind /scratch:/scratch:rw"
else
    SCRATCH_BIND=""
fi

if [[ $1 = "--nv" ]]; then
    shift
    NV="--nv"
else
    NV=""
fi

if [ $# -eq 0 ]; then
    set -- /usr/bin/bash -i
    echo "Entering singularity"
fi

export SINGULARITYENV_PATH="/usr/local/bin:$PATH"
export SINGULARITYENV_PS1="$PS1"

exec singularity run \
    --bind $SCRIPT_DIR/root.x86_64/usr/bin:/bin:rw \
    --bind $SCRIPT_DIR/root.x86_64/boot:/boot:rw \
    --bind $SCRIPT_DIR/root.x86_64/etc:/etc:rw \
    --bind $SCRIPT_DIR/root.x86_64/usr/lib:/lib:rw \
    --bind $SCRIPT_DIR/root.x86_64/usr/lib:/lib64:rw \
    --bind $SCRIPT_DIR/root.x86_64/mnt:/mnt:rw \
    --bind $SCRIPT_DIR/root.x86_64/opt:/opt:rw \
    --bind $SCRIPT_DIR/root.x86_64/root:/root:rw \
    --bind $SCRIPT_DIR/root.x86_64/usr/bin:/sbin:rw \
    --bind $SCRIPT_DIR/root.x86_64/run:/run:rw \
    --bind $SCRIPT_DIR/root.x86_64/srv:/srv:rw \
    --bind $SCRIPT_DIR/root.x86_64/usr:/usr:rw \
    --bind $SCRIPT_DIR/root.x86_64/var:/var:rw \
    $SSS_BIND \
    $SCRATCH_BIND \
    $NV \
    $SCRIPT_DIR/rootless.sif \
    "$@"
