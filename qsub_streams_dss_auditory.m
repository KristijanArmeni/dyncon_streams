function qsub_streams_dss_auditory(data, subject)

out_dir = '/home/language/kriarm/matlab/streams_output/dss_timelocked';
cd(out_dir);

cfg = [];
cfg.channel = 'z-scored diff';
audio = ft_selectdata(cfg, data);
cfg.channel = 'MEG';
data = ft_selectdata(cfg, data);

component_filename      = sprintf('%s_dss_audcomp', subject.name);
tlck_filename           = sprintf('%s_tlck', subject.name);

[~, ~] = streams_dss_auditory(data, audio, ...
                              'savecomps', component_filename);

cd ~;

end

