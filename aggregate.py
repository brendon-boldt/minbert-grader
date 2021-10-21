#!/bin/python3

import sys
from pathlib import Path

OUT_FN = "all_results.csv"

FIELDS = [
    "optimizer_test",
    "sanity_check",
    "best-sst-dev-acc",
    "best-sst-test-acc",
    "best-cfimdb-dev-acc",
    "best-cfimdb-test-acc",
    "sst-pretrain-dev-acc",
    "sst-pretrain-test-acc",
]


def process_file(p: Path) -> str:
    name = p.name.split(".")[0]

    with p.open() as fo:
        kvs = dict(l.split(",") for l in fo.read().split("\n") if l)
    fields = ",".join(kvs.get(f, "") for f in FIELDS)
    return name + "," + fields + "\n"


def main():
    if len(sys.argv) < 2:
        print("Please provide the work directory as the first argument.")
        sys.exit(1)

    workdir = Path(sys.argv[1])
    with open("all_results.csv", "w") as fo:
        fo.write("name,")
        fo.write(",".join(FIELDS))
        fo.write("\n")
        for p in workdir.glob("*.results.txt"):
            fo.write(process_file(p))


main()
