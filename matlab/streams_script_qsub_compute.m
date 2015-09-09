%% run it
clear all;

%subjects = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's10'});
subjects = streams_subjinfo({'s09'});
features = {'perplexity' 'entropy' 'depind' 'gra_perpl' 'pho_perpl'}; % fill in the other ones here;

subjectlist = cell(0,1);
audiolist   = cell(0,1);
featurelist = cell(0,1);
savelist    = cell(0,1);

cnt = 0;
for j = 1:numel(subjects)
  subject    = subjects(j);
  audiofiles = subject.audiofile;
  for k = 1:numel(audiofiles)
    audiofile = audiofiles{k};
    tmp       = strfind(audiofile, 'fn');
    audiofile = audiofile(tmp+(0:7));
    feature   = features;

    subjectlist{end+1} = subject;
    audiolist{end+1}   = audiofile;
    featurelist{end+1} = feature;
    savelist{end+1}    = fullfile('/home/language/jansch/projects/streams/data/featuredata/',[subject.name,'_',audiofile,'_featuredata_100Hz']);
  end
end

% for k = 1:numel(savelist)
%   existfile(k,1) = streams_existfile([savelist{k},'.mat'],'');
% end
% subjectlist = subjectlist(existfile==0);  
% audiolist   = audiolist(existfile==0);  
% featurelist = featurelist(existfile==0);  
% savelist    = savelist(existfile==0);  

njob       = numel(subjectlist);
audiokey   = repmat({'audiofile'}, [njob 1]);
featurekey = repmat({'feature'},   [njob 1]);   
savekey    = repmat({'savefile'},  [njob 1]);   

  
memreq = 2*1024^3;
timreq = 5*60;
qsubcellfun('streams_extract_feature', subjectlist, audiokey, audiolist, featurekey, featurelist, savekey, savelist, 'memreq', memreq, 'timreq', timreq);
