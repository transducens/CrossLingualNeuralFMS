This package contains the results of the human evaluation described in Section 5 of the paper corresponding to submission number 2479 of the EMNLP 2022 conference. There are six folders, each of them corresponding to the evaluation carried out by a professional translator. Inside each folder, there is a file "results.EMNLP.tsv" with tab-separated format. These files contain five fields:
 1. Source sentence in English
 2. Translation proposal number 1 (either from neuroMatch or from FMS)
 3. Name of the system that produced the proposal number 1 (either neuroMatch or FMS) and the assessment provided by the translator, separated by ":"
 4. Translation proposal number 2 (either from neuroMatch or from FMS)
 5. Name of the system that produced the proposal number 2 (either neuroMatch or FMS) and the assessment provided by the translator, separated
 by ":"
The assessment provided by translators can take 3 values: useless, 1 or 2. Value 1 means that the translation proposal is useful and the best option for the source segment provided. Value 2 also means that the translation proposal is useful, but the translator considered that there is an alternative translation that is better. 
