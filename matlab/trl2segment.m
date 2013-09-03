function newtrl = trl2segment(trl, fs, len, overlap)

if size(trl,1) > 1
  error('only a single trial in the input is supported');
end

overlap = round((1-overlap)*len*fs);
len     = round(len*fs);

newtrl(:,1) = (trl(1,1):overlap:(trl(end,2)))';
newtrl(:,2) = newtrl(:,1) + len - 1;
newtrl(:,3) = trl(1,3) - newtrl(:,1) + trl(1,1);

newtrl(newtrl(:,2)>trl(1,2),:) = [];
