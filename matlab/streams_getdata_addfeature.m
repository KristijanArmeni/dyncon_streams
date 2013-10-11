function [data] = streams_getdata_addfeature(subject_num, audiofile, feature, sampling_rate)

% This function is intended to create a fieldtrip data structure that contains the MEG data 
% combined with a feature vector for a given audio fragment. 

%% Create the feature vector for the specified audio fragment

% get the data for the given subject
subject = streams_subjinfo(subject_num);

% find the appropriate .donders and .textgrid files, 
[ donders_data, textgrid_data ] = find_donders_and_textgrid_data(audiofile);

% combine them.
combined_data = combine_donders_textgrid(donders_data, textgrid_data);

  

%% Find the row in the subject.trl matrix that corresponds with the specified audio file.
% row_index = 1;
% for i=1:length(subject.audiofile)
%   if strcmp(audiofile, subject.audiofile);
%     break
%   else
%     row_index = row_index+1;
%   end
% end
row_index = find(~cellfun('isempty',strfind(subject.audiofile, audiofile)));


%% read in MEG and audio data
cfg = [];
cfg.dataset = subject.dataset;
cfg.trl     = subject.trl(row_index,:); % teh index from the above 
cfg.continuous = 'yes';
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
data           = ft_preprocessing(cfg);
cfg.channel    = 'UADC004';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 10;
cfg.rectify    = 'yes';
cfg.boxcar     = 0.025;
audio_data     = ft_preprocessing(cfg);

%% downsample data
cfg = [];
cfg.detrend    = 'no';
cfg.demean     = 'yes';
cfg.resamplefs = 300;
data  = ft_resampledata(cfg, data);
audio_data = ft_resampledata(cfg, audio_data);

% create a time series representation of it. 
% the time vector is discarded for now 
[ ~, feature_value_vector ] = get_time_series(combined_data, feature, sampling_rate);

%% Zero pad the features_vector 
%(cos there is silence in the audio that we got rid of)
%interval = subject.trl(row_index, 2) - subject.trl(row_index, 1);
%feature_value_vector(end+interval) = 0;
feature_value_vector(numel(data.time{1})) = 0;

% Step 4: add the feature vector
% create a FieldTrip style data structure for the feature vector
featuredata.time = data.time;
featuredata.trial{1} = zeros(1,numel(data.time{1}));
featuredata.trial{1}(1:numel(feature_value_vector)) = feature_value_vector;
featuredata.label{1} = feature;

%% append
data = ft_appenddata([], data, featuredata, audio_data);
