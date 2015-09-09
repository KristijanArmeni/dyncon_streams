function [indx] = streams_featuredat2wordindx(featuredat)

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

indxall = zeros(size(featuredatorig))+nan;
indxall(sel) = indx;

indx = indxall;clear indxall;
