
clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};


% Language: Subject, story loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
	tmp       = strfind(audiofile, 'fn');
	audiofile = audiofile(tmp+(0:7));
    
    qsubfeval('pipeline_streams_preprocessing_', subject, audiofile, ...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_features');
    
  end

end