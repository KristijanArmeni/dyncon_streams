%% extract the high frequency data for each story
clear all;

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's10'};
for k = 1:numel(subjects)
  subject = streams_subjinfo(subjects{k});
  for m = 1:numel(subject.audiofile)
    audiofile = subject.audiofile{m};
    [p,f,e]   = fileparts(audiofile);
    savefile  = fullfile('/home/language/jansch/projects/streams/data/preproc/',[subject.name,'_',f,'_data_highfreq_100Hz']);

    qsubfeval('streams_extract_data',subject,'audiofile',audiofile,'hpfreq',60,'dftfreq',[99 101;149 151;199 201],'fsample',100,'savefile',savefile,'timreq',10*60,'memreq',12*1024^3);
  end
end
