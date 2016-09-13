
selaudio = {'fn001078'
    'fn001155'
    'fn001293'
    'fn001294'
    'fn001443'
    'fn001481'
    'fn001498'
    'fn001172'};

words_perstory = cell(numel(selaudio, 1));
for m = 1:numel(selaudio)
  
  dondersfile  = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{m},[selaudio{m},'.donders']);
  textgridfile = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{m},[selaudio{m},'.TextGrid']);
%   if m==1,
  words_perstory{m,:} = combine_donders_textgrid(dondersfile, textgridfile);
  [words_perstory{m}(:).audiofile] = deal(selaudio(m));
  
  % Count words
  word_count = 0;
  duration = zeros(1, numel(words_perstory{m}));
  
  for i = 1:numel(words_perstory{m})
  
    if ~isempty(words_perstory{m}(i).start_time) && ~isempty(words_perstory{m}(i).end_time);
      word_count = word_count + 1;
      [words_perstory{m}(i).duration] = words_perstory{m}(i).end_time - words_perstory{m}(i).start_time; % compute word length in seconds
      duration(1, i) = words_perstory{m}(i).duration;
    else
      [words_perstory{m}(i).duration] = NaN; % 
      duration(1, i) = NaN;
    end
    
  end
  
  [words_perstory{m}(:).numwords] = deal(word_count);
  [words_perstory{m}(:).meanduration] = deal(nanmean(duration));
  [words_perstory{m}(:).sdduration] = deal(nanstd(duration));
  [words_perstory{m}(:).medduration] = deal(nanmedian(duration));
  [words_perstory{m}(:).maxduration] = deal(max(duration));
  [words_perstory{m}(:).minduration] = deal(min(duration));
  [words_perstory{m}(:).rngduration] = deal(range(duration));
    
%   combineddata_perstory{m,:}.audiofile = selaudio(m);
%   else
%     combineddata = cat(1, combineddata, combine_donders_textgrid(dondersfile, textgridfile));
%   end
end

for i = 1:8
  
  display(sprintf('story nr %d', i));
  display(sprintf('mean is %0.5f', words_perstory{i}(end).meanduration));
  display(sprintf('std is %0.5f', words_perstory{i}(end).sdduration));
  display(sprintf('median is %0.5f', words_perstory{i}(end).medduration));
  display(sprintf('max is %0.5f', words_perstory{i}(end).maxduration))
  display(sprintf('min is %0.5f', words_perstory{i}(end).minduration));
  display(sprintf('range is %0.5f', words_perstory{i}(end).rngduration));
  
end
  
  % combineddata is a struct array, with one entry for each word.
  % sentence and word counts are 0-based
  
  wordid = zeros(numel(combineddata),1);
  sentid = wordid;
  ent = wordid;
  for k = 1:numel(combineddata)
      wordid(k,1) = combineddata(k).word_;
      sentid(k,1) = combineddata(k).sent_;
      ent(k,1) = combineddata(k).entropy;
      perp(k,1) = combineddata(k).perplexity;
  end
  
  hist(ent, 20)
  set(gca,'xscale','log')
  
  ix = (-0.5:(ceil(max(ent))+0.5));
  
  uwordid = unique(wordid);
  n = zeros(numel(ix),numel(uwordid));
  for k = 1:numel(uwordid)
    n(:,k) = histc(ent(wordid==uwordid(k)),ix);
  end
  
% Compute word duration
combineddata.duration = zeros(1, numel(combineddata));

  
  for k = 1:numel(combineddata)
      
      if isempty(combineddata(k).start_time) && isempty(combineddata(k).start_time)
          combineddata(k).duration = nan; 
      else
          combineddata(k).duration = combineddata(k).end_time - combineddata(k).start_time; % compute word length in seconds
      end
      
  end 
  
  % Compute word duration
words = zeros(1, numel(combineddata));

  
  for k = 1:numel(combineddata)
      
      if isempty(combineddata(k).start_time) && isempty(combineddata(k).start_time)
          combineddata(k).duration = nan; 
      else
          combineddata(k).duration = combineddata(k).end_time - combineddata(k).start_time; % compute word length in seconds
      end
      
  end 
  
%   words_.label = {'word_timing'; 'entropy'; 'logprob'};
%   words_.trial = words;
%   words_.dimord = 'chan_time';
  
figure; scatter(words(1,:), words(3,:))
words2 = words';

figure; scatter(combineddata(:).duration, combineddata(:).entropy);
  
wlenMi = ft_connectivity_mutualinformation(words, 'refind', 1);
wlenCorr = corrcoef(words2, 'rows', 'complete');