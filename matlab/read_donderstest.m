function [data] = read_donderstest(filename)

% READ_DONDERSTEST reads a textfile with the extension .words.donderstest,
% assuming a particular text format
%
% Use as
%   data = read_donderstest(filename)
%
% Input argument:
%   filename = string that points to a file with the extension
%              .words.donderstest
%   
% Output argument:
%   data     = structure array containing the data represented in the text
%              file, containing the following fields:
%               word
%               lemma
%               postag
%               postagprob
%               guess
%               logprob
%               entropy
%               perplexity


fid   = fopen(filename);
fseek(fid, 0, 1);  
fpend = ftell(fid);
frewind(fid);



row = 0;
while 1,
  
  % increase the row counter by 1
  row = row+1;
  
  t   = fgetl(fid);
  fp  = ftell(fid);
  if fp==fpend
    break;
  end
  
  data(row,1) = struct('word','','lemma','','postag','','postagprob',nan,'guess','','logprob',nan,'entropy',nan,'perplexity',nan);
  
  col = 0;
  while numel(t)>0
    % increase the column counter by 1
    col = col+1;
    % columns can be either separated by space or tab (=ascii code 9)
    [a1,b1] = strtok(t, ' ');
    [a2,b2] = strtok(t, 9);
    
    if numel(a1)<numel(a2) && numel(a1)>0
      % space occurred earlier than tab
      t    = b1;
      val  = a1;
      data = assignoutput(data, row, col, val);
      continue;
    end
    if numel(a2)<numel(a1) && numel(a2)>0
      % tab occurred earlier than space
      t    = b2;
      val  = a2;
      data = assignoutput(data, row, col, val);
      continue;
    end
  end
end

function data = assignoutput(data, row, col, val)

switch col
  case 1
    data(row,1).word = val;
  case 2
    data(row,1).lemma = val;
  case 3
    data(row,1).postag = val;
  case 4
    data(row,1).postagprob = str2double(val);
  case 5
    % skip this repeats the word
  case 6
    data(row,1).guess = val;
  case 7
    data(row,1).logprob = str2double(val);
  case 8
    data(row,1).entropy = str2double(val);
  case 9
    data(row,1).perplexity = str2double(val);
  otherwise
    error('invalid column number');
end

