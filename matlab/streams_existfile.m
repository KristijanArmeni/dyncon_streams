function [status, filename] = streams_existfile(filename, pathname)

% the assumed path where the files will be looked for is:
if nargin<2
  pathname = '/home/language/jansch/projects/streams/data/';
end
filename = fullfile(pathname,filename);
status   = exist(filename,'file');
