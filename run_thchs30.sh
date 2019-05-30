#!/bin/bash

. ./cmd.sh
. ./path.sh

resource_url=http://www.openslr.org/resources/18
download_dst=/export/a05/xna/data/thchs30

# step -1: prepare resources
cd local
rm score.sh
ln -s ../steps/scoring/score_kaldi_cer.sh ./score.sh
cd ..
rm -f exp/chain/tdnn/phones.txt
rm -f exp/chain/tdnn/graph/phones.txt
rm -rf exp/chain/tdnn/graph/phones
cp data/lang_chain/phones.txt exp/chain/tdnn/
cp data/lang_chain/phones.txt exp/chain/tdnn/graph/
cp -R data/lang_chain/phones exp/chain/tdnn/graph/

# step 0: download and format test set
local/thchs30_download_and_untar.sh $download_dst $resource_url data_thchs30
local/thchs30_test_prep.sh . $download_dst/data_thchs30

# step 1: generate fbank features
obj_dir=data/thchs30

for x in test; do
  # rm fbank/$x
  mkdir -p fbank/$x
  # compute fbank without pitch
  steps/make_fbank.sh --nj 1 --cmd "run.pl" $obj_dir/$x exp/make_fbank/$x fbank/$x || exit 1;
  # compute cmvn
  steps/compute_cmvn_stats.sh $obj_dir/$x exp/fbank_cmvn/$x fbank/$x || exit 1;
done

# #step 2: offline-decoding
test_data=data/thchs30/test
dir=exp/chain/tdnn

steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
  --nj 5 --num-threads 1 \
  --cmd "$decode_cmd" --iter final \
  --frames-per-chunk 50 \
  $dir/graph $test_data $dir/decode_thchs30_test

grep WER exp/chain/tdnn/decode_thchs30_test/cer* | utils/best_wer.sh

# # note: the model is trained using "apply-cmvn-online",
# # so you can modify the corresponding code in steps/nnet3/decode.sh to obtain the best performance,
# # but if you directly steps/nnet3/decode.sh,
# # the performance is also good, but a little poor than the "apply-cmvn-online" method.
