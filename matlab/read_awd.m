function [data] = read_awd(filename)

% READ_AWD reads *.awd files containing timing information for the
% individual words in the file
%
% Input argument:
%   filename to the *.awd file
%
% Output argument:
%   data structure containing some header info and the following fields:
%     words = Nx1 cell-array with the words
%     times = Nx2 matrix with the corresponding begin and end times
%
% info about the file format has been taken from:
% http://lands.let.ru.nl/cgn/doc_English/topics/version_1.0/formats/text/ort.htm
% also see: http://lands.let.ru.nl/cgn/doc_English/topics/version_1.0/formats/text/ort.htm

fid = fopen(filename);

%-----------------------------------------
% first 7 lines contain the general header

% check the first line
t   = fgetl(fid);
if ~strcmp(t, 'File type = "ooTextFile short"')
  error('the file %s may be of an unsupported file format, abort reading');
end

% skip a few lines
skiplines(fid, 5);

% get the number of tiers
ntier = str2double(fgetl(fid));
% end of header
%----------------------------------

% loop over the tiers
data = struct('speaker', '', 'time_beg', nan, 'time_end', nan, 'ninterval', nan, 'times', [], 'words', {});
for k = 1:ntier
  fgetl(fid);               %reads the line saying "IntervalTier", does nothing.
  tmp = fgetl(fid);         
  data(k).speaker   = tmp(2:end-1);
  data(k).time_beg  = str2double(fgetl(fid));
  data(k).time_end  = str2double(fgetl(fid));
  data(k).ninterval = str2double(fgetl(fid));

  % read the text for this tier
  times = zeros(data(k).ninterval,2);
  words = cell(data(k).ninterval,1);
  for m = 1:data(k).ninterval
    times(m,1) = str2double(fgetl(fid));
    times(m,2) = str2double(fgetl(fid));
    tmp        = fgetl(fid);
    words{m,1} = tmp(2:end-1); % remove the quotation marks
  end
  data(k).times = times;
  data(k).words = words;
end

fclose(fid);


function skiplines(fid, n)

for k = 1:n
  fgetl(fid);
end
