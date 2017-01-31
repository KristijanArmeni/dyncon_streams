function [stat] = qsub_streams_megaudio_MI(subject, bpfreq, comps)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

comp_dir = '/home/language/kriarm/matlab/streams_output/dss_timelocked';
savedir = '/home/language/kriarm/matlab/streams_output/stats/meg_audio_MI';


cfg = [];
cfg.channel = 'MEG';
data = ft_selectdata(cfg, data);
data = streams_dss_rejectauditory(subject, data, comps, comp_dir);                            

data = ft_appenddata(data, data_old);

cfg = [];
cfg.channel = {'all'; '-UADC004'};
data = ft_preprocessing(cfg, data);
                            
cfg = [];
cfg.hilbert = 'angle';
data = ft_preprocessing(cfg, data);

cfg = [];
cfg.method = 'mi';
cfg.refindx = numel(data.label);
stat = ft_connectivityanalysis(cfg, data);

fullname = fullfile(savedir, filename);
save(fullname, 'stat');

end

