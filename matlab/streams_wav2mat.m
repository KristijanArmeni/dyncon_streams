function data = streams_wav2mat(filename)

% STREAMS_WAV2MAT does some processing on a named wav-file.
% These processing steps consist of:
%   - The creation of a Hilbert envelope version of the signal, using the strategy
%     described in Joachim's 2013 PLoS biology paper.
%   - Downsampling of the data to 1200 Hz sampling rate.
%   - Addition of the feature data
%
% Use as
%   audio = streams_wav2mat(filename)
%
% Input argument
%   filename = string, pointing to a wav-file
%   
% Output argument
%   audio = structure, fieldtrip-style, containing the data

[y,fs]         = wavread(filename);

% Do the envelope processing on the high temporal resolution data
addpath('/home/language/jansch/matlab/toolboxes/ChimeraSoftware');
n   = 10;
fco = equal_xbm_bands(100, 10000, n);
b   = quad_filt_bank(fco, fs);

z = zeros(size(y,1),size(b,2));
label = cell(size(b,2),1);
for m = 1:size(b,2)
  z(:,m) = abs(fftfilt(b(:,m), y(:,1)));
  label{m} = sprintf('audio_%d-%d',round(fco(m)),round(fco(m+1)));
end

% Create a Fieldtrip-style structure
data       = [];
data.trial = {[y(:,1)';z';mean(z,2)']};
data.time  = {(0:size(data.trial{1},2)-1)./fs};
data.label = [{'audio'};label;{'audio_avg'}];
data.fsample = fs;

% Resample to 1200 Hz
cfg = [];
cfg.resamplefs = 1200;
data = ft_resampledata(cfg, data);

% Deal with the features
[p,f,e]      = fileparts(filename);
dondersfile  = fullfile(p,[f,'.donders']);
textgridfile = fullfile(p,[f,'.TextGrid']);
combineddata = combine_donders_textgrid(dondersfile, textgridfile);

fnames = {'sent_';'word_';'depind';'logprob';'entropy';'perplexity';'gra_perpl';'pho_perpl'};
for k = 1:numel(fnames)
  [time, featurevector] = get_time_series(combineddata, fnames{k}, 1200);
  if k==1
    featuredata(numel(fnames), numel(featurevector))=0;
  end
  featuredata(k,:) = featurevector;
end
featuredata(:,end+1:numel(data.time{1})) = nan;
data.trial{1} = cat(1, data.trial{1},featuredata);
data.label    = cat(1, data.label, fnames);
data.textinfo = combineddata;
