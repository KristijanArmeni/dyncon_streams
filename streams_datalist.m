function [data_files, feature_files] = streams_datalist(freq)
% STREAMS_DATALIST List datafiles and corresponding featuredata from JM directory
% There should be 65 datafiles (one less than featurefiles)
% 
% Input argument:

% freq        =          string, specifying frequency band from the file
%                        name
% Example use:
% 
% [data_files, feature_files] = streams_datalist('12-18')

% Read directory contents
getdata = fullfile('/home/language/jansch/projects/streams/data/preproc/', ['*data_' freq '*']);
getfeatures = fullfile('/home/language/jansch/projects/streams/data/featuredata/', '*featuredata_30*');
data_files = dir(getdata);
data_files = {data_files.name}';
feature_files = dir(getfeatures);
feature_files = {feature_files.name}';

% Create cell arrays with file list that I can compare (for the missing
% data)
data_filestmp = data_files;
for i = 1:length(data_files)
    data_filestmp{i} = data_filestmp{i}(1:12);
end

feature_filestmp = feature_files;
for i = 1:length(feature_files)
    feature_filestmp{i} = feature_filestmp{i}(1:12);
end

% check what is missing and exclude it from featuredata
missing = ismember(feature_filestmp, data_filestmp)';
feature_files(find(missing == 0), :) = [];

end

