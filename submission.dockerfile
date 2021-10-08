FROM minbert

ARG target

ADD \
    $target/bert.py \
    $target/base_bert.py \
    $target/optimizer.py \
    $target/classifier.py \
    $target/sst-dev-output.txt \
    $target/sst-test-output.txt \
    $target/cfimdb-dev-output.txt \
    $target/cfimdb-test-output.txt \
    $target/config.py \
    $target/tokenizer.py \
    $target/utils.py \
    ./

CMD bash grader.sh
