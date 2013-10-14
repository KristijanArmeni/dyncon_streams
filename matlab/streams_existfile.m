function [status, filename] = streams_existfile(filename)

% the assumed path where the files will be looked for is:
pathname = '/home/language/jansch/projects/streams/data/';
filename = fullfile(pathname,filename);
status   = exist(filename,'file');