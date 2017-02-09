function [mi, filename] = streams_statstruct(datadir, filename_part)
%STREAMS_STATSTRUCT Creates .mat files with datasets per feature and story
%   It reads contents from the directory specified in datadir string argument and joins separate
%   datafiles into one .mat structure for use with ft_timelockstatistics

% Read the contents of the directory with specific feature and freq band
getdata = fullfile(datadir, filename_part);

% create files cell array
files = dir(getdata);
files = {files.name}';

fprintf('I found these files:\n')
disp(files);

mi = cell(numel(files), 1);
fields2remove = {'statshuf', 'mi'};

% loop over all files and store them to the appropriate .mat structure
for k = 1 : numel(files)
        
        filename = files{k};
        load(filename);
    
        % real MI condition
        mi{k} = stat;
        
        if isfield(mi{k}, 'statshuf') % substract the surrogate mi if it exists
            mi{k}.stat = stat.mi - nanmean(stat.statshuf, 3);
            mi{k}.raw = stat.mi;
            mi{k}.shuf = nanmean(stat.statshuf, 3);
            
            %remove statshuf and mi fields
            mi{k} = rmfield(mi{k}, fields2remove);
            
        else
            mi{k}.stat = stat.mi;
        end
        
end    

end

