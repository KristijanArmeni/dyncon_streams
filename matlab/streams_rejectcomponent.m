function [data] = streams_rejectcomponent(subject)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

subjectfull = streams_subjinfo(subject);
datadir = '/project/3011044.02/preproc/meg';
savedir = '/project/3011044.02/preproc/meg/clean-epoched/fastica2';

datafile = fullfile(datadir, [subject '_meg.mat']);
compfile = fullfile(datadir, [subject '_comp.mat']);

load(datafile);
load(compfile);

selcomp = subjectfull.eogv.badcomps;

if ~isempty(selcomp)
    cfg = [];
    cfg.component = selcomp;
    data = ft_rejectcomponent(cfg, comp, data);
end

cfg = [];
cfg.length = 1;
data = ft_redefinetrial(cfg, data);

savename = fullfile(savedir, [subject '_clean']);
save(savename, 'data');
end

