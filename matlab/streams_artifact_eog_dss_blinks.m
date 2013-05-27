function [avgcomp, avgpre, avgeog, mixing, unmixing] = streams_artifact_eog_dss_blinks(subject)

[status, filename] = streams_existfile([subject.name,'_eogv.mat']);
if status
  load(filename);
else
  fprintf('computing EOGv topographies for subject %s\n', subject.name);
  cfg0 = [];
  cfg0.dataset    = subject.dataset;
  cfg0.trl        = subject.trl;
  cfg0.artfctdef  = subject.artfctdef;
  cfg0.artfctdef.reject = 'partial';
  cfg0 = ft_rejectartifact(cfg0);
  
  cfg1            = [];
  cfg1.continuous = 'yes';
  cfg1.dataset    = subject.dataset;
  cfg1.channel    = 'MEG';
  cfg1.demean     = 'yes';
  cfg1.trl        = cfg0.trl;
  cfg1.trl(:,3)   = 0;
  
  cfg2            = cfg1;
  cfg2.channel    = {'EOGv' 'EEG058'};
  cfg2.boxcar     = 0.2;
  cfg2.bpfilter   = 'yes';
  cfg2.bpfreq     = [1 10];
  cfg2.bpfiltord  = 2;
  cfg2.rectify    = 'yes';
  cfg2.trl        = cfg0.trl;
  
  cfg3            = [];
  cfg3.demean     = 'yes';
  cfg3.detrend    = 'no';
  cfg3.resamplefs = 300;
  
  % read in and normalise eog data
  data            = ft_resampledata(cfg3, ft_preprocessing(cfg1));
  eog             = ft_resampledata(cfg3, ft_channelnormalise([], ft_preprocessing(cfg2)));
  
  % compute peak times for eog
  clear p
  for k = 1:numel(eog.trial)
    p = peakdetect2(eog.trial{k}(1,:),0.5,120);
    params.tr{k,1} = p(:);
  end
  
  cfg2.rectify = 'no';
  cfg2         = rmfield(cfg2, 'boxcar');
  
  eognew = ft_resampledata(cfg3, ft_preprocessing(cfg2));
  eognew = ft_checkdata(eognew, 'hassampleinfo', 'yes');
  
  % do componentanalysis for eye blinks
  addpath /home/language/jansch/matlab/toolboxes/dss2_1-0
  params.demean   = 1;
  s.X             = 1;
  params.computenew = 0;
  params.pre      = 50;
  params.pst      = 75;
  [~,~,avgpre]    = denoise_avg2(params,data.trial,s);
  [~,~,avgeog]    = denoise_avg2(params,eognew.trial,s);
  params.computenew = 1;
  
  cfg                   = [];
  cfg.method            = 'dss';
  cfg.dss.denf.function = 'denoise_avg2';
  cfg.dss.denf.params   = params;
  cfg.channel           = 'MEG';
  cfg.numcomponent      = 10;
  cfg.cellmode          ='yes';
  comp                  = ft_componentanalysis(cfg, data);
  params.computenew     = 0;
  [~,~,avgcomp]         = denoise_avg2(params,comp.trial,s);
  
  mixing   = comp.topo;
  unmixing = comp.unmixing;
  filename = fullfile('/home/language/jansch/projects/streams/data/', [subject.name,'_eogv.mat']);
  save(filename, 'avgpre', 'avgcomp', 'avgeog', 'mixing', 'unmixing');
end


