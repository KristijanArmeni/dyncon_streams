function [p, begsmp, endsmp] = peaks2continuous(p, nsmp, presmp, postsmp)

% convert cell-array with peak indices into a vector, where the indices
% are adjusted according to the nsmp per trial, and the begin and endsamples
% respect the trial boundary.
% 
% Use as
%   [p, begsmp, endsmp] = peaks2continuous(p, sampleinfo, presmp, postsmp) 

ix = zeros(0,1);
iy = zeros(0,1);
for k = 1:numel(p)
  ix = [ix; k.*ones(numel(p{k}),1)];
  iy = [iy; p{k}(:)];
end

if numel(presmp)==1
  presmp = repmat(presmp, [numel(ix) 1]);
elseif numel(presmp)==numel(ix)
  % ok
else
  error('number of presmp-values should either be equal to the number of segments, or 1');
end

if numel(postsmp)==1
  postsmp = repmat(postsmp, [numel(ix) 1]);
elseif numel(postsmp)==numel(ix)
  % ok
else
  error('number of presmp-values should either be equal to the number of segments, or 1');
end

csmp   = cumsum([0 nsmp(:)']);
begsmp = zeros(numel(ix),1);
endsmp = zeros(numel(ix),1);
for k = 1:numel(ix)
  begsmp(k,1) = csmp(ix(k)) + max(iy(k)-presmp(k),  1);
  endsmp(k,1) = csmp(ix(k)) + min(iy(k)+postsmp(k), nsmp(ix(k)));
  iy(k)       = csmp(ix(k)) + iy(k);
end
p = iy; 
