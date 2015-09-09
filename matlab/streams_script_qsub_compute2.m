%% run it
clear all;

subjects = streams_subjinfo({'s09'});% 's02' 's03' 's04' 's05' 's07' 's08' 's10'});
%subjects = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's10'});
bpfreqs  = [12 18];

subjectlist = cell(0,1);
audiolist   = cell(0,1);
bplist      = cell(0,1);
savelist    = cell(0,1);

cnt = 0;
for j = 1:numel(subjects)
  subject    = subjects(j);
  audiofiles = subject.audiofile;
  for k = 1:numel(audiofiles)
    audiofile = audiofiles{k};
    tmp       = strfind(audiofile, 'fn');
    audiofile = audiofile(tmp+(0:7));
    for m = 1:size(bpfreqs,1)
      bpfreq = bpfreqs(m,:);

        subjectlist{end+1} = subject;
        audiolist{end+1}   = audiofile;
        bplist{end+1}      = bpfreq;
        savelist{end+1}    = fullfile('/home/language/jansch/projects/streams/data/preproc/',[subject.name,'_',audiofile,'_data_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'),'_100Hz']);
      
    end
  end
end

% for k = 1:numel(savelist)
%   existfile(k,1) = streams_existfile([savelist{k},'.mat'],'');
% end
% subjectlist = subjectlist(existfile==0);  
% audiolist   = audiolist(existfile==0);  
% bplist      = bplist(existfile==0);  
% savelist    = savelist(existfile==0);  

njob       = numel(subjectlist);
audiokey   = repmat({'audiofile'}, [njob 1]);
bpfreqkey  = repmat({'bpfreq'},    [njob 1]);   
savekey    = repmat({'savefile'},  [njob 1]);   

  
memreq = 9*1024^3;
timreq = 15*60;
qsubcellfun('streams_extract_data', subjectlist, audiokey, audiolist, bpfreqkey, bplist, savekey, savelist, 'memreq', memreq, 'timreq', timreq);
