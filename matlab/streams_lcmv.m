function [source, data] = streams_lcmv(subject, data)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

anatomydir = '/project/3011044.02/preproc/anatomy'; %temporary directory
load(fullfile(anatomydir,[subject.name,'_headmodel.mat']));
load(fullfile(anatomydir,[subject.name,'_leadfield_parc.mat']));

%rename the leadfield variable if needed
if exist('leadfield_parc', 'var')
  fprintf('Using parcellated leadfields in streams_lcmv()...\n')
  leadfield = leadfield_parc;
  clear leadfield_parc
end

%% Compute spatial filters

cfg              = [];
cfg.vartrllength = 2;
cfg.covariance   = 'yes';
tlck             = ft_timelockanalysis(cfg, data);
tlck.cov         = real(tlck.cov);

cfg                 = [];
cfg.vol             = headmodel;
cfg.grid            = leadfield;
cfg.grid.label      = tlck.label;
cfg.method          = 'lcmv';
cfg.lcmv.fixedori   = 'yes';%'no';
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.lambda     = '5%';
source              = ft_sourceanalysis(cfg, tlck);

% storing source.cfg information for ft_analysispipeline
cfgt = [];
cfgt.comment = 'streams_lcmv';
data = ft_annotate(cfgt, data);  % add comment and shift .previous
data.cfg.previous = {data.cfg.previous}; % make it a 1-by-1 cell
data.cfg.previous(2) = {source.cfg};  % store source.cfg info

%%  Apply spatial filters to the data

if nargout>1
  data = ft_selectdata(data, 'channel', ft_channelselection('MEG', data.label));
  for k = 1:numel(data.trial)
    data.trial{k} = cat(1,source.avg.filter{:})*data.trial{k};
  end
  
  % if multiple orientations per parcel are allowed, then adjust the parcel
  % label field accordingly
  if strmatch(cfg.lcmv.fixedori, 'no')
    ncomp = cellfun('size',source.avg.filter,1);
    data.label=cell(0,1);
    
    for k = 1:numel(ncomp)  
      for m = 1:ncomp(k)
        data.label{end+1}=sprintf('%s_%0.2d',leadfield.label{k},m);
      end
    end
  else 
    % add parcel labels
    data.label = leadfield.label;
  end
  
end
    
end  