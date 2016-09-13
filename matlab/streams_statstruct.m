function [miAc, miReal, miShuf, miRand, filename] = streams_statstruct(datadir, filename_part, varargin)
%STREAMS_STATSTRUCT Creates .mat files with datasets per feature and story
%   It reads contents from the directory specified in datadir string argument and joins separate
%   datafiles into one .mat structure for use with ft_timelockstatistics

% Read the contents of the directory with specific feature and freq band
getdata = fullfile(datadir, filename_part);

% create files cell array
files = dir(getdata);
files = {files.name}';

% create cell structures for looping over
miAc = cell(numel(files), 1);
miReal = cell(numel(files), 1);
miShuf = cell(numel(files), 1);
miRand = cell(numel(files), 1);

% loop over all files and store them to the appropriate .mat structure

for k = 1 : numel(files)

    filename = files{k};
    load(filename);
    
    if ~isfield(stat, 'statshuf')
        
        % general procedure
        miAc{k} = stat;
        
    elseif isfield(stat, 'statshuf') && isfield(stat, 'statrand')
        % real MI condition
        miReal{k} = stat;
        miReal{k} = rmfield(miReal{k}, {'statshuf', 'statrand'});    % remove the statshuf timecourse
        
        % surrogate MI
        miShuf{k} = stat;
        miShuf{k} = rmfield(miShuf{k}, {'statshuf', 'statrand', 'stat'});          % remove old .statshuf, .stat & field
        miShuf{k}.stat = mean(stat.statshuf, 3);                       % assign .statshuf timecourse as .stat field
        miShuf{k} = orderfields(miShuf{k}, miReal{k});                 % order fields as in miReal
        
        % surrogate rand MI
        miRand{k} = stat;
        miRand{k} = rmfield(miRand{k}, {'statshuf', 'statrand', 'stat'});          % remove old .statshuf, statrand, .stat & field
        miRand{k}.stat = mean(stat.statrand, 3);                       % assign .statrand timecourse as .stat field
        miRand{k} = orderfields(miRand{k}, miReal{k});                 % order fields as in miReal
        
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

end

