function [comp, avgcomp] = streams_dss_auditory(data, audio, varargin)

% streams_neuralspeechtimelocked_sensor() performs time-locked averaging of
% a continous dataset, similar to mouse_neuralspeecktimelocked_sensor()

% CUSTUM FUNCTIONS CALLED WITHIN THIS FUNCTION
% streams_findpeaks()
% denoise_avg2()

% ensure that the dss2_1-0 directory is on your matlab path
addpath('/home/language/kriarm/matlab/dss2_1-0');

%% input argument handling

savecomps       =   ft_getopt(varargin, 'savecomps');
savetlck        =   ft_getopt(varargin, 'savetlck');
dotlck          =   ft_getopt(varargin, 'dotlck', 0);
pre             =   ft_getopt(varargin, 'pre', 30);
pst             =   ft_getopt(varargin, 'pst', 210);

%% detect peaks in all trials

[p_ind, ~, ~] = streams_findpeaks(audio.trial, 2, 15);


%% Perform DSS component analysis

s.X = 1;

params.tr = [];
params.tr_inds = p_ind;
params.pre = pre;
params.pst = pst;
params.demean = 'prezero';

fprintf('\nStarting component analysis ...\n');
fprintf('=========================================\n');

cfg                   = [];
cfg.cellmode          = 'yes';
cfg.method            = 'dss';
cfg.dss.denf.function = 'denoise_avg2';
cfg.dss.denf.params   = params;
cfg.channel           = 'MEG';
cfg.numcomponent      = 10;
comp                  = ft_componentanalysis(cfg, data);

fprintf('\nAveraging components ...\n');
fprintf('=========================================\n');

[~,~,avgcomp]         = denoise_avg2(params,comp.trial,s);

%% Perform ERF time-locked averaging using denoise_avg2()

if dotlck

    fprintf('\nPerforming time-locked averaging ...\n');
    fprintf('=========================================\n\n')

    s.X = 1;

    % average over all time-locked responses in the story
    [~, ~, avg] = denoise_avg2(params, data.trial, s);

    tlck = [];
    tlck.label = data.label;
    tlck.avg   = avg;
    tlck.dimord = 'chan_time';
    tlck.time = (-params.pre:params.pst)./data.fsample;

end

%% SAVE VARIABLES

if ~isempty(savecomps);
   
   %save just topo and unmixing matrices
   comp_tmp.topo = comp.topo;
   comp_tmp.unmixing = comp.unmixing;
   
   save(savecomps, 'comp_tmp', 'avgcomp', 'params');
end

if ~isempty(savetlck);
    save(savetlck, 'tlck')
end

fprintf('\n###streams_dss_auditory: DONE!###\n');
