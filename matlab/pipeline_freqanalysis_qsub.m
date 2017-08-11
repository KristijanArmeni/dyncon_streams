function pipeline_freqanalysis_qsub(subject, optarg)

% Initialization
if ischar(subject)
   subject = streams_subjinfo(subject);
end

savedir = '/project/3011044.02/analysis/freqanalysis';
datadir = '/project/3011044.02/preproc';

% filter_range = ft_getopt(optarg, 'filter_range');

filename_meg = [subject.name '_' 'meg-clean'];
filename_meg = fullfile(datadir, 'meg', filename_meg);           % megdata

% load in the data
load(filename_meg)

%% add grad info for s09 (two datasets)
if strcmp(subject.name, 's09')
%     dataset = subject.dataset{1};
%     data.grad = ft_read_sens(dataset, 'senstype', 'meg');  
end

%% Frequency analysis

% epochlength     = ft_getopt(optarg, 'epochlength'); now done in
% rejectcomponent
taper           = ft_getopt(optarg, 'taper');
tapsmooth       = ft_getopt(optarg, 'tapsmooth');

[freq, ~] = streams_freqanalysis(data, taper, tapsmooth);

%% save the output

taperinfo = [taper num2str(tapsmooth)];
% save the info on preprocessing options used
datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = fullfile(savedir, ['s02_' taperinfo '_' datecreated]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq);
end

savenamefreq = [subject.name '_' taperinfo];
savenamefreq = fullfile(savedir, savenamefreq);

save(savenamefreq, 'freq');

