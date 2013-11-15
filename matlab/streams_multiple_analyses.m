features = {'perplexity', 'entropy', 'gra_perpl', 'pho_perpl', 'depind'};
bpfreqs  = {'04-08', '08-12', '12-18', '18-24', '24-40', '40-60', '70-90'};

index = 1;
for i = 1:numel(features)
  for j = 1:numel(bpfreqs)
    %run and save stats for the demeaned 
    stats = streams_stats_test(features{i}, bpfreqs{j}, 'demeaned');
    save(sprintf('/home/language/miccza/INTERNSHIP/matfiles_stats/stats_%s_%s_demeaned', features{i}, bpfreqs{j}), 'stats');

    %run and save stats for the demeaned 
    stats = streams_stats_test(features{i}, bpfreqs{j});
    save(sprintf('/home/language/miccza/INTERNSHIP/matfiles_stats/stats_%s_%s', features{i}, bpfreqs{j}), 'stats');

    index = index + 1;
  end
end


% memreq = 7*1024^3;
% timreq = 10*60;
% 
% [a, b] = ndgrid(1:numel(features),1:numel(bpfreqs));
% perm_f     = features(a(:));
% perm_b     = bpfreqs(b(:));
% 
% featurekey = repmat({'feature'}, [numel(perm_f), 1]);
% freqkey    = repmat({'freqband'}, [numel(perm_f), 1]);
% 
% qsubcellfun('streams_stats_test', featurekey, perm_f, freqkey, perm_b, 'memreq', memreq, 'timreq', timreq);


