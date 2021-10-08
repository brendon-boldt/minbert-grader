import utils

archive_file = utils.hf_bucket_url('bert-base-uncased', filename=utils.WEIGHTS_NAME)
utils.cached_path(archive_file)
