function [p, v] = peakdetect2(dat, val, mindist)

% PEAKDETECT2 detects peaks above a certain threshold in single-channel data
%
% Use as
%   [pindx, pval] = peakdetect(signal, min, mindist)
%
% mindist is optional, default is 1
%
% See also PEAKDETECT, PEAKDETECT3

% Copyright (C) 2000, Robert Oostenveld
%
% $Log: peakdetect2.m,v $
% Revision 1.3  2006/01/11 17:24:03  roboos
% made peakdetect and peakdetect2 functions more consistent with peakdetect3, also improved documentation
%
% Revision 1.2  2003/03/17 10:37:29  roberto
% improved general help comments and added copyrights
%

if nargin<3
  mindist=1;
end

i = find(dat>val);
m = dat(i);
if ~isempty(i)
  d = [diff(i) inf];
else
  d = diff(i);
end
jump = (d>mindist);
p = [];

sect=1;
while sect<=length(d)
  if jump(sect)
    p = [p i(sect)];
  else
    s = zeros(1,0);
    while sect<=length(d) && ~jump(sect)  
      s = cat(2,s,sect);
      sect = sect + 1;
    end
    [lm, li] = max(m(s));
    p = cat(2,p,i(s(li)));
  end
  sect = sect+1;
end

if nargout>1
  v = dat(p);
end

