function streams_anatomy_dicom2mgz(subject)
%streams_anatomy_dicom2mgz takes the the subject info data structure (or subject string as 'sXX') 
%   
%   Picks up the dicom files, reslices the image and creates a .mgz file (spm coordsyst)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

subject_code = subject.name;
subject_number = str2num(subject.name(2:end));
anatomy_savedir = fullfile('~/pro/streams/data/MRI/preproc'); %just for test, should be: '/home/language/jansch/projects/streams/data/anatomy'

% select the last dicom file in subject's mri directory
if subject_number <= 10 % pilot data have different directory structure
  dicom_dir  = fullfile(subject.mridir, subject.id, 'dicom');
else 
  dicom_dir  = fullfile(subject.mridir, subject.id);
end

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

