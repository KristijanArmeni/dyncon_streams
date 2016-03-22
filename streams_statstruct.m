function [miReal, miShuf] = streams_statstruct(datadir, filename_part, varargin)
%STREAMS_STATSTRUCT Creates .mat files with datasets per feature and story
%   It reads contents from med_model_MI_noDss dir and joins separate
%   datafiles into .mat structures for use with ft_timelockstatistics

save_dir         = ft_getopt(varargin, 'saveto', datadir);

% Read the contents of the directory with specific feature and freq band
getdata = fullfile(datadir, ['*' filename_part '*']);

% create files cell array
files = dir(getdata);
files = {files.name}';

% create cell structures for looping over
miAc = cell(numel(files), 1);
miReal = cell(numel(files), 1);
miShuf = cell(numel(files), 1);

% loop over all files and store them to the appropriate .mat structure

for k = 1 : numel(files)

    filename = files{k};
    load(filename);
    
    if ~isfield(stat, 'statshuf')
        
        % general procedure
        miAc{k} = stat;
        
    else
        % real MI condition
        miReal{k} = stat;
        miReal{k} = rmfield(miReal{k}, {'statshuf'});    % remove the statshuf timecourse

        % surrogate MI
        miShuf{k} = stat;
        miShuf{k} = rmfield(miShuf{k}, {'statshuf', 'stat'});          % remove old .statshuf, .stat & field
        miShuf{k}.stat = mean(stat.statshuf, 3);                       % assign .statshuf timecourse as .stat field
        miShuf{k} = orderfields(miShuf{k}, miReal{k});                 % order fields as in miReal

    end
    
end    

% save the structures
if ~isfield(stat, 'statshuf')
    saveStruct = fullfile(save_dir, ['acLag_' filename(14:24)]);
    save(saveStruct, 'miAc');
else
    saveStruct = fullfile(save_dir, ['mi_' filename(14:23)] );
    save(saveStruct, 'miReal', 'miShuf');
end

end

