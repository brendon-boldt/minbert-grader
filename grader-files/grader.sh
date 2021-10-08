#!/bin/bash

source activate bert_hw

rm -f results.txt

timeout 60 python -m optimizer_test
optimizer_test_result=$?
echo optimizer_test,$optimizer_test_result >> results.txt

timeout 60 python -m sanity_check
sanity_check_result=$?
echo sanity_check,$sanity_check_result >> results.txt

mkdir output

timeout 3600 python classifier.py \
    --epochs 1 \
    --use_gpu \
    --option pretrain \
    --lr 1e-3 \
    --train data/sst-train.txt \
    --dev data/sst-dev.txt \
    --test data/sst-test.txt \
    --dev_out output/sst-dev.txt \
    --test_out output/sst-test.txt \
    --seed 28392

compute_accuracy() {
    <$1 awk -F' \|\|\| ' '{sum+= $2==$3}; END {print sum/NR}'
}

echo sst-dev-acc,$(compute_accuracy output/sst-dev.txt) >> results.txt
echo sst-test-acc,$(compute_accuracy output/sst-test.txt) >> results.txt
