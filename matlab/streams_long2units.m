function [featuredat_unit, dat_unit] = streams_long2units(featuredat, dat, meanflag)

if nargin<3
  meanflag = true;
end

sel        = isfinite(featuredat);
featuredat = featuredat(sel);
dat        = dat(:,sel);
clear sel;

ramp_up   = find(diff([-inf featuredat])>0);
ramp_down = find(diff([-inf featuredat])<0);
ramp_all  = sort([ramp_up ramp_down]);

% the ramp_all variable contains the start indices of the plateaus, which
% run until the next index, minus 1
ramp_all(end+1) = numel(featuredat)+1;

featuredat_unit = nan+zeros(1,numel(ramp_all)-1);
dat_unit        = nan+zeros(size(dat,1),numel(ramp_all)-1);
for k = 1:numel(ramp_all)-1
  featuredat_unit(1,k) = mean(featuredat(ramp_all(k):(ramp_all(k+1)-1)));
  if meanflag
    dat_unit(:,k) = nanmean(dat(:,ramp_all(k):(ramp_all(k+1)-1)),2);
  else
    dat_unit(:,k) = dat(:,ramp_all(k));
  end
end