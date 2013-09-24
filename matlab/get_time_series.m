function [ time , feature_value_vector] = get_time_series( combined_data, feature, sampling_rate )

%GET_STREAMS_TIME_SERIES
% convert the data into a time-series representation


end_time_point = combined_data(end).end_time;     % the length of the 
time = linspace(0, end_time_point, end_time_point * sampling_rate);
feature_value_vector = zeros(1, numel(time));

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
      case 'perplexity'
        feature_value_vector(i) = combined_data(feature_index).perplexity;
      case 'logprob'
        feature_value_vector(i) = combined_data(feature_index).logprob;
      % Add other cases for each field in combined_data
    end
    
  end
end

end

