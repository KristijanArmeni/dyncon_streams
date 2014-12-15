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
%   for k = 1:size(subject.trl,1)
%     [coh, trials] = streams_corticoaudiocoherence(subject,'trials',k);
%     pathname = '/home/language/jansch/projects/streams/data';
%     save(fullfile(pathname, [subject.name, '_corticoaudiocoherence_',num2str(k,'%02d')]), 'coh', 'trials');
%   end
  [coh, trials, freq, data] = streams_corticoaudiocoherence(subject, 'resamplefs', 200);
  pathname = '/home/language/jansch/projects/streams/data/corticoaudiocoherence';
  save(fullfile(pathname, [subject.name, '_corticoaudiocoherence']), 'coh', 'trials', 'data');
end

%% compute cortico_audio coherence at source level
if 0%do_cac_source
  pathname = '/home/language/jansch/projects/streams/data/corticoaudiocoherence';
  load(fullfile(pathname, [subject.name, '_corticoaudiocoherence']), 'data', 'trials');
  
  for idx = 1:numel(subject.cac)
    %[source, coh, ~, freq] = streams_corticoaudiocoherence_bf(subject, 'frequency', subject.cac(idx), 'subtrials', trials(:,end), 'resamplefs', 300);
    [source, coh, count, ~, freq] = streams_corticoaudiocoherence_bf(subject, 'frequency', subject.cac(idx), 'data', data);
    freq = ft_checkdata(freq, 'cmbrepresentation', 'fullfast');
    save(fullfile(pathname, [subject.name, '_corticoaudiocoherence_source_',num2str(subject.cac(idx)),'.mat']), 'source', 'freq', 'coh', 'count');
  end
end

if 0%do_cac_lcmv
  pathname = '/home/language/jansch/projects/streams/data/corticoaudiocoherence';
  cd(pathname);
  
  load standard_sourcemodel3d5mm;
  inside  = sourcemodel.inside;
  ninside = numel(inside);
  chunk   = [0:500:ninside ninside];
  %if ~exist('subset', 'var')
  %  subset = 1:(numel(chunk)-1);
  %end
  
  d = dir([subjectid,'*output.mat']);
  tmp = nan+zeros(numel(d),1);
  for k = 1:numel(d)
    tmp(k) = str2double(d(k).name(5:7));
  end
  subset = setdiff(1:(numel(chunk)-1),tmp);
  
  for k = subset(:)'
    voxindx = inside((chunk(k)+1):chunk(k+1));
    str     = sprintf('%s_%03d',subjectid,k);
    qsubfeval('streams_corticoaudiocoherence_lcmv', subject, voxindx, 'memreq', 8*1024^3, 'timreq', 60*60 ,'batchid', str);
  end
end

if 1%compile cross frequency results
  pathname = '/home/language/jansch/projects/streams/data/corticoaudiocoherence';
  cd(pathname);
  
  load standard_sourcemodel3d5mm;
  inside  = sourcemodel.inside;
  ninside = numel(inside);
  chunk   = [0:500:ninside ninside];
  cnt = 0;
  for k = 1:numel(chunk)-1
    voxindx = inside((chunk(k)+1):chunk(k+1));
    str     = sprintf('%s_%03d*output.mat',subjectid,k);
    d       = dir(str);
    if ~isempty(d)
      cnt = cnt+1;
      filename{cnt} = d.name;
    end
  end
  if numel(filename)==numel(chunk)-1
    coh = zeros(0,12,151);
    voxindx = zeros(1,0);
    for k = 1:numel(filename)
      fprintf('loading %d/%d\n',k,numel(filename));
      load(filename{k});
      n = numel(argout{2});
      coh = cat(1,coh,reshape(argout{1},[n 12 151]));
      voxindx = cat(2,voxindx,argout{2}(:)');
    end
    source = rmfield(sourcemodel, {'xgrid' 'ygrid' 'zgrid'});
    source.coh = zeros(prod(source.dim),12,151);
    source.coh(source.inside,:,:) = abs(coh);
    source.time = 0:0.2:30;
    source.freq = 1:12; %dummy
    save(fullfile(pathname,[subject.name,'_corticoaudiocoherence_source_gammaenv_35-45']), 'source');
  else
    error('the set of files is incomplete');
  end
end

