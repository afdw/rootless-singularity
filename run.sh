#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if command -v module &> /dev/null; then
    module load singularity
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

export SINGULARITYENV_PATH=$PATH

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
    --bind /etc/passwd:/etc/passwd:ro \
    --bind /etc/group:/etc/group:ro \
    --bind /etc/resolv.conf:/etc/resolv.conf:ro \
    $SCRATCH_BIND \
    $NV \
    $SCRIPT_DIR/rootless.sif \
    "$@"
