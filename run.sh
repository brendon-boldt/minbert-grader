#!/bin/bash

zips=$@
miniconda_installer=Miniconda3-latest-Linux-x86_64.sh
miniconda_installer_url=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

max_concurrent=4

if [ $(whoami) != root ]; then
    echo Script must be run as root
    exit 1
fi

run_submission() {
    local name=$1
    local zip=$2
    rm -rf work/$name
    mkdir work/$name
    # The students submission should already be in a directory, but in case
    # they did it wrong, minimize the damage.
    unzip -q $zip -d work/$name
    local image_name=minbert_$name
    docker build \
        --build-arg target=work/$name/$name \
        --build-arg miniconda_installer=$miniconda_installer \
        -t $image_name \
        -f Dockerfile \
        .
    docker run --cpus 4.0 --memory=1g --name $image_name $image_name
    docker cp $image_name:/app/submission/results.txt work/$name.results.txt
    docker rm $image_name
}

if [ ! -e $miniconda_installer ]; then
    wget $miniconda_installer_url
fi

run_submission_wrapper() {
    echo Running $1...
    run_submission $@ &> work/$1.out
    chmod -R a+rwX work
    echo Finished $1.
}

mkdir -p work

for zip in $zips; do
    while [ $(jobs | wc -l) -ge $max_concurrent ]; do
        sleep 2
    done
    name=$(basename ${zip%.*})
    run_submission_wrapper $name $(readlink -f $zip) &
done

wait
