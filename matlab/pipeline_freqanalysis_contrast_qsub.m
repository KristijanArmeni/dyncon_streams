function pipeline_freqanalysis_contrast_qsub(subject, filename, ivar)

datadir = '/project/3011044.02/analysis/freqanalysis/';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast-subject';

file = fullfile(datadir, [subject filename '.mat']); %.mat files
load(file)

% ivarstr = ivar(6:end); % for saving names

%% Contrast

[freq_T, freq_high, freq_low] = streams_freqanalysis_contrast(freq, ivar);

%% save the output

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s01' filename '_' ivar]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq_T);
end

% save conditions-specific
savename_low = [subject filename '_' ivar '_low'];
savename_low = fullfile(savedir, savename_low);

savename_high = [subject filename '_' ivar  '_high'];
savename_high = fullfile(savedir, savename_high);

save(savename_high, 'freq_high');
save(savename_low, 'freq_low');

% save t-stats

savename_ttest = [subject filename '_' ivar  '_ttest'];
savename_ttest = fullfile(savedir, savename_ttest);
save(savename_ttest, 'freq_T')


end