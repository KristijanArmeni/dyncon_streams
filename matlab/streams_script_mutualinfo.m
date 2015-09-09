%% script to compute mutual information for perplexity on highfreq Hz filtered amplitude envelopes
clear all;

datadir1 = '/home/language/jansch/projects/streams/data/preproc';
datadir2 = '/home/language/jansch/projects/streams/data/featuredata';
datadir3 = '/home/language/jansch/projects/streams/data/mutualinformation';
d1 = dir(fullfile(datadir1,'s*fn*highfreq*100Hz.mat'));
d2 = dir(fullfile(datadir2,'s*fn*featuredata*'));

for k = 1:numel(d1)
  n1{k,1} = d1(k).name(1:12);
end
for k = 1:numel(d2)
  n2{k,1} = d2(k).name(1:12);
end
[ix1,ix2]=match_str(n1,n2);
d1=d1(ix1);
d2=d2(ix2);

for k = 1:numel(d1)
  f1{k} = fullfile(datadir1,d1(k).name);
  f2{k} = fullfile(datadir2,d2(k).name);
%  s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m','z_mi_perplexity_all.m');
  s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m','z_mi_perplexity.m');
end


%for k = 1:numel(s)
%  existfile(k) = exist(s{k},'file');
%end
%f1 = f1(~existfile);
%f2 = f2(~existfile);
%s  = s(~existfile);

%load(fullfile(datadir3,'memory_streams_blp_feature_10rand.mat'));
%M(~isfinite(M))=9*1024^3;
for k = 1:numel(f1)
%  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','perplexity','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','perplexity','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);
  s{k} = strrep(s{k},'perplexity','entropy');
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','entropy','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);
  s{k} = strrep(s{k},'entropy','depind');
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','depind','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);
  s{k} = strrep(s{k},'depind','gra_perpl');
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','gra_perpl','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);
  s{k} = strrep(s{k},'gra_perpl','pho_perpl');
  qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','pho_perpl','lag',[-1000:50:-250 -50:2:50 250:50:1000],'savefile',s{k},'nshuffle',0,'memreq',12*1024^3,'timreq',15*60*60);

end


% %% script to compute mutual information for perplexity on 12-18 Hz filtered amplitude envelopes
% 
% datadir1 = '/home/language/jansch/projects/streams/data/preproc';
% datadir2 = '/home/language/jansch/projects/streams/data/featuredata';
% datadir3 = '/home/language/jansch/projects/streams/data/mutualinformation';
% d1 = dir(fullfile(datadir1,'s*fn*12-18*100Hz.mat'));
% d2 = dir(fullfile(datadir2,'s*fn*featuredata*'));
% 
% for k = 1:numel(d1)
%   f1{k} = fullfile(datadir1,d1(k).name);
%   f2{k} = fullfile(datadir2,d2(k).name);
% %  s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m','z_mi_perplexity_all.m');
%   s{k}  = strrep(fullfile(datadir3,d1(k).name),'z.m','z_mi_perplexity_source.m');
% 
% end
% 
% % for k = 1:numel(s)
% %   existfile(k) = exist(s{k},'file');
% % end
% % f1 = f1(~existfile);
% % f2 = f2(~existfile);
% % s  = s(~existfile);
% 
% %load(fullfile(datadir3,'memory_streams_blp_feature_10rand.mat'));
% %M(~isfinite(M))=9*1024^3;
% for k = 1:numel(f1)
%   %qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','perplexity','savefile',s{k},'memreq',12*1024^3,'timreq',180*60);
%   qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','perplexity','dosource',1,'chunk',100,'lag',10,'savefile',s{k},'nshuffle',40,'memreq',12*1024^3,'timreq',15*60*60);
% 
%   %qsubfeval('streams_blp_feature',f1{k},f2{k},'feature','perplexity','length',45,'overlap',0.5,'savefile',s{k},'memreq',8*1024^3,'timreq',15*60)
% end
