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

RUN conda run -n bert_hw python -m download_bert

