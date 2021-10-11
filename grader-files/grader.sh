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

compute_accuracy() {
    <$1 awk -F' \|\|\| ' '{sum+= $2==$3}; END {print sum/NR}'
}

# Check accuracy of pre-computed outputs
echo best-sst-dev-acc,$(compute_accuracy sst-dev-output.txt) >> results.txt
echo best-sst-test-acc,$(compute_accuracy sst-test-output.txt) >> results.txt
echo best-cfimdb-dev-acc,$(compute_accuracy cfimdb-dev-output.txt) >> results.txt
echo best-cfimdb-test-acc,$(compute_accuracy cfimdb-test-output.txt) >> results.txt

run_model() {
    local dataset=$1
    local pretrain_or_finetune=$2
    local dev_out_fn=output/$dataset-$pretrain_or_finetune-dev.txt
    local test_out_fn=output/$dataset-$pretrain_or_finetune-test.txt
    timeout 3600 python classifier.py \
        --epochs 1 \
        --use_gpu \
        --option $pretrain_or_finetune \
        --lr 1e-3 \
        --train data/$dataset-train.txt \
        --dev data/$dataset-dev.txt \
        --test data/$dataset-test.txt \
        --dev_out $dev_out_fn \
        --test_out $test_out_fn \
        --seed 28392
    echo $dataset-$pretrain_or_finetune-dev-acc,$(compute_accuracy $dev_out_fn) \
        >> results.txt
    echo $dataset-$pretrain_or_finetune-test-acc,$(compute_accuracy $test_out_fn) \
        >> results.txt
}

run_model sst pretrain
run_model sst finetune
run_model cfimdb finetune
