
wavefiles = {'fn001078' 'fn001155' 'fn001172' 'fn001293' 'fn001294' 'fn001443' 'fn001481' 'fn001498'};
stim_dir  = '/project/3011044.02/lab/experiment/stims'; % stimulus directory
savedir   = '/project/3011044.02/docs/draft/tables/';

dur = cell(numel(wavefiles), 3);

for i = 1:numel(wavefiles)
    
    filename = fullfile(stim_dir, [wavefiles{i} '.wav']);
    info     = audioinfo(filename);
    
    sec = round(info.Duration);
    min = floor(round(info.Duration)/60);
    rem = sec - (min*60);
    
    dur{i, 1} = wavefiles{i};
    dur{i, 2} = round(info.Duration);
    dur{i, 3} = sprintf('%02d:%02d', min, rem);
end

stim_duration = array2table(dur, 'VariableNames', {'story' 'sec', 'mm_ss'});
save([savedir 'stim_duration'], 'dur');
writetable(stim_duration, [savedir 'stim_duration.txt']);