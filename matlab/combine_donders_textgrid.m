function [ combined_data ] = combine_donders_textgrid( donders_data, textgrid_data )

% COMBINE_DONDERS_TEXTGRID combines the data from the .donders file, which
% contains the outputs of linguistic parsers with the timing information
% from the textgrid data.
%
% Use as
%   [combined_data] = combine_donders_textgrid(filename_d, filename_t)
%
% Input arguments:
%   filenamed = string, filename pointing to a *.donders file
%   filenamet = string, filename pointing to the corresponding *.textgrid
%                 file
%
% Output argument:
%   combined_data = struct-array that contains the combined data, i.e. the
%                    donders-file based struct-array with the timing
%                    information added.

% [p,f1,e] = fileparts(textgrid_data);
% [p,f2,e] = fileparts(donders_data);
% if ~strcmp(f1,f2),
%   error('the filenames of the textgrid data and the donders data are different, and probably refer to different audio files');
% end


combined_data = donders_data;

%for each word, get the start time from the textgrid file and add it to the
% the new field in the combined data structure.
for i=1:numel(textgrid_data(1).times(:, 1))
  combined_data(i).start_time = textgrid_data(1).times(i, 1);
end

% same as above, but for the end times for each word.
for i=1:numel(textgrid_data(1).times(:, 2))
  combined_data(i).end_time = textgrid_data(1).times(i, 2);
end



end