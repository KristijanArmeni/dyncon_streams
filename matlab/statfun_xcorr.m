function [stat, lag] = statfun_xcorr(cfg, dat, design)

% NEW IMPLEMENTATION OCT 2012

% this gives slightly different results from xcorr with normalization
% option = 'coeff'

% where the lags are negative, dat is preceding design,
% where the lags are positive, design is preceding dat.

if isempty(cfg),         cfg     = [];                               end
if ~isfield(cfg, 'lag'), cfg.lag = -(size(dat,2)-1):(size(dat,2)-1); end

[nvox, nsmp] = size(dat);
nlag         = numel(cfg.lag);

stat = zeros(nvox, nlag);

% demean
mdat    = nanmean(dat,2);
mdesign = nanmean(design,2);
dat     = dat    - mdat(:,ones(nsmp,1));
design  = design - mdesign(1);

% the denominator is the product of the standard deviations
denom   = sqrt(nansum(dat.^2,2).*nansum(design(1,:).^2,2));
sel     = isfinite(design(1,:));

for k = 1:nlag
  lag = cfg.lag(k);
  if lag<0,
    overlap1 = [sel false(1,-lag)]; 
    overlap2 = [false(1,-lag) sel]; 
    overlap  = find(overlap1 & overlap2);
  else
    overlap1 = [false(1,lag) sel]; 
    overlap2 = [sel false(1,lag)]; 
    overlap  = find(overlap1 & overlap2); 
  end
  %noverlap = numel(overlap);
  if lag<0,
    tmp1    = dat(:, overlap+lag);
    tmp2    = design(1, overlap);
  else
    tmp1    = dat(:, overlap);
    tmp2    = design(1, overlap-lag);
  end
  num       = (tmp1*tmp2');
  stat(:,k) = num./denom;
end

lag = cfg.lag;

