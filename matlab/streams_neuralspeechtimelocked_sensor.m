function [tlck, p_ind] = streams_neuralspeechtimelocked_sensor(data, audio, varargin)

% streams_neuralspeechtimelocked_sensor() performs time-locked averaging of
% a continous dataset, similar to mouse_neuralspeecktimelocked_sensor()

% CUSTUM FUNCTIONS CALLED WITHIN THIS FUNCTION
% denoise_avg2()
% peakdetect2()

%% INPUT ARGUMENT HANDLING
savecomps       =   ft_getopt(varargin, 'savecomps');
savetlck       =    ft_getopt(varargin, 'savetlck');
dotlck         =    ft_getopt(varargin, 'dotlck', 0);

%% detect peaks in all trials

[p_ind, ~, ~] = streams_findpeaks(audio.trial, 2, 15);


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

fprintf('\nDetected peaks in %d trials.\n', numel(data.trial));
fprintf('\n###streams_neuralspeechtimelocked_sensor: DONE! ...###\n');


%% Perform DSS component analysis

params.tr = [];
params.tr_inds = p_ind;
params.pre = 30;
params.pst = 210;
params.demean = 'prezero';

[comp, avgcomp, params] = artifact_speechramp_dss(data, 'params', params),

%% SAVE VARIABLES

if ~isempty(savecomps);
    save(savecomps, 'comp', 'avgcomp', 'params', 'p_ind');
end

if ~isempty(savetlck);
    save(savetlck, 'tlck')
end

%%%%%%%%%%%%%%%%%%%%
%%% SUBFUNCTION %%%%
function [comp, avgcomp, params] = artifact_speechramp_dss(data, varargin)

%ARTIFACT_SPEECHRAMP_DSS performs blind source separation calling
%ft_componentanalysis

% ensure that the dss2_1-0 directory is on your matlab path
addpath('/home/language/kriarm/matlab/dss2_1-0');

params          = ft_getopt(varargin, 'params');
s.X = 1;

% Do component analysis

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

fprintf('\n###artifact_speechramp_dss: DONE!###\n');