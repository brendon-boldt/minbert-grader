#!/bin/bash

if [ $(whoami) != root ]; then
    echo Script must be run as root
    exit 1
fi

zips=$@

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
        --build-arg miniconda_installer=grader-files/Miniconda3-latest-Linux-x86_64.sh \
        -t $image_name \
        -f Dockerfile \
        .
    docker run --name $image_name $image_name
    docker cp $image_name:/app/submission/results.txt work/$name.results.txt
    docker rm $image_name
    chmod -R a+rwX work/$name
}

mkdir -p work
chmod -R a+rwX work

for zip in $zips; do
    name=$(basename ${zip%.*})
    run_submission $name $(readlink -f $zip) | tee work/$name.out
done
