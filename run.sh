#!/bin/bash

set -e

get_gpu_file() {
    echo gpu_$1.lock
}

get_avail_gpu() {
    for i in $(seq 0 $(( $num_gpus - 1 ))); do
        if [[ ! -e $(get_gpu_file $i) ]]; then
            touch $(get_gpu_file $i)
            echo $i
            break
        fi
    done
}

run_submission() {
    local name=$1
    local zip=$2
    local gpu=$3
    rm -rf work/$name
    mkdir work/$name
    # The students submission should already be in a directory, but in case
    # they did it wrong, minimize the damage.
    unzip -q $zip -d work/$name
    local image_name=minbert_$name
    docker build \
        --build-arg target=work/$name/$name \
        -t $image_name \
        -f submission.dockerfile \
        .
    docker run \
        --cpus 4.0 \
        --gpus device=$gpu \
        --memory=16g \
        --name $image_name \
        $image_name
    docker cp $image_name:/app/submission/results.txt work/$name.results.txt
    docker rm $image_name
}

run_submission_wrapper() {
    echo Running $1...
    run_submission $@ &> work/$1.out
    chmod -R a+rwX work
    echo Finished $1.
}

zips=$@
miniconda_installer=Miniconda3-latest-Linux-x86_64.sh
miniconda_installer_url=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

if [ $(whoami) != root ]; then
    echo Script must be run as root
    exit 1
fi

num_gpus=$(nvidia-smi --format=csv,noheader --query-gpu=uuid | wc -l)

if [ ! -e $miniconda_installer ]; then
    wget $miniconda_installer_url
fi

docker build \
    --build-arg miniconda_installer=$miniconda_installer \
    -t minbert \
    -f minbert.dockerfile \
    .

mkdir -p work

for zip in $zips; do
    gpu=$(get_avail_gpu)
    while [[ -z $gpu ]]; do
        sleep 5
        gpu=$(get_avail_gpu)
    done
    name=$(basename $zip)
    name=${name%.*}
    name=${name%-*}
    name=${name##*_}
    run_submission_wrapper $name $(readlink -f $zip) $gpu &
    rm $(get_gpu_file $gpu)
done

wait

rm -f gpu_*.lock
