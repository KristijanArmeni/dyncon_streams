clear all;

subjects = {'s02' 's03' 's04' 's05' 's07' 's10'};

for i=1:numel(subjects)
  subjectlist{i} = streams_subjinfo();
end


% subjects = streams_subjinfo({'s02' 's03' 's04' 's05' 's07' 's10'});
% bpfreqs  = [4 8;8 12;12 18;18 24;24 40;40 60;70 90];
% features = {'perplexity' 'entropy'}; % fill in the other ones here


subjectlist = cell(0,1);
audiolist   = cell(0,1);
bplist      = cell(0,1);
featurelist = cell(0,1);
savelist    = cell(0,1);


% memreq = 4*1024^3;
% timreq = 5*60;
% qsubcellfun('streams_blp_feature', subjectlist, audiokey, audiolist, bpfreqkey, bplist, featurekey, featurelist, savekey, savelist, 'memreq', memreq, 'timreq', timreq);



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

