function [data] = read_donders(filename)

% READ_DONDERS reads a textfile with the extension .donders,
% assuming the first line to contain the info about the fields
%
% Use as
%   data = read_donderstest(filename)
%
% Input argument:
%   filename = string that points to a file with the extension donders
%   
% Output argument:
%   data     = structure array containing the data represented in the text
%              file, containing the fields as named in the first line of the file

fid   = fopen(filename);
fseek(fid, 0, 1);  
fpend = ftell(fid);
frewind(fid);

data = struct([]);
  
row = 0;
while 1,
  
  % increase the row counter by 1
  row = row+1;
  
  t   = fgetl(fid);
  fp  = ftell(fid);
  if fp==fpend
    break;
  end
  
  if row==1
    % determine the fields
    col = 0;
    while numel(t)>0
      col = col+1;
      % columns can be either separated by space or tab (=ascii code 9)
      [a1,b1] = strtok(t, ' ');
      [a2,b2] = strtok(t, 9);
    
      a1(strfind(a1,'#')) = '_';
      a2(strfind(a2,'#')) = '_';
      a1(strfind(a1,'-')) = '_';
      a2(strfind(a2,'-')) = '_';
      
      if numel(a1)<numel(a2) && numel(a1)>0
        % space occurred earlier than tab
        t    = b1;
        fname{1,col} = a1;
        continue;
      end
      if numel(a2)<numel(a1) && numel(a2)>0
        % tab occurred earlier than space
        t    = b2;
        fname{1,col} = a2;
        continue;
      end
    end
    continue;
  end
  
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
      data = assignoutput(data, row-1, fname{col}, val);
      continue;
    end
    if numel(a2)<numel(a1) && numel(a2)>0
      % tab occurred earlier than space
      t    = b2;
      val  = a2;
      data = assignoutput(data, row-1, fname{col}, val);
      continue;
    end
  end
end

function data = assignoutput(data, row, fname, val)

switch fname
  case {'word' 'POS' 'lemma' 'deprel' 'prediction'}
    data(row,1).(fname) = val;
  case {'sent_' 'word_' 'depind' 'logprob' 'entropy' 'perplexity' 'gra_perpl' 'pho_perpl'}
    data(row,1).(fname) = str2double(val);
  otherwise
    error('invalid fieldname');
end

