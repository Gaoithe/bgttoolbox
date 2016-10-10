#!/bin/bash

grep=$1
cmd=$2
#docker_running=$(docker ps --format '{{.Names}} {{.ID}} {{.Status}} created {{.CreatedAt}} im {{.Image}}' |grep ${grep})
docker_ps=$(docker ps -a --format '{{.Names}} {{.Status}} im {{.Image}}' |sort -n |grep "${grep}")
#CONTS=$(docker ps --format '{{.Names}} {{.Image}}' |grep nfv10 |cut -d" " -f1); echo $CONTS

if [[ -z $docker_ps || -z $cmd ]] ; then
    usage="Usage: $0 <grep> <cmd>
e.g.:  $0 nfv10 \"ls -alstr \\\"*core*\\\"\"
"
    echo "$usage"
    exit -1
fi

ids=$(echo "$docker_ps" |awk '{print $1}')
statuses=$(echo "$docker_ps" |awk '{print $2}')

echo ids=$ids
echo statuses=$statuses

for id in $ids; do
    #docker exec -it oasis-nfv10 bash
    #docker exec -i $id sh -c "$cmd"
    echo docker exec -i $id sh -c "su - omn -s /bin/bash -c \"$cmd\""
    docker exec -i $id sh -c "su - omn -s /bin/bash -c \"$cmd\""
done
