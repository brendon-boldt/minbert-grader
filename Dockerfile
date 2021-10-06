FROM debian:bullseye-slim

ARG miniconda_installer

WORKDIR /app

COPY $miniconda_installer mc-installer.sh
RUN bash mc-installer.sh -b -p /app/miniconda
RUN rm mc-installer.sh

ENV PATH $PATH:/app/miniconda/bin

ADD setup.sh ./
RUN bash setup.sh
RUN rm setup.sh

WORKDIR /app/submission
ADD grader-files ./

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
