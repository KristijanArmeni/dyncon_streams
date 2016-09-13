function [randfeature] = streams_randomfeature(featuredat, nshuffle)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if isstruct(featuredat)
  smps = [0 cumsum(cellfun('size',featuredat.trial,2))];
  tmp  = cat(2,featuredat.trial{:});
  shuf = streams_shufflefeature(tmp, nshuffle);
  randfeature = cell(1,numel(featuredat.trial));
  for k = 1:numel(smps)-1
    randfeature{1,k} = shuf(:,(smps(k)+1):smps(k+1));
  end
  return;
end

featuredatorig   = featuredat;
sel              = isfinite(featuredat);
featuredat       = featuredat(sel);

ramp_up   = find(diff([-inf featuredat])>0);
ramp_down = find(diff([-inf featuredat])<0);
ramp_all  = sort([ramp_up ramp_down]);

% the ramp_all variable contains the start indices of the plateaus, which
% run until the next index, minus 1
ramp_all(end+1) = numel(featuredat)+1;

%create vectors that store values and indices
val  = zeros(1,numel(ramp_all)-1);  % for model values
indx = zeros(1,numel(featuredat));  % for indices

for k = 1:numel(ramp_all)-1
  val(1,k) = featuredat(ramp_all(k));
  indx(ramp_all(k):(ramp_all(k+1)-1)) = k;
end

% create a vector of random values in the range max and min model value
valmin = min(val);            % minimum value in the model output
valmax = max(val);            % maximum value in the model output
maxmindiff = valmax-valmin;   % difference of the two

tmprand = zeros(nshuffle, numel(featuredat))+nan;
% loop
for k = 1:nshuffle
  randval = maxmindiff.*rand(1,size(tmprand, 2)) + valmin; %create random values in the range of max and min model values
  tmprand(k,:) = randval(indx);                            % map the created values onto correct indices
end

randfeature        = zeros(nshuffle, numel(featuredatorig))+nan;
randfeature(:,sel) = tmprand;

end

