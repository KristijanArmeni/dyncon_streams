function script_withinsubject_trialinfo

savedir = '/project/3011044.02/analysis/lng-contrast/';
datadir = '/project/3011044.02/preproc/meg/';

%% CREATE IN EPOCHED FEATUREDATA WITH TRIALINFO AND CONTRAST STRUCTURE
   
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

varnames = {'mode_story', 'num_trl', 'trl_low', 'trl_high', ...
                     'perp_L_M', 'perp_H_M', ...
                      'corr_lf', 'corr_audio'};
header = categorical(varnames);

dat                 = zeros(num_sub, numel(header));
trialinfoR          = zeros(1, 6); % just initializing for the loop
trialinfoR_rownames = {'empty'};
pcontrastinfoR      = {'empty'};
econtrastinfoR      = {'empty'};

for k = 1:num_sub

    subject = subjects{k};

    megf         = fullfile(datadir, [subject '_meg-clean']);
    featuredataf = fullfile(datadir, [subject '_featuredata']);
    audiof       = fullfile(datadir, [subject, '_aud']);
    load(megf)
    load(featuredataf)
    load(audiof)

    opt = {'save', 0, ...
           'altmean', 0, ...
           'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
           'audio_features', {'audio_avg'}, ...
           'contrastvars', {'entropy', 'perplexity'}};

    [depdata, ~, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);
    clear featuredata data audio
    
    col         = ismember(header, 'mode_story');
    dat(k, col) = mode(depdata.trialinfo(:, 1));
    
    col         = ismember(header, 'num_trl');
    dat(k, col) = numel(depdata.trial);
    
    col         = ismember(header, {'trl_low', 'trl_high'});
    dat(k, col) = sum(contrast(1).trial);
    
    col         = ismember(header, 'perp_L_M');
    rowsel      = contrast(2).trial(:, 1);
    colsel      = ismember(depdata.trialinfolabel, 'perplexity');
    dat(k, col) = mean(depdata.trialinfo(rowsel, colsel));
    
    col         = ismember(header, 'perp_H_M');
    rowsel      = contrast(2).trial(:, 2);
    colsel      = ismember(depdata.trialinfolabel, 'perplexity');
    dat(k, col) = mean(depdata.trialinfo(rowsel, colsel));
    
    col         = ismember(header, 'corr_lf');
    colsel1     = ismember(depdata.trialinfolabel, 'perplexity');
    colsel2     = ismember(depdata.trialinfolabel, 'log10wf');
    dat(k, col) = corr(depdata.trialinfo(:, colsel1), depdata.trialinfo(:, colsel2));
    
    col         = ismember(header, 'corr_audio');
    colsel1     = ismember(depdata.trialinfolabel, 'perplexity');
    colsel2     = ismember(depdata.trialinfolabel, 'audio_avg');
    dat(k, col) = corr(depdata.trialinfo(:, colsel1), depdata.trialinfo(:, colsel2));
    
    if str2double(subject(2:end)) > 10
        depdata.trialinfo(:, 1) = depdata.trialinfo(:,1)./10; % change labels 10, 20 to 1, 2 etc.
    end
    
    trialinfo = depdata.trialinfo;
    
    % add perplexity contrast info
    contrastinfo1 = contrast(ismember({contrast.indepvar}, 'perplexity'));
    pcontrast     = cell(numel(contrastinfo1.trial(:, 1)), 1);
    
    pcontrast(:)  = {'mid'};
    pcontrast(contrastinfo1.trial(:, ismember(contrastinfo1.label, 'low')))  = {'low'};
    pcontrast(contrastinfo1.trial(:, ismember(contrastinfo1.label, 'high'))) = {'high'};
    
    % add entropy contrast info
    contrastinfo2 = contrast(ismember({contrast.indepvar}, 'entropy'));
    econtrast     = cell(numel(contrastinfo2.trial(:, 1)), 1);
    
    econtrast(:)  = {'mid'};
    econtrast(contrastinfo2.trial(:, ismember(contrastinfo2.label, 'low')))  = {'low'};
    econtrast(contrastinfo2.trial(:, ismember(contrastinfo2.label, 'high'))) = {'high'};
    
    % save
    savename = fullfile(savedir, [subject '_contrast']);
    savename2 = fullfile(savedir, [subject, '_trialinfo']);
    
    save(savename, 'contrast');
    save(savename2, 'trialinfo');
    
    % append subject-specific trial info to common arrays
    trialinfoR          = [trialinfoR; trialinfo]; % numerical data
    trialinfoR_rownames = [trialinfoR_rownames; repmat({subject}, numel(depdata.trial), 1)]; % subject string
    pcontrastinfoR       = [pcontrastinfoR; pcontrast]; % contrast bin categories
    econtrastinfoR       = [econtrastinfoR; econtrast];
end

%% Construct a table

trialinfo_num       = array2table(trialinfoR);         % convert matrix with trialinfo numbers tot table
trialinfo_sub       = cell2table(trialinfoR_rownames); % convert cell array with sub ids to table
trialinfo_pcontrast = cell2table(pcontrastinfoR);
trialinfo_econtrast = cell2table(econtrastinfoR);

tabtrialinfo = [trialinfo_sub, trialinfo_num, trialinfo_pcontrast, trialinfo_econtrast]; % concatenate into a single table
tabtrialinfo.Properties.VariableNames = ['subject' depdata.trialinfolabel' 'p_bin' 'e_bin']; % add variable names

tabtrialinfo = tabtrialinfo(:, [1 2 3 4 end-1, 5 end 6 7]); % reorder bin columns next to columns with values

% summary table
tabdat       = array2table(dat, 'RowNames', subjects', 'VariableNames', varnames);

%% SAVING
savename3 = fullfile(savedir, 'within_subject_info');
savename4 = fullfile(savedir, 's02-s28_trialinfo');

save(savename3, 'tabdat');
save(savename4, 'varnames', 'trialinfoR_rownames', 'trialinfoR', 'econtrastinfoR', 'pcontrastinfoR');

% txt files
writetable(tabtrialinfo, [savename4 '.txt']);
    
end