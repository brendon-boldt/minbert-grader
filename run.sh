#!/bin/bash

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
    rm $(get_gpu_file $gpu)
    rm -rf work/$name-results/
    mkdir work/$name-results/
    docker cp $image_name:/app/submission/results.txt work/$name-results/
    docker cp $image_name:/app/submission/output/. work/$name-results/output
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


nvidia-smi &> /dev/null
if [[ $? -ne 0 ]]; then
    echo 'No GPUs available; running CPU-only.'
    num_gpus=0
else
    num_gpus=$(nvidia-smi --format=csv,noheader --query-gpu=uuid | wc -l)
fi

if [ ! -e $miniconda_installer ]; then
    wget $miniconda_installer_url
fi

docker build \
    --build-arg miniconda_installer=$miniconda_installer \
    -t minbert \
    -f minbert.dockerfile \
    .

mkdir -p work

i=0
total_zips=$( echo $zips | tr ' ' '\n' | wc -l)
for zip in $zips; do
    i=$(( ++i ))
    name=$(basename $zip)
    name=${name%.*}
    name=${name%%-*}
    name=${name##*_}

    if [[ -e work/$name.results.txt ]]; then
        echo Found results file for $name, skipping.
        continue
    fi

    gpu=$(get_avail_gpu)
    while [[ $num_gpus -gt 0 ]] && [[ -z $gpu ]]; do
        sleep 1
        gpu=$(get_avail_gpu)
    done
    echo -n "$i/$total_zips "
    run_submission_wrapper $name $(readlink -f $zip) $gpu &
done

wait

rm -f gpu_*.lock
