clear all;

 features = {'perplexity', 'entropy', 'gra_perpl', 'pho_perpl', 'depind'};
 bpfreqs  = {'04-08', '08-12', '12-18', '18-24', '24-40', '40-60', '70-90'};
 
for i = 1:numel(features)
  for j = 1:numel(bpfreqs)
    %run and save stats for the demeaned 
    stats = streams_stats_test(features{i}, bpfreqs{j}, 'demeaned');
    save(sprintf('/home/language/miccza/INTERNSHIP/matfiles_stats_corrected/stats_corrected_%s_%s_demeaned', features{i}, bpfreqs{j}), 'stats');

    %run and save stats for the demeaned 
    stats = streams_stats_test(features{i}, bpfreqs{j});
    save(sprintf('/home/language/miccza/INTERNSHIP/matfiles_stats_corrected/stats_corrected_%s_%s', features{i}, bpfreqs{j}), 'stats');

  end
end

%% Should run parallel jobs but gives the following error instead:

% d function or variable "hascrsspctrm".
% 
% Error in prepare_timefreq_data (line 99)
% if hascrsspctrm
%   
%   Error in statistics_wrapper (line 235)
%     [cfg, data] = prepare_timefreq_data(cfg, varargin{:});
%     
%     Error in ft_timelockstatistics (line 108)
%     [stat, cfg] = statistics_wrapper(cfg, varargin{:});
%     
%     Error in streams_stats_test (line 57)
%     stat = ft_timelockstatistics(cfg, s{:}, s2{:});
%     
%     Error in fexec (line 156)
%         feval(fname, argin{:});
%         
%         Error in qsubexec (line 89)
%           [argout, optout] = fexec(argin, optin);
% 
% ==========================================================

% memreq = 4*1024^3;
% timreq = 10*60;
% 
% [a, b] = ndgrid(1:numel(features),1:numel(bpfreqs));
% perms_of_f     = features(a(:))';
% perms_of_b     = bpfreqs(b(:))';
% 
% featurekey = repmat({'feature'}, [numel(perms_of_f), 1]);
% bandkey    = repmat({'freqband'}, [numel(perms_of_b), 1]);
% 
% qsubcellfun('streams_stats_test', featurekey, perms_of_f, bandkey, perms_of_b, 'memreq', memreq, 'timreq', timreq);


