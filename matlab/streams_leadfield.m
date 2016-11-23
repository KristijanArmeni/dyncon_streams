function streams_leadfield(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% create the subject structure
if ischar(subject)
  subject = streams_subjinfo(subject);
end

% directories 
subject_code                 = subject.name;
anatomy_dir                  = fullfile('~/pro/streams/data/MRI/preproc'); %just for test, should be: '/home/language/jansch/projects/streams/data/anatomy'
freesurfer_dir               = fullfile(anatomy_dir, subject_code); % points to the directory with parcellation and labels
atlas_dir                    = fullfile('~/pro/streams/data/MRI/atlas/374');

% filenames
headmodel_filename           = fullfile(anatomy_dir, [subject_code, '_headmodel.mat']);
sourcemodel_filename         = fullfile(anatomy_dir, [subject_code, '_sourcemodel.mat']);
leadfield_filename           = fullfile(anatomy_dir, [subject_code, '_leadfield.mat']);
parcellation                 = fullfile(atlas_dir, 'atlas_subparc374_8k.mat');
leadfield_parcellated        = fullfile(anatomy_dir, [subject_code, '_leadfield_parc.mat']);

% load the necessary files
load(sourcemodel_filename)
load(headmodel_filename)
load(parcellation);  % load in the atlas
load('~/pro/streams/data/MEG/preproc/s02_fn1001078_04-08_entr_300hz.mat');

%% Full leadfield

% compute leadfield
cfg = [];
cfg.headmodel = headmodel;
cfg.pos = sourcemodel.pos;
cfg.inside = sourcemodel.inside;
leadfield = ft_prepare_leadfield(cfg, data);

save(leadfield_filename, 'leadfield');

%% Parcellated leadfield

leadfield_parc = streams_parcellate_leadfield(leadfield, atlas);
save(leadfield_parcellated, 'leadfield_parc');


end

