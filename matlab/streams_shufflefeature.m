function [shuffle] = streams_shufflefeature(featuredat, nshuffle, randomseed)

if isstruct(featuredat)
  smps = [0 cumsum(cellfun('size',featuredat.trial,2))];
  tmp  = cat(2,featuredat.trial{:});
  shuf = streams_shufflefeature(tmp, nshuffle);
  shuffle = cell(1,numel(featuredat.trial));
  for k = 1:numel(smps)-1
    shuffle{1,k} = shuf(:,(smps(k)+1):smps(k+1));
  end
  return;
end

featuredatorig = featuredat;
sel        = isfinite(featuredat);
featuredat = featuredat(sel);

ramp_up   = find(diff([-inf featuredat])>0);
ramp_down = find(diff([-inf featuredat])<0);
ramp_all  = sort([ramp_up ramp_down]);

% the ramp_all variable contains the start indices of the plateaus, which
% run until the next index, minus 1
ramp_all(end+1) = numel(featuredat)+1;

val  = zeros(1,numel(ramp_all)-1);
indx = zeros(1,numel(featuredat)); 
for k = 1:numel(ramp_all)-1
  val(1,k) = featuredat(ramp_all(k));
  indx(ramp_all(k):(ramp_all(k+1)-1)) = k;
end

tmpshuffle = zeros(nshuffle, numel(featuredat))+nan;
for k = 1:nshuffle
  tmp  = randperm(numel(val));
  %tmp2 = val_reindex_random(val);
  tmp2 = val;
  tmpval = tmp2(tmp);
  tmpshuffle(k,:) = tmpval(indx);
end
shuffle        = zeros(nshuffle, numel(featuredatorig))+nan;
shuffle(:,sel) = tmpshuffle;

function out = val_reindex_random(in)

% randomly reindex the values, keeping the probability distribution
out    = in;
out(:) = nan;
uin    = unique(in);
uin_perm = uin(randperm(numel(uin)));

for k = 1:numel(uin)
  out(in==uin(k)) = uin_perm(k);
end

