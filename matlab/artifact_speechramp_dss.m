function [comp, avgcomp, avgpost, params] = artifact_speechramp_dss(data, varargin)

% this code serves as an example to identify the speechramp related components

% ensure that the dss2_1-0 directory is on your matlab path
addpath('/home/language/kriarm/matlab/dss2_1-0');

pre             = ft_getopt(varargin, 'pre');
pst             = ft_getopt(varargin, 'pst');
p_ind           = ft_getopt(varargin, 'p_ind');
reject          = ft_getopt(varargin, 'reject', 0);
comps           = ft_getopt(varargin, 'comps');
%sdemean   = ft_getopt(varargin, 'demean')

s.X = 1;
params.tr = [];
params.tr_inds = p_ind;
params.pre = pre;
params.pst = pst;
params.demean = true;

% Do component analysis

fprintf('\nStarting component analysis ...\n');
fprintf('=========================================\n');

cfg                   = [];
cfg.cellmode          = 'yes';
cfg.method            = 'dss';
cfg.dss.denf.function = 'denoise_avg2';
cfg.dss.denf.params   = params;
cfg.channel           = 'MEG';
cfg.numcomponent      = 20;
comp                  = ft_componentanalysis(cfg, data);

fprintf('\nAveraging components ...\n');
fprintf('=========================================\n');

[~,~,avgcomp]         = denoise_avg2(params,comp.trial,s);


if reject
    % Reject component
    fprintf('\nRejecting components ...\n');
    fprintf('=========================================\n');

    cfg           = [];
    cfg.component = comps;
    data = ft_rejectcomponent(cfg, comp, data);
    [~,~,avgpost] = denoise_avg2(params,data.trial,s);
end

fprintf('\n###artifact_speechramp_dss: DONE!###\n');

% cfg            = [];
% cfg.trl        = trl;
% cfg.continuous = 'yes';
% cfg.dataset    = filename;
% cfg.channel    = 'MEG';
% cfg.demean     = 'yes';
% cfg.hpfilter   = 'yes';
% cfg.hpfilttype = 'firls';
% cfg.hpfreq     = 0.5;
% cfg.hpfiltord  = 200;
% data           = ft_preprocessing(cfg);
% 
% cfg.channel    = {'EEG057'};
% cfg.boxcar     = 0.2;
% cfg.hpfilter   = 'no';
% cfg.bpfilter   = 'yes';
% cfg.bpfreq     = [1 10];
% cfg.bpfiltord  = 2;
% cfg.rectify    = 'yes';
% eog            = ft_preprocessing(cfg);
% 
% % post process eog data
% eog  = ft_channelnormalise([], eog);
% 
% % compute peak times for eog
% clear p
% for k = 1:numel(eog.trial)
%   p{k} = peakdetect2(eog.trial{k}(1,:),0.5,40);
% end
% 
% % convert to linear array
% nsmp = cellfun('size', eog.trial, 2);
% [p,begsmp,endsmp] = peaks2continuous(p, nsmp, 300, 900);
% fprintf('detected %d blinks\n', numel(p));
% 
% % do componentanalysis for eye blinks
% addpath /home/language/jansch/matlab/toolboxes/dss_1-0
% params.tr = p(:);
% params.tr_begin = begsmp(:);
% params.tr_end   = endsmp(:);
% params.demean   = true;
% s.X             = 1;
% [~,~,avgpre]    = denoise_avg2(params,cat(2,data.trial{:}),s);
% 
% cfg                   = [];
% cfg.method            = 'dss';
% cfg.dss.denf.function = 'denoise_avg2';
% cfg.dss.denf.params   = params;
% cfg.channel           = 'MEG';
% cfg.numcomponent      = 9;
% comp                  = ft_componentanalysis(cfg, data);
% [~,~,avgcomp]         = denoise_avg2(params,cat(2,comp.trial{:}),s);
% 
% cfg           = [];
% cfg.component = 1;
% data = ft_rejectcomponent(cfg, comp, data);
% [~,~,avgpost] = denoise_avg2(params,cat(2,data.trial{:}),s);

%comp          = rmfield(comp, 'trial');
