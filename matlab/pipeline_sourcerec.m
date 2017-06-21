clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end


%% INITIALIZE
subjects = strsplit(sprintf('s%.2d ', 1:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors
s9 = strcmp(subjects, 's09');
subjects(s9) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

ivars = {'log10perp', 'entropy'};

%% SUBJECT LOOP

cfgfreq.foilim = [40 40];
cfgfreq.tapsmofrq = 10;
cfgfreq.taper = 'dpss';

cfgdics.freq = 40;

for i = 1:num_sub
   
    subject = subjects{i};
    
    for ii = 1:numel(ivars)
        
    ivar = ivars{ii};
    
    qsubfeval('streams_dics', cfgfreq, cfgdics, subject, ivar, ...
              'memreq', 1024^3 * 12,...
              'timreq', 240*60,...
              'batchid', 'streams_features');
          
    end
    
end