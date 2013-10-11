function [ time , feature_value_vector , trl] = get_time_series( combined_data, feature, sampling_rate )

% GET_STREAMS_TIME_SERIES creates a vector and time axis of a specified
% feature from the computational model output, at a specified sampling
% rate.
%
% Use as:
%   [time, data] = get_time_series(combined_data, feature, sampling_rate)
%
% Input arguments:
%   combined_data = struct_array, the output of COMBINE_DONDERS_TEXTGRID
%   feature       = string, specifying which feature to use
%   sampling_rate = integer scalar, specifying the sampling rate
%
% Output arguments:
%   time = vector, specifying the time axis
%   data = vector, specifying the feature values as a 'block regressor'
%            (one value per word). missing data are represented as NaN.
%   trl  = Nx4 array, FieldTrip style trl-like matrix containing the
%            begin samples and end samples of each element in
%            combined_data, along with a counter (3d row, indexing the
%            element in combined data), and the value of the feature
%            (4th row). note that the samples are counted in the specified
%            sampling_rate, and are relative to the beginning of the
%            stimulus. note, also, that the samples have an offset of 1.

end_time_point = max([combined_data.end_time]);     % the length of the 
time = linspace(0, end_time_point, end_time_point * sampling_rate + 1); 
feature_value_vector = zeros(1, numel(time))+nan; % initialize as NaN so that missing data takes this value

% the index keeps track of which word we are currently on
feature_index = 1;

for i=1:numel(time)

  % keep looping until you get to the word onset
  if time(i) < combined_data(feature_index).start_time
    continue
  end
  
  % if it reaches past the word offset, increment the index
  if time(i) > combined_data(feature_index).end_time
    feature_index = feature_index + 1;
  end
  
  % if the time is between the start and end times for the word, add the
  % value of the feature for that word.
  if combined_data(feature_index).start_time < time(i) < combined_data(feature_index).end_time
    switch feature
      case 'logprob'
        feature_value_vector(i) = combined_data(feature_index).logprob;
      case 'entropy'
        feature_value_vector(i) = combined_data(feature_index).entropy;
      case 'perplexity'
        feature_value_vector(i) = combined_data(feature_index).perplexity;
      % TO DO ... Add other cases for each relevant field in combined_data
    end
    
  end
end

% create a trl-like matrix for the feature with samples expressed in the
% requested sampling_frequency
for i=1:numel(combined_data)
  existtime(i) = ~isempty(combined_data(i).start_time);
end
trl = zeros(numel(combined_data),4)+nan;
trl(existtime,1) = round([combined_data(existtime).start_time]*sampling_rate);
trl(existtime,2) = round([combined_data(existtime).end_time]*sampling_rate);
trl(existtime,3) = 1:sum(existtime);
trl(existtime,4) = [combined_data(existtime).(feature)];

end
