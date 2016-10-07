%% STREAMS ANALYSIS PIPELINE


%% AUDITORY COMPONENT ANALYSIS
clear all

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};

inp_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';

cd(inp_dir);

jobid_array_tlck = cell(1, numel(subjects));

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    load(sprintf('%s_data.mat', subject.name));
    
    jobid_array_tlck{k} = qsubfeval('qsub_streams_dss_auditory', data, subject, ...
                                    'memreq', 1024^3 * 12,...
                                    'timreq', 60*60,...
                                    'batchid', 'streams_tlck');
end

%% CREATE MODEL OUTPUT

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
features = {'entropy', 'perplexity'};

if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    
    qsubfeval('qsub_streams_getfeatures', subject, features, ...
                                        'memreq', 1024^3 * 8,...
                                        'timreq', 45*60,...
                                        'batchid', 'streams_features');
end



%% AUDIOCORTICO MI

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
bpfreqs   = [01 03];

%Subject, story and freq loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('qsub_streams_bpl_audio', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 60*60,...
                      'batchid', 'streams_feature');
    end
    
  end

end

% Loops for computation with legacy code
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('qsub_streams_bpl_feature_legacy', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 60*60,...
                      'batchid', 'streams_feature');
    end
    
  end

end

%% BAND-PASS-LIMITED DATA ~ FEATURE ANALYSIS

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end
[data_files, feature_files] = streams_datalist('12-18');
datadir       = '/home/language/jansch/projects/streams/data/preproc';
featuredir    = '/home/language/jansch/projects/streams/data/featuredata';

addpath(datadir)
addpath(featuredir)

for k = 1:numel(data_files)
    
    data = data_files{k};
    data = fullfile(datadir, data);
    featuredata = feature_files{k};
    featuredata = fullfile(featuredir, featuredata);
    subject = streams_subjinfo(data_files{k}(1:3));
    
    qsubfeval('qsub_streams_bpl_feature', subject, data, featuredata, ...
                      'memreq', 1024^3 * 4,...
                      'timreq', 420*60,...
                      'batchid', 'streams_feature');

end

unfinished = {4 5 48};

% for killed jobs
for k = 1:numel(unfinished)
    
    current_file = unfinished{k};
    
    data = data_files{current_file};
    data = fullfile(datadir, data);
    
    featuredata = feature_files{current_file};
    featuredata = fullfile(featuredir, featuredata);
    
    subject = streams_subjinfo(data_files{current_file}(1:3));
    
    qsubfeval('qsub_streams_bpl_feature', subject, data, featuredata, ...
                      'memreq', 1024^3 * 4,...
                      'timreq', 360*60,...
                      'batchid', 'streams_feature');

end

%% PREPROCESSING + BAND-PASS-LIMITED DATA ~ FEATURE ANALYSIS

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
bpfreqs   = [08 12; 13 30; 30 90];

for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
 		
    for h = 1:size(bpfreqs)
    bpfreq = bpfreqs(h,:);  
    
    qsubfeval('qsub_streams_bpl_feature2', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 480*60,...
                      'batchid', 'streams_feature');
    
    end
    
  end

end
