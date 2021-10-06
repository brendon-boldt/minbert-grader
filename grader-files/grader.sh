#!/bin/bash

source activate bert_hw

rm -f results.txt

timeout 60 python -m optimizer_test
optimizer_test_result=$?
echo optimizer_test,$optimizer_test_result >> results.txt

timeout 60 python -m sanity_check
sanity_check_result=$?
echo sanity_check,$sanity_check_result >> results.txt
