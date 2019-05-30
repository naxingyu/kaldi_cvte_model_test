## Intro
This repo allows you to
1. reproduce the THCHS30 result mentioned in [CVTE model package](http://kaldi-asr.org/models/m2)

## Preparations
1. Install Kaldi
2. Download and untar [CVTE model package](http://kaldi-asr.org/models/m2)
3. Clone this repo, and copy the files to CVTE/s5

## Results
%WER 8.10 [ 6569 / 81139, 146 ins, 327 del, 6096 sub ] exp/chain/tdnn/decode_thchs30_test/cer_8_0.5

## N.B.
The test set is contained in the whole THCHS30 data package, so downloading might take tens of minutes.