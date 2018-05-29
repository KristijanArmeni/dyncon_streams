## Documentation
---
This is a brief documentation/overview of the currently used [analysis pipeline][analysis pipeline] for the Streams project. These are customly written [MATLAB][matlab] scripts and functions which rely on heavily the [Fieldtrip toolbox][Fieldtrip] subroutines and functionality. Please see the Fieldtrip [reference documentation][Fieldtrip documentation] for details where appropriate.

### Preprocessing
---
#### MEG
* [`streams_subjinfo.m`](matlab/streams_subjinfo.m)
  * [`streams_artifact_definetrial.m`](matlab/streams_artifact_definetrial.m)
  * [`streams_artifact_squidjumps.m`](matlab/streams_artifact_squidjumps.m)
* [`streams_preprocessing.m`](matlab/streams_preprocessing.m)
* [`streams_componentanalysis_fastica.m`](matlab/streams_componentanalysis_fastica.m)
* [`streams_rejectcomponent_fastica.m`](matlab/streams_rejectcomponent_fastica.m)
* [`streams_cleanadhoc.m`](matlab/streams_rejectcomponent_fastica.m)

#### Audio preprocessing

* [`streams_preprocessing.m`](matlab/streams_preprocessing.m)
  * [`streams_wav2mat.m`](matlab/streams_wav2mat.m)

#### Language model preprocessing

##### Language model predictors
* [`streams_preprocessing.m`](matlab/streams_preprocessing.m)
    * [`combine_donders_textgrid.m`](matlab/combine_donders_textgrid.m)
    * [`streams_addsubtlex.m`](matlab/streams_addsubtlex.m)
    * [`create_featuredata.m`](matlab/create_featuredata.m)
      * [`get_time_series.m`](matlab/get_time_series.m)

##### Binning and contrast definition
* [`streams_epochdefinecontrast.m`](language/streams_epochdefinecontrast.m)
  * [`streams_cleanadhoc.m`](matlab/streams_cleanadhoc.m)

##### Subtlex data

* [`language_combineddata2csv.m`](language/language_combineddata2csv.m)
* [`language_data.m`](language/language_data.m)
* [`language_subtlexcsv2mat.m`](language/language_subtlexcsv2mat.m)

### Sensor-level analyses
---
#### MEG frequency analysis & stats

* [`streams_freqanalysis_contrast.m`](matlab/streams_freqanalysis_contrast.m)
* [`streams_freqanalysis_groupcontrast.m`](matlab/streams_freqanalysis_groupcontrast.m)
* [`streams_freqanalysis_groupcontrast_permute.m`](matlab/streams_freqanalysis_groupcontrast_permute.m)

#### MEG speech-brain coherence analysis & stats

* [`streams_coherence_contrast.m`](matlab/streams_coherence_contrast.m)
* [`streams_coherence_groupcontrast.m`](matlab/streams_coherence_groupcontrast.m)

### MEG source reconstruction
---
#### MRI preprocessing

Dependencies: [Freesurfer][Freesurfer], [FSL][FSL], [Workbench][Workbench]

* [`streams_anatomy_dicom2mgz.m`](matlab/streams_anatomy_dicom2mgz.m)
* [`streams_anatomy_mgz2ctf.m`](matlab/streams_anatomy_mgz2ctf.m)
* [`streams_anatomy_mgz2mni.m`](matlab/streams_anatomy_mgz2mni.m)
* [`streams_anatomy_skullstrip.m`](matlab/streams_anatomy_skullstrip.m)
* [`streams_anatomy_freesurfer.sh`](matlab/streams_anatomy_freesurfer.sh)
* [`streams_anatomy_volumetricQC.m`](matlab/streams_anatomy_volumetricQC.m)
* [`streams_anatomy_wmclean.m`](matlab/streams_anatomy_wmclean.m)
* [`streams_anatomy_freesurfer2.sh`](matlab/streams_anatomy_freesurfer2.sh)
* [`streams_anatomy_workbench.m`](matlab/streams_anatomy_workbench.m)
  * [`streams_anatomy_postfreesurferscript.sh`](matlab/streams_anatomy_postfreesurferscript.m)
* [`streams_anatomy_sourcemodel2d.m`](matlab/streams_anatomy_sourcemodel2d.m)
* [`streams_anatomy_headmodel.m`](matlab/streams_anatomy_headmodel.m)
* [`streams_anatomy_coregistration_qc.m`](matlab/streams_anatomy_coregistration_qc.m)
* [`streams_anatomy_leadfield.m`](matlab/streams_anatomy_leadfield.m)

#### DICS & statistics
---
* [`streams_dics.m`](matlab/streams_dics.m)
  * [`streams_dics_groupcontrast.m`](matlab/streams_dics_groupcontrast.m)

### Utilities
---
* [`streams_util_subjectstring.m`](matlab/streams_util_subjectstring.m)
* [`streams_util_stories.m`](matlab/streams_util_stories.m)

Last updated by: Kristijan on 05/29/2018

[matlab]:https://nl.mathworks.com/products/matlab.html
[analysis pipeline]:https://github.com/KristijanArmeni/dyncon_streams
[Freesurfer]: https://surfer.nmr.mgh.harvard.edu/
[FSL]: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
[Workbench]: http://www.humanconnectome.org/software/connectome-workbench
[Fieldtrip]: http://www.fieldtriptoolbox.org/
[Fieldtrip documentation]: http://www.fieldtriptoolbox.org/reference
