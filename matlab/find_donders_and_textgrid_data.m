function [donders_data, textgrid_data ] = find_donders_and_textgrid_data( audiofile_path )

% FIND_TEXTGRID_AND_DONDERS_DATA helper function to create the filenames
% for a specified audio file, including the path
%
% Example use:
%   [filename_d, filename_t] = find_donders_and_textgrid_data('fn001055');

base_name = '/home/language/jansch/projects/streams/audio/';

%filename = regexp('fn[0-9]+', audiofile_path, 'match');
filename = audiofile_path;

textgrid_data = fullfile(base_name, filename, [filename, '.TextGrid']);
donders_data  = fullfile(base_name, filename, [filename, '.donders']);

end

