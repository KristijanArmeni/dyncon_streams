clear all;

subjects = streams_subjinfo({'s02' 's03' 's04' 's05' 's07' 's10'});
bpfreqs  = [4 8;8 12;12 18;18 24;24 40;40 60;70 90];

for k = 1:numel(subjects)
  subject    = subjects(k);
  audiofiles = subject.audiofile;
  for m = 1:numel(audiofiles)
    audiofile = audiofiles{m};
    tmp = strfind(audiofile, 'fn');
    audiofile = audiofile(tmp+(0:7));
    for p = 1:size(bpfreqs,1)
      bpfreq    = bpfreqs(p,:);
      feature   = 'entropy';
      try
        fprintf('computing cross-correlation for bandlimited power at %d-%dHz, for audio fragment %s in subject %s\n',bpfreq(1),bpfreq(2),audiofile,subject.name);
        [~, ~, c, lag] = streams_blp_feature(subject, 'audiofile', audiofile, 'bpfreq', bpfreq, 'feature', feature);
        fname = fullfile('/home/language/jansch/projects/streams/data',[subject.name,'_',audiofile,'_',feature,'_xcorr','_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d')]);
        save(fname, 'c', 'lag');
      end
    end
  end
end