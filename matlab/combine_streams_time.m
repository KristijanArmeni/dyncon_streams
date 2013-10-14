function [trial, samples, indx] = combine_streams_time(streams, time, parameter)

% COMBINE_STREAMS_TIME projects streams information onto a time-axis and
% returns a vector that contains a 'pseudo-channel'.
%
% Use as
%   [trial, words] = combine_streams_time(streams, time, parameter)
%
% Input arguments:
%   streams = a streams structure, that inclused timing information 
%   time    = 1xN vector that specifies the time axis
%   parameter = string, the parameter whose value is projected.
%
% Output arguments:
%   trial   = 1xN vector that contains the value of parameter on the time
%                points where the corresponding word was 'present'
%   indx    = Mx1 vector with indices that relate to the entries in the
%                streams struct-array (not all elements correspond to words
%                and have [nan nan] as times.
%   samples = Mx2 matrix containing the begin and end sample of the
%                corresponding entry.
%
% See also: COMBINE_STREAMS_AWD, READ_AWD and READ_STREAMDAT_V1

trial   = zeros(size(time))+nan;
indx    = zeros(0,1);
samples = zeros(0,2);
for k = 1:numel(streams)
  if isfinite(streams(k).times(1))
    begsmp  = nearest(time, streams(k).times(1));
    endsmp  = nearest(time, streams(k).times(2));
    
    indx    = cat(1, indx,    k);
    samples = cat(1, samples, [begsmp endsmp]);
    trial(begsmp:endsmp) = streams(k).(parameter);
  end
end