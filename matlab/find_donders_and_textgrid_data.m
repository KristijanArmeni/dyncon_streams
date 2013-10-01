function [ donders_path, textgrid_path ] = find_donders_and_textgrid_data( audiofile_path )
% FIND_TEXTGRID_AND_DONDERS_DATA 
% finds the .textgrid and .donders files for a specific audio file


base_name = '/home/language/jansch/projects/streams/audio/';

id = regexp(audiofile_path, 'fn[0-9]+', 'match');

textgrid_path = fullfile(base_name, id, strcat(id, '.TextGrid'));
donders_path = fullfile(base_name, id, strcat(id, '.donders'));

end

