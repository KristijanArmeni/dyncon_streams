function [source, data] = streams_lcmv(subject, data)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

anatomydir = '/home/language/kriarm/pro/streams/data/MRI/preproc'; %temporary directory
load(fullfile(anatomydir,[subject.name,'_headmodel.mat']));
load(fullfile(anatomydir,[subject.name,'_leadfield_parc.mat']));

%rename the leadfield variable if needed
if exist('leadfield_parc', 'var')
  leadfield = leadfield_parc;
  clear leadfield_parc
end

cfg              = [];
cfg.vartrllength = 2;
cfg.covariance   = 'yes';
tlck             = ft_timelockanalysis(cfg, data);
tlck.cov         = real(tlck.cov);

cfg      = [];
cfg.vol  = headmodel;
cfg.grid = leadfield;
cfg.grid.label = tlck.label;
cfg.method = 'lcmv';
cfg.lcmv.fixedori   = 'yes';
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.lambda     = '5%';
source              = ft_sourceanalysis(cfg, tlck);

if nargout>1
  data = ft_selectdata(data, 'channel', ft_channelselection('MEG', data.label));
  for k = 1:numel(data.trial)
    data.trial{k} = cat(1,source.avg.filter{:})*data.trial{k};
  end
  data.label = leadfield.label;
end  