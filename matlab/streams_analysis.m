%% get subject info
subject = streams_subjinfo(subjectid);

%% compute the necessary anatomical objects
if 0%do_anatomy
  [mri, sourcemodel, headmodel, shape, shapemri] = streams_anatomy(subject);
  pathname = fullfile(subject.mridir, subject.id);
  
  save(fullfile(pathname, [subject.name, '_shape']),          'shape');
  save(fullfile(pathname, [subject.name, '_shapemri']),       'shapemri');
  save(fullfile(pathname, [subject.name, '_sourcemodel8mm']), 'sourcemodel');
  save(fullfile(pathname, [subject.name, '_headmodel']),      'headmodel');
  
  cfg           = [];
  cfg.filename  = fullfile(pathname, [subject.name, '_mri.nii']);
  cfg.filetype  = 'nifti';
  cfg.parameter = 'anatomy';
  ft_volumewrite(cfg, mri);
end

%% compute cortico-audio coherence
if 0%do_cac
  [coh, trials] = streams_corticoaudiocoherence(subject);
  pathname = '/home/language/jansch/projects/streams/data';
  save(fullfile(pathname, [subject.name, '_corticoaudiocoherence']), 'coh', 'trials');
end

%% compute cortico_audio coherence at source level
if 1%do_cac_source
  pathname = '/home/language/jansch/projects/streams/data';
  load(fullfile(pathname, [subject.name, '_corticoaudiocoherence']), 'coh', 'trials');
  
  [coh] = streams_corticoaudiocoherence_bf(subject, 'trials', trials, 'frequency', 5);
end
