function [ stat ] = streams_stats_test(feature, freqband, varargin)
% 
% Return the statistics for a particular frequency band and feature.
% 
% Use as:
%     function [ stat ] = streams_stats_test(feature, freqband, varargin)
%       
% Input arguments;
%     feature   = string, specifying the feature to use (perplexity, entropy, etc.)
%     freqband  = frequency band to use ( eg. '8-12', '12-18' )
%     
% Optional arguments:
%     'demeaned' - specifies whether to demaen the xcorrelation values across time
%     'plot'     - will also output plots 
% 

path = '/home/language/jansch/projects/streams/data/crosscorrelation_planar/';

% list the files
d = dir(fullfile(path, sprintf('*%s*%s*', feature, freqband)));

% init the array (needs to be
%s = cell(1, numel(d));

% load the xcorrelations for a particular feature and frequency and store
% it in a cell-array
for k = 1:numel(d)
  load(fullfile(path, d(k).name));
  if ismember(varargin, 'demeaned')
    stat.stat = stat.stat - repmat(mean(stat.stat,2),[1 numel(stat.time)]);
  end
  s{k} = stat;
end

%s2 = cell(numel(s));

% duplicate the data, but replace the xcorr values with 0's
for k = 1:numel(s)
  s2{k} = s{k};
  s2{k}.stat(:) = 0;
end
N = numel(s);

load('/home/common/matlab/fieldtrip/template/neighbours/ctf275_neighb');

% do the statistical test
cfg = [];
cfg.method = 'montecarlo';
cfg.parameter = 'stat';
cfg.numrandomization = 1000;
cfg.statistic = 'depsamplesT';
cfg.design = [ones(1,N) ones(1,N)*2;1:N 1:N];
cfg.ivar   = 1;
cfg.uvar   = 2;
cfg.correctm = 'cluster';
cfg.neighbours = neighbours;
stat = ft_timelockstatistics(cfg, s{:}, s2{:});

% if ismember(varargin, 'demeaned')
%   filename = sprintf('streams_stats_%s_%s_demeaned', feature, freqband);
% else
%   filename = sprintf('streams_stats_%s_%s', feature, freqband);
% end
% 
% save(filename, 'stat');

% if ismember(varargin, 'plot')
%   cfgp = [];
%   cfgp.layout = 'CTF275.lay';
%   cfgp.parameter='stat';
%   figure;ft_multiplotER(cfgp,stat);
%   cfgp.parameter='prob';
%   figure;ft_multiplotER(cfgp,stat);
% end






