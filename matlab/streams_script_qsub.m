%% run it
clear all;

subjects = streams_subjinfo({'s02' 's03' 's04' 's05' 's07' 's10'});
bpfreqs  = [4 8;8 12;12 18;18 24;24 40;40 60;70 90];
features = {'perplexity' 'entropy'}; % fill in the other ones here

subjectlist = cell(0,1);
audiolist   = cell(0,1);
bplist      = cell(0,1);
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
    for m = 1:size(bpfreqs,1)
      bpfreq = bpfreqs(m,:);
      for p = 1:numel(features)
        feature = features{p};

        subjectlist{end+1} = subject;
        audiolist{end+1}   = audiofile;
        bplist{end+1}      = bpfreq;
        featurelist{end+1} = feature;
        %savelist{end+1}    = fullfile('/home/language/jansch/projects/streams/data',[subject.name,'_',audiofile,'_',feature,'_xcorr','_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d')]);
        savelist{end+1}    = fullfile('/home/language/jansch/projects/streams/data',[subject.name,'_',audiofile,'_',feature,'_xcorr','_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'),'_planar']);
      end
    end
  end
end
njob       = numel(subjectlist);
audiokey   = repmat({'audiofile'}, [njob 1]);
bpfreqkey  = repmat({'bpfreq'},    [njob 1]);   
featurekey = repmat({'feature'},   [njob 1]);   
savekey    = repmat({'savefile'},  [njob 1]);   

memreq = 6*1024^3;
timreq = 10*60;
qsubcellfun('streams_blp_feature', subjectlist, audiokey, audiolist, bpfreqkey, bplist, featurekey, featurelist, savekey, savelist, 'memreq', memreq, 'timreq', timreq);



% for k = 1:numel(subjects)
%   subject    = subjects(k);
%   audiofiles = subject.audiofile;
%   for m = 1:numel(audiofiles)
%     audiofile = audiofiles{m};
%     tmp = strfind(audiofile, 'fn'); 
%     audiofile = audiofile(tmp+(0:7));
%     for p = 1:size(bpfreqs,1)
%       bpfreq    = bpfreqs(p,:);
%       feature   = 'entropy';
%       try,
%         fprintf('computing cross-correlation for bandlimited power at %d-%dHz, for audio fragment %s in subject %s\n',bpfreq(1),bpfreq(2),audiofile,subject.name);
%         [~, ~, stat] = streams_blp_feature(subject, 'audiofile', audiofile, 'bpfreq', bpfreq, 'feature', feature);
%         fname = fullfile('/home/language/jansch/projects/streams/data',[subject.name,'_',audiofile,'_',feature,'_xcorr','_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d')]);
%         save(fname, 'stat');
%       end
%     end
%   end
% end

