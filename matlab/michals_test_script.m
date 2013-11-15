
path = '/home/language/miccza/INTERNSHIP/matfiles_stats/';
data = dir('/home/language/miccza/INTERNSHIP/matfiles_stats/*');

load(fullfile(path, data(3).name))

cfgp = [];
cfgp.layout = 'CTF275.lay';
% cfgp.parameter='stat';
% figure;ft_multiplotER(cfgp,stats);
cfgp.parameter='prob';
figure;ft_multiplotER(cfgp,stats);