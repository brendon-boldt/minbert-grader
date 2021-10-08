# MinBERT Grader

Run the grader by executing `run.sh` as root (or with `sudo`) with the ZIP files from Canvas as the arguments (e.g,, `sudo ./run.sh submissions/*.zip`).
Note that this requires Docker to be installed with support for Nvidia GPUs (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).

## File Structure

The following gives a quick summary of the file structure of this project.
- `run.sh` - the main script
- `minbert.dockerfile` - the Dockerfile for the base `minbert` image; student submission images will be derived from this image
- `submission.dockerfile` - the Dockerfile for the student submission which copies the files from extracted ZIP file and runs the grader script
- `grader-files/` - scripts and data which is used for evaluating the submissions
    - `grader.sh` - the script responsible for running the commands used for grading
- `setup.sh` - a script for setting up the Python environment inside the Docker container
- `work/` - the working/output directory created by `run.sh`
    - `andrewid.out` - captured stdout and stderr for the script grading the submission
    - `andrewid.results.txt` - the recorded results from each of the tests (e.g., sanity check, accuracy); note that for `sanity_check` and `optimizer_test` `0` corresponds to success (like shell command)


## License

The following files are copied from [neubig/minbert-assignment](https://github.com/neubig/minbert-assignment); please see that repository for the licensing of that code.
- `data/`
- `optimizer_test.npy`
- `optimizer_test.py`
- `sanity_check.data`
- `sanity_check.py`
- `setup.sh`
- `utils.py`
