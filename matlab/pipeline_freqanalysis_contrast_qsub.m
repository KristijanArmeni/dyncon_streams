function pipeline_freqanalysis_contrast_qsub(subject, var)

savedir = '/project/3011044.02/analysis/freqanalysis';

file = fullfile('/project/3011044.02/analysis/freqanalysis', [subject '_all_01-100_freqanalysis_200Hz.mat']);
load(file)

%% Contrast

[freq_change, freq_high, freq_low] = streams_freqanalysis_contrast(freq, var);

%% save the output

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s01_all_01-100_freqanalysis_diff_' var '_200Hz']);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq_change);
end

% save conditions-specific
savename_low = [subject '_all_01-100_freqanalysis_' var '_low_200Hz'];
savename_low = fullfile(savedir, savename_low);

savename_high = [subject '_all_01-100_freqanalysis_' var '_high_200Hz'];
savename_high = fullfile(savedir, savename_high);

save(savename_high, 'freq_high');
save(savename_low, 'freq_low');

% save difference
savename = [subject '_all_01-100_freqanalysis_' var '_diff_200Hz'];
savename = fullfile(savedir, savename);
save(savename, 'freq_change');

end