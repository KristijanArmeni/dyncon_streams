%% STREAMS ANALYSIS PIPELINE

clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

%% RAW DATA PREPROCESSING

audiodir = '/home/language/jansch/projects/streams/audio';
addpath(audiodir);
subjects = {'s05'};

% begin subject loop

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    
    jobid = qsubfeval('qsub_streams_preproc', subject, ...
                                'memreq', 1024^3 * 12, ...
                                'timreq', 60*60, ...
                                'batchid', 'streams_preproc');

end

[subject, data, audio] = qsubget(jobid);

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

%% WORD LENGTH ~ MODEL DISTRIBUTIONS

%trial loop
featuredata.single = featuredata.trial{1};
for i = 2:numel(featuredata.trial)
    
    featuredata.single = [featuredata.single featuredata.trial{i}];
    
end
    
posVal = featuredata.single(3, :);    % assign word position values
entVal = featuredata.single(1, :);    % assign entropy values

% create a vector of unique word position values for current trial
uniqueId = unique(posVal);    % get all the word position values
uniqueId(isnan(uniqueId)) = []; % exclude NaNs
if any(uniqueId == 0)           % exclude the zero
    uniqueId(1) = [];
end

% create a matrix with word order indices as rows
wMat = cell(size(uniqueId, 2), size(posVal, 2));

% word position loop
for j = 1:numel(uniqueId);

    % a boolean wMat struct with word position values in rows
    currInd = uniqueId(j);         % get current position value
    wMat{j} = posVal == currInd;

end

% create a cell array with word position x trials with entropy values in
% columns
if ~exist('wpos_ent', 'var');
    wpos_ent = cell(size(wMat, 1), 1);
end
for h = 1:size(wMat, 1)
    wpos_ent{h} = entVal(wMat{h}); % assign current w position h and trial i
end

% save word position x entropy value cell array
savedir = '/home/language/kriarm/matlab/streams_output/data_model/wInd_vs_ent';
savefile = fullfile(savedir, 'wpos_ent');
save(savefile, 'wpos_ent');

figure;
for i = 1:30
    
    subplot(3, 10, i);
    hist(wpos_ent{i}, max(wpos_ent{i})); hold on;

end

%% AUDIOCORTICO MI

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
bpfreqs   = [04 08];

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
                      'timreq', 25*60,...
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
bpfreqs   = [04 08; 12 18];

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
