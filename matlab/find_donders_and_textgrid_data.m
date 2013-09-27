function [donders_data, textgrid_data ] = find_donders_and_textgrid_data( audiofile_path )
% FIND_TEXTGRID_AND_DONDERS_DATA 
% finds the .textgrid and .donders files for a specific audio file


base_name = '/home/language/jansch/projects/streams/audio/';

filename = regexp('fn[0-9]+', audiofile_path, 'match');

textgrid_data = fullfile(base_name, filename, '.TextGrid');
donders_data = fullfile(base_name, filename, '.donders');

end

