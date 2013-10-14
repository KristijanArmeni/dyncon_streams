function streams = combine_streams_awd(streamsfile, awdfile)

% COMBINE_STREAMS_AWD combines the timing information from an *.awd file to
% the corresponding streams data.
%
% Use as
%   streamdata = combine_streams_awd(streamsfile, awdfile)  
%
% Input variables:
%   streamsfile = filename of a streamsfile
%   awdfile     = filename of the corresponding *.awd file containing timing information.
%
% Output variables:
%   streams     = data-structure that contains streams information in
%                 addition with timing information of the words.
%
% See also: READ_AWD and READ_STREAMDAT_V1

awd     = read_awd(awdfile);
%streams = read_streamdat_v1(streamsfile);
streams = read_donders(streamsfile);
if numel(awd)>1
  % assume the first
  awd = awd(1);
end

% add a times field to the streams structure
for k = 1:numel(streams)
  streams(k).times = zeros(1,2)+nan;
end

% match the words (chronologically) in the streams and awd lists
% use the awdlist as the template

awdlist     = awd.words;
streamslist = {streams.word}';
cnt         = 0;
for k = 1:numel(awdlist)
  if ~isempty(awdlist{k})
    % find the matching words
    sel = find(strcmp(awdlist{k}, streamslist));
    
    % remove the matches that have been matched before
    sel(sel<=cnt) = [];
    
    % take the first next match
    if ~isempty(sel)
      sel = sel(1);
  
      % add the timing info to the streams structure
      streams(sel).times = awd.times(k, :);
      
      % update the counter
      cnt = sel;
    else
    end
    
  else
    % there is nothing to be matched 
  end
end
