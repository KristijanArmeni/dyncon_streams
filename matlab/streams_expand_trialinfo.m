function trialinfo = streams_expand_trialinfo(data, varargin)

% STREAMS_EXPAND_TRIALINFO expands the trialinfo field in the data in order
% to contain more information, extracting information from the features

feature = ft_getopt(varargin, 'feature');

channelid_word = match_str(data.label, 'word_');
%channelid_sent = match_str(data.label, 'sent_');
channelid_feat = match_str(data.label, feature);

trialinfo = data.trialinfo;

% audio_id = unique(data.trialinfo(:,1)); % assume hard coded first column
% for k = 1:numel(audio_id)
%   %tmp     = subject.audiofile{subject.trl(:,4)==audio_id(k)};
%   %[p,f,e] = fileparts(tmp);
%   %streams = combine_donders_textgrid(f);
% 
%   sel = find(trialinfo(:,1)==audio_id(k));
%   for m = sel(:)'
%     word = data.trial{m}(channelid_word,:);
%     sent = data.trial{m}(channelid_sent,:);
%     w_s  = sent.*100 + word; % make a vector with unique values, and 0 where there's no word indicated
%     w_s(mod(w_s,100)==0) = 0;
%     
%     feat = data.trial{m}(channelid_feat,:);
%     
%   end
%   
% end

F = cell(numel(data.trial),1);
n = 0;
for k = 1:numel(data.trial)
  word = data.trial{k}(channelid_word,:);
  %sent = data.trial{k}(channelid_sent,:);
  %w_s  = sent.*100 + word; % make a vector with unique values, and 0 where there's no word indicated
  %w_s(mod(w_s,100)==0) = 0;
  idx  = diff([-10 word])~=0;
  
  feat = data.trial{k}(channelid_feat,:);
  F{k} = feat(idx);
  n    = max(n, numel(F{k}));
end

ncol = size(trialinfo,2);
trialinfo(:, ncol+(1:n)) = nan;
for k = 1:numel(data.trial)
  trialinfo(k, ncol + (1:numel(F{k}))) = F{k};
end
