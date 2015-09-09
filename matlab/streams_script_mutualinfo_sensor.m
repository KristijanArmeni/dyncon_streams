%% script to compute mutual information for perplexity on 12-18 Hz filtered amplitude envelopes

datadir1 = '/home/language/jansch/projects/streams/data/preproc';
datadir2 = '/home/language/jansch/projects/streams/data/featuredata';
datadir3 = '/home/language/jansch/projects/streams/data/mutualinformation';
d1 = dir(fullfile(datadir1,'s*fn*12-18*z.mat'));
d2 = dir(fullfile(datadir2,'s*fn*featuredata*'));

feature = 'depind';
for k = 1:numel(d1)
  f1{k} = fullfile(datadir1,d1(k).name);
  f2{k} = fullfile(datadir2,d2(k).name);
%  s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m','z_mi_perplexity_all.m');
  s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m',['z_mi_',feature,'_sensor.m']);

end

% for k = 1:numel(s)
%   existfile(k) = exist(s{k},'file');
% end
% f1 = f1(~existfile);
% f2 = f2(~existfile);
% s  = s(~existfile);

%load(fullfile(datadir3,'memory_streams_blp_feature_10rand.mat'));
%M(~isfinite(M))=9*1024^3;
M = 6*1024^3*ones(numel(f1),1);
for k = 1:numel(f1)
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature',feature,'chunk',100,'lag',-160:10:160,'savefile',s{k},'nshuffle',10,'memreq',M(k)*1.2,'timreq',3*60*60);
end
