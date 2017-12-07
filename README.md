### ABOUT

This repository hosts the code that was used for analysis pipeline in the project _MEG spectral correlates of lexical perplexity and entropy during auditory story comprehension_ ('streams' for short).

### Directory structure

* [matlab](matlab) (meg analysis pipeline)
  * [external](matlab/external) (external code)
* [language](language) (for processing language stimuli used in the experiment)
* [ploting](ploting) (code for ploting the results)
* [old](old) (code no longer used, obsolete or replaced)

### Toolboxes used

The pipeline relies on the following matlab toolboxes and software:

* [Fieldtrip][Fieldtrip] (for MEG data analysis)
* [Freesurfer][Freesurfer] (for cortical sheet reconstruction in source analysis)
* [FSL][FSL] (part of MRI image preprocessing in cortical sheet reconstruction)
* [Workbench][Workbench] (for a part of MRI preprocessing in cortical sheet reconstruction)

### Data availability

Data used in the project are available through [Donders repository](http://donders.data.ru.nl). See [here]('http://www.ru.nl/donders/research/data/user-manual/access-shared-data/request-access/') for instructions on how to request access to the shared data.

### Licence

[Fieldtrip]: http://fieldtriptoolbox.org
[Freesurfer]: https://surfer.nmr.mgh.harvard.edu
[FSL]: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
[Workbench]: http://www.humanconnectome.org/software/connectome-workbench
