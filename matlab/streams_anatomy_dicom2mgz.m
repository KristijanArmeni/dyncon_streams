function streams_anatomy_dicom2mgz(subject)
%streams_anatomy_dicom2mgz takes the the subject info data structure (or subject string as 'sXX') 
%   
%   Picks up the dicom files, reslices the image and creates a .mgz file (spm coordsyst)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

subject_code = subject.name;
anatomy_savedir = fullfile('~/pro/streams/data/MRI/preproc'); %just for test, should be: '/home/language/jansch/projects/streams/data/anatomy'

%if subject-specific folder does not exist, make one
if ~isdir(anatomy_savedir)
  mkdir('~/pro/streams/data/MRI/preproc');
end

% select the last dicom file in subject's mri directory
dicom_dir  = fullfile(subject.mridir, subject.id);
dicom_list = dir(dicom_dir);
dicom_file = fullfile(dicom_dir, dicom_list(end).name);

% read in the dicom files
mri   = ft_read_mri(dicom_file);

% filename for saving
mgz_filename = fullfile(anatomy_savedir, [subject_code, '_mri' '.mgz']); % sXX_mri_resliced.mgz

% save the images in the mgz format
cfg             = [];
cfg.filename    = mgz_filename;
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);

end

