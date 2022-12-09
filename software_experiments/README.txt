This package contains the software used to run the experiments reported in the paper number 2479 submitted to the EMNLP 2022 conference. This package contains several folders with libraries and scripts. In order to reproduce the results reported in the paper, one can install all the dependencies included in requirements.yaml by running:

    pip install -r requirements.yaml

Then, access the folder "experiments" and execute the script "run_experiments.sh". It will automatically download any required data (that is available); it is worth noting that two manual steps are required in order to run the experiments:
 - downloading the EurLex corpus from https://www.sketchengine.eu/eurlex-corpus: this corpus is provided under a Creative Commons license by Sketch Engine, but, in order to download it, it is necessary to request access to the data; and
 - training a COMET model to estimate FMS (neuroFMS). In a different supplementary material for this paper, one can find the training data and config file required to do so.

Note that many scripts are designed to run on SLURM. It is also worth noting that running these experiments can be time consuming, even when GPUs are available. In our case, with 8 GPUs, it took about ten days. The slowest step in this process is obtaining the best candidates by using FMS, which took about a week when using 96 CPUs.
