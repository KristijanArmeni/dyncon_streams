function [p_ind, p_val, n_peaks] = streams_findpeaks(audiofile, p_amp, p_dist)
% STREAMS_FINDPEAKS detects peaks in the audio signal calling peakdetect2()
% 
% INPUT ARGUMENTS

%detect peaks in all trials
p_ind = cell(1,numel(audiofile));
p_val = cell(1,numel(audiofile));

for kk = 1:numel(audiofile)

  % store indices and corresponding values that go above value in p_amp
  [p_ind{1, kk}, p_val{1, kk}] = peakdetect2(audiofile{kk}, p_amp, p_dist);
   p_ind{1, kk} = p_ind{1, kk}(:);

end

n_peaks = sum(cellfun(@numel, p_ind));

fprintf('\nDetected %d peaks in %d trials.\n', n_peaks, numel(audiofile));
