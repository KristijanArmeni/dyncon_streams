function [ dataout ] = streams_circularshift(data, n)
%streams_circularshift() shifts the data vector by a random value within a range
%of the length of the data vector n-times (each time with a new value). It
%outpus a matrix of dimension 'n by datavector-length'.
%
%    INPUTS:
%           x - 1 x m row vector (can be struct)
%           n - number of circular shifts
%
%    OUTPUT:
%           shifts - a cell array of length equal to the number of trials

% initialize 
num_trial = numel(data.trial);
datavec = cat(2, data.trial{:});

dataout = cell(1, num_trial);
range = length(datavec);

smpsend = [0 cumsum(cellfun('size', data.trial, 2))]; % used to compute the sample indices

% shift the concatenated data vector n-times
datashifted = zeros(n, size(datavec, 2));
for i = 1:n
    
    shift = round(range*rand()); % pick a random value for the shift
    new_begin_indx = shift;
    
    datashifted(i, :) = [datavec(new_begin_indx:end) datavec(1:new_begin_indx-1)];

end

% put the datavector into the output cell array (as the input trials)
for ii = 1:num_trial
   
   dataout{1, ii} = datashifted(:, smpsend(ii)+1:smpsend(ii + 1));
    
end

end


