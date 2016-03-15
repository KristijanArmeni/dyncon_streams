function [miReal, miShuf] = streams_statstruct(feat_band)
%STREAMS_STATSTRUCT Creates .mat files with datasets per feature and story
%   It reads contents from med_model_MI_noDss dir and joins separate
%   datafiles into .mat structures for use with ft_timelockstatistics

% Create structures for stats
save_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss/MI_combined';

% Read the contents of the directory with specific feature and freq band
getdata = fullfile('/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss', ...
                   ['*' feat_band '*']);

% create files cell array
files = dir(getdata);
files = {files.name}';

% create cell structures for looping over
miReal = cell(numel(files), 1);
miShuf = cell(numel(files), 1);

% loop over all files and store them to the appropriate .mat structure

for k = 1 : numel(files)

    filename = files{k};
    load(filename);

    % real MI condition
    miReal{k} = stat;
    miReal{k} = rmfield(miReal{k}, 'statshuf');    % remove the statshuf timecourse

    % surrogate MI
    miShuf{k} = stat;
    miShuf{k} = rmfield(miShuf{k}, {'statshuf', 'stat'});   % remove old .statshuf & .stat field
    miShuf{k}.stat = mean(stat.statshuf, 3);                % add .statshuf timecourse as .stat field
    miShuf{k} = orderfields(miShuf{k}, miReal{k});          % order fields as in miReal

end    

% save the structures
saveMi = fullfile(save_dir, ['mi_' filename(14:23)] );
save(saveMi, 'miReal', 'miShuf');

end

